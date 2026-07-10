//
//  Interactions.swift
//  Facet
//
//  Shared interaction primitives: a staggered reveal-on-appear modifier and a
//  pressable card style (subtle scale-down on touch). Keeping these in one place
//  means the whole app shares a single motion vocabulary.
//

import SwiftUI

struct RevealOnAppear: ViewModifier {
    var delay: Double = 0
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 14)
            .onAppear {
                withAnimation(reduceMotion ? .none : Motion.panel.delay(delay)) { shown = true }
            }
    }
}

extension View {
    /// Fade + rise into place, optionally after `delay` seconds (for staggering).
    func revealOnAppear(delay: Double = 0) -> some View {
        modifier(RevealOnAppear(delay: delay))
    }
}

/// A button style for tappable cards: a gentle press scale, nothing more.
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}
