//
//  GlowOrb.swift
//  Facet
//
//  The Home hero: a luminous orb with a slow rotating shimmer, a floating bob and
//  two orbital rings. Driven by `TimelineView` for smooth, continuous motion.
//

import SwiftUI

struct GlowOrb: View {
    var size: CGFloat = 186

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let float = reduceMotion ? 0 : CGFloat(sin(t * 0.9) * 6)

            ZStack {
                orbitalRing(diameter: size * 1.56, speed: -0.06, dashed: false, tint: Palette.iris.opacity(0.16), t: t)
                orbitalRing(diameter: size * 1.25, speed: 0.10, dashed: true, tint: Palette.aqua.opacity(0.28), t: t)

                // Core gradients.
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0xB8FFF0), Palette.aqua.opacity(0.9), Palette.aqua.opacity(0.0)],
                        center: UnitPoint(x: 0.38, y: 0.32), startRadius: 2, endRadius: size * 0.6))
                Circle()
                    .fill(RadialGradient(
                        colors: [Palette.iris.opacity(0.85), .clear],
                        center: UnitPoint(x: 0.66, y: 0.72), startRadius: 2, endRadius: size * 0.55))
                    .blendMode(.screen)

                // Rotating conic shimmer along the rim.
                Circle()
                    .strokeBorder(
                        AngularGradient(colors: [.clear, .white.opacity(0.55), .clear],
                                        center: .center),
                        lineWidth: 4)
                    .rotationEffect(.radians(reduceMotion ? 0 : t * 0.8))
                    .blur(radius: 1)

                // Specular highlight.
                Circle()
                    .fill(RadialGradient(colors: [.white.opacity(0.7), .clear],
                                         center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: size * 0.22))
                    .frame(width: size * 0.5, height: size * 0.5)
                    .blur(radius: 2)
            }
            .frame(width: size, height: size)
            .shadow(color: Palette.aqua.opacity(0.5), radius: 44)
            .shadow(color: Palette.iris.opacity(0.4), radius: 66)
            .offset(y: float)
            .frame(width: size * 1.6, height: size * 1.6)   // room for rings
        }
    }

    private func orbitalRing(diameter: CGFloat, speed: Double, dashed: Bool, tint: Color, t: Double) -> some View {
        Circle()
            .strokeBorder(tint, style: StrokeStyle(lineWidth: 1, dash: dashed ? [4, 8] : []))
            .frame(width: diameter, height: diameter)
            .overlay(alignment: .top) {
                Circle()
                    .fill(Palette.aqua)
                    .frame(width: 6, height: 6)
                    .shadow(color: Palette.aqua, radius: 6)
                    .offset(y: -3)
            }
            .rotationEffect(.radians(reduceMotion ? 0 : t * speed))
    }
}
