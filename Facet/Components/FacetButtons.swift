//
//  FacetButtons.swift
//  Facet
//
//  Primary and ghost buttons with tactile press feedback (a subtle scale-down and
//  spring-back) and haptics. Built as `ButtonStyle`s so any Button can adopt them.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16.5, weight: .semibold))
            .foregroundStyle(Color(hex: 0x04120F))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Gradients.primaryButton, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                    .blendMode(.overlay)
            }
            .shadow(color: Palette.aqua.opacity(0.5), radius: 18, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .glassCard(cornerRadius: 18, highlight: false)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// Primary call-to-action with an optional leading SF Symbol and haptic feedback.
struct PrimaryButton: View {
    var title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.press()
            action()
        } label: {
            HStack(spacing: 9) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct GhostButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Text(title)
        }
        .buttonStyle(GhostButtonStyle())
    }
}
