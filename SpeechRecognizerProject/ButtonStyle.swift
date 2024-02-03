//
//  ButtonStyle.swift
//  SpeechRecognizerProject
//
//  Created by Evgeniy Timofeev on 03.02.2024.
//

import SwiftUI

extension Button {
    func neomorphStyle(_ isAppeared: Bool) -> some View {
        self
            .buttonStyle(NeomorphButtonStyle(isAppeared))
    }
}

struct NeomorphButtonStyle: ButtonStyle {
    var isAppeared: Bool
    
    init(_ isAppeared: Bool = true) {
        self.isAppeared = isAppeared
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(isAppeared ? 1 : 0.95)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .modifier(NeomorphModifier(isAppeared: isAppeared, isPressed: configuration.isPressed))
    }

}


struct NeomorphModifier: ViewModifier {
    var isAppeared: Bool
    var isPressed: Bool
    let startDate = Date.now

    func body(content: Content) -> some View {
        content
            .background(
                backgroundContent(content: content)
            )
            .animation(.snappy(duration: 0.3, extraBounce: 0.6), value: isAppeared)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
    
    @ViewBuilder
    func backgroundContent(content: Content) -> some View {
        switch isAppeared {
        case true:
            TimelineView(.animation) { context in
                content
                
                    .shadow(color: .black.opacity(0.3),
                            radius: isPressed ? 1 : 5,
                            x: isPressed ? -2 : 5,
                            y: isPressed ? -2 : 5)
                    .shadow(color: .white.opacity(0.3),
                            radius: isPressed ? 0 : 5,
                            x: isPressed ? 2 : -5,
                            y: isPressed ? 2 : -5)
                    .blur(radius: isPressed ? 1 : 5)
            }

        case false:
            EmptyView()
        }
    }
}
