//
//  ContentView.swift
//  SpeechRecognizerProject
//
//  Created by Evgeniy Timofeev on 01.02.2024.
//

import SwiftUI

enum MainState {
    case listening
    case spelling
}

struct ContentView: View {
    @ObservedObject var speechManager: SpeechRecognizerManager
    
    var body: some View {
        ZStack {
            color.ignoresSafeArea()
            VStack {
                Text(speechManager.textSpeech)
                    .foregroundStyle(.white)
                    .fontWeight(.heavy)
                    .frame(maxHeight: .infinity)
                
                Button {
                    speechManager.enableRecognizer()
                } label: {
                    Text(speechManager.isBusy ? "Закончить" : "Говорите")
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            Rectangle()
                                .cornerRadius(20)
                                .foregroundStyle(color)
                        )
                }
                .neomorphStyle(true)
                .frame(maxHeight: .infinity)
            }
        }
        .animation(.smooth, value: speechManager.isBusy)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }
    
    var color: Color {
        speechManager.isBusy ? .red : .gray
    }

}

#Preview {
    ContentView(speechManager: .init())
}

