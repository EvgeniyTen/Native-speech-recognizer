//
//  SpeechRecognizerProjectApp.swift
//  SpeechRecognizerProject
//
//  Created by Evgeniy Timofeev on 01.02.2024.
//

import SwiftUI

@main
struct SpeechRecognizerProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(speechManager: SpeechRecognizerManager(locale: Locale(identifier: "ru-RU")))
        }
    }
}
