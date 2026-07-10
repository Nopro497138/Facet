//
//  Motion.swift
//  Facet
//
//  One shared motion vocabulary so the whole app feels like a single system.
//  Durations follow a tight scale (micro → page); we favour ease-out for things
//  that appear and a gentle spring for tactile presses. Every value here maps to
//  the timing scale used across premium product UIs.
//

import SwiftUI

enum Motion {
    // Micro-interactions & controls
    static let micro   = Animation.easeOut(duration: 0.18)
    static let control = Animation.spring(response: 0.28, dampingFraction: 0.7)

    // Cards & panels
    static let card    = Animation.spring(response: 0.34, dampingFraction: 0.82)
    static let panel   = Animation.easeOut(duration: 0.30)

    // Full-screen stage transitions
    static let stage   = Animation.spring(response: 0.5, dampingFraction: 0.86)

    // Continuous / ambient loops (linear so they never "pulse")
    static let ambient = Animation.linear(duration: 6).repeatForever(autoreverses: false)

    /// Press feedback used by buttons: scale down slightly, spring back.
    static let press   = Animation.spring(response: 0.22, dampingFraction: 0.6)
}

/// Respects the system Reduce Motion setting: returns `.none`-like behaviour
/// by collapsing to a fast fade when the user prefers reduced motion.
struct MotionSensitive: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .easeOut(duration: 0.01) : animation, value: UUID())
    }
}
