//
//  GlassCard.swift
//  Facet
//
//  The signature translucent surface: an ultra-thin material with a whisper of
//  tint and a top-left highlight edge. Exposed both as a container view and as a
//  `.glassCard()` modifier.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 24
    var highlight: Bool = true

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape
                    .fill(Color.white.opacity(0.04))
                    .background(.ultraThinMaterial, in: shape)
            }
            .overlay {
                if highlight {
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), .clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1)
                } else {
                    shape.strokeBorder(Palette.hairline, lineWidth: 1)
                }
            }
            .clipShape(shape)
            .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 16)
    }
}

extension View {
    /// Wrap content in Facet's glass surface.
    func glassCard(cornerRadius: CGFloat = 24, highlight: Bool = true) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius, highlight: highlight))
    }
}

/// A convenience container that pads its content inside a glass card.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var padding: CGFloat = 16
    var content: Content

    init(cornerRadius: CGFloat = 24, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: cornerRadius)
    }
}
