//
//  Typography.swift
//  Facet
//
//  Facet uses the authentic Apple system face (SF Pro via `.system`) and finds
//  personality through weight, optical size and tracking — the correct choice
//  for an app that should feel designed by Apple. Data uses a monospaced face so
//  digits align in columns.
//

import SwiftUI

extension Font {
    /// Large screen title (e.g. "Insights").
    static func facetTitle(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    /// Section heading.
    static let facetHeadline = Font.system(size: 19, weight: .semibold)
    /// Standard body copy.
    static let facetBody = Font.system(size: 15, weight: .regular)
    /// Secondary / caption.
    static let facetCaption = Font.system(size: 12, weight: .medium)
    /// Uppercase eyebrow label.
    static let facetEyebrow = Font.system(size: 11, weight: .semibold)
    /// Numeric / HUD readouts.
    static func facetMono(_ size: CGFloat = 13, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension View {
    /// An uppercase, letter-spaced eyebrow label in the muted tone.
    func eyebrowStyle() -> some View {
        self.font(.facetEyebrow)
            .tracking(2.4)
            .textCase(.uppercase)
            .foregroundStyle(Palette.muted)
    }
}
