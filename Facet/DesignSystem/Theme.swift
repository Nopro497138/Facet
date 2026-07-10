//
//  Theme.swift
//  Facet
//
//  The single source of truth for colour. Facet's identity is a cool graphite
//  "biometric console": a near-black ground with a slight blue bias, luminous
//  spectral aqua for AI energy, periwinkle-iris for depth, and exactly one warm
//  coral note reserved for the human/face signal (emotion, warmth).
//

import SwiftUI

/// Named palette. Every colour in the app is derived from here — never hard-coded.
enum Palette {
    // Ground
    static let ink      = Color(hex: 0x06070C)
    static let ink2     = Color(hex: 0x090C14)
    static let ink3     = Color(hex: 0x0C111C)

    // Accents
    static let aqua     = Color(hex: 0x54F2D6)   // primary — AI / scan energy
    static let aquaDeep = Color(hex: 0x26C9B4)
    static let iris     = Color(hex: 0x7C8CFF)   // depth
    static let irisDeep = Color(hex: 0x5866E8)
    static let coral    = Color(hex: 0xFF8A8A)   // the single warm/human note

    // Text
    static let text     = Color(hex: 0xEEF3FB)
    static let text2    = Color(hex: 0xAEB9CE)
    static let muted    = Color(hex: 0x7C879C)
    static let faint    = Color(hex: 0x5A6377)

    // Semantic (distinct from the accent hue)
    static let good     = Color(hex: 0x54F2D6)
    static let warn     = Color(hex: 0xFFCE7A)
    static let critical = Color(hex: 0xFF7A93)

    // Hairlines
    static let hairline = Color.white.opacity(0.08)
    static let hairline2 = Color.white.opacity(0.05)
}

/// Reusable gradients built from the palette.
enum Gradients {
    /// The signature spectral sweep used on titles, meters and glows.
    static let spectral = LinearGradient(
        colors: [Palette.aqua, Palette.iris],
        startPoint: .leading, endPoint: .trailing)

    static let spectralDiagonal = LinearGradient(
        colors: [Palette.aqua, Palette.iris],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    /// Primary button fill.
    static let primaryButton = LinearGradient(
        colors: [Color(hex: 0x7DFBE4), Palette.aqua, Palette.aquaDeep],
        startPoint: .top, endPoint: .bottom)

    /// The ambient page background (radial glows over a graphite base).
    static let appBackground = LinearGradient(
        colors: [Color(hex: 0x04050A), Color(hex: 0x07090F), Color(hex: 0x05070C)],
        startPoint: .top, endPoint: .bottom)
}

// MARK: - Hex initialiser

extension Color {
    /// Create a colour from a 24-bit hex literal, e.g. `Color(hex: 0x54F2D6)`.
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
