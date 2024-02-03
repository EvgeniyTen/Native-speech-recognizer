//
//  SpeechRecognizerManager.swift
//  SpeechRecognizerProject
//
//  Created by Evgeniy Timofeev on 03.02.2024.
//

import Foundation
import Speech


class SpeechRecognizerManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var textSpeech: String = "" 
    @Published var isBusy: Bool = false
    
    private static let AUDIO_BUFFER_SIZE: UInt32 = 1024
    private let speechRecognizer: SFSpeechRecognizer
    private var speechRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    override public convenience init() {
        self.init(speechRecognizer: SFSpeechRecognizer())
    }
    
    public convenience init(locale: Locale) {
        self.init(speechRecognizer: SFSpeechRecognizer(locale: locale))
    }
    
    private init(speechRecognizer: SFSpeechRecognizer?) {
        guard let speechRecognizer = speechRecognizer else {
            fatalError("Locale not supported. Check SpeechController.supportedLocales() or  SpeechController.localeSupported(locale: Locale)")
        }
        self.speechRecognizer = speechRecognizer
        self.speechRecognizer.defaultTaskHint = .search
        super.init()
        DispatchQueue.main.async {
            self.requestAuthorization()
        }
    }
    
    private func supportedLocales() -> Set<Locale> {
        return SFSpeechRecognizer.supportedLocales()
    }
    
    private func localeSupported(_ locale: Locale) -> Bool {
        return SFSpeechRecognizer.supportedLocales().contains(locale)
    }
    
    @MainActor
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.textSpeech = "Давай, удиви!"
                default:
                    self.textSpeech = "У нас ничего не выйдет!"
                }
            }
        }
    }
    
    func enableRecognizer() {
        DispatchQueue.main.async {
            if self.isBusy {
                self.stopRecording()
            } else {
                self.startRecording()
            }
        }
    }
    
    @MainActor
    private func startRecording() {
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch{
            print(error.localizedDescription)
            return
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        speechRequest = SFSpeechAudioBufferRecognitionRequest()
        
        node.installTap(onBus: 0,
                        bufferSize: Self.AUDIO_BUFFER_SIZE,
                        format: recordingFormat) { [weak self] (buffer, _) in
            self?.speechRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isBusy = true

        } catch{
            return
        }
        
        speechTask = speechRecognizer.recognitionTask(with: speechRequest!) { [weak self] (result, error) in
            guard let self, let result else { return }
            if !result.bestTranscription.formattedString.isEmpty {
                let transcription = result.bestTranscription
                textSpeech = transcription.formattedString
            }
        }
    }
    
    @MainActor
    public func stopRecording() {
        if audioEngine.isRunning {
            speechRequest?.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            speechTask?.cancel()
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        speechTask = nil
        speechRequest = nil
        isBusy = false
    }    
}
