//
//  ScanEffects.swift
//  Facet
//
//  The rotating concentric rings and sweeping scan line that make the scan feel
//  like a depth-sensor capture. Both pause when inactive or when Reduce Motion is
//  on, and both animate only transform/opacity for 120 Hz smoothness.
//

import SwiftUI

struct ScanRings: View {
    var active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !active || reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                Circle()
                    .trim(from: 0, to: 0.82)
                    .stroke(AngularGradient(colors: [Palette.aqua, Palette.aqua.opacity(0.12)], center: .center),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .rotationEffect(.radians(t * 1.85))

                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(AngularGradient(colors: [Palette.iris, Palette.iris.opacity(0.12)], center: .center),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .padding(26)
                    .rotationEffect(.radians(-t * 1.4))

                Circle()
                    .stroke(Color.white.opacity(0.28), style: StrokeStyle(lineWidth: 1, dash: [3, 7]))
                    .padding(52)
                    .rotationEffect(.radians(t * 0.5))

                Circle()
                    .stroke(Palette.aqua.opacity(0.22), style: StrokeStyle(lineWidth: 8, dash: [1.5, 15]))
                    .padding(12)
                    .rotationEffect(.radians(t * 0.2))
            }
        }
    }
}

struct ScanLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let cycle = (t.truncatingRemainder(dividingBy: 2.6)) / 2.6   // 0…1

            GeometryReader { geo in
                let h = geo.size.height
                let y = cycle * (h + 60) - 30

                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, Palette.aqua.opacity(0.16), Palette.aqua.opacity(0.55)],
                        startPoint: .top, endPoint: .bottom))
                    .frame(width: geo.size.width, height: 60)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Palette.aqua)
                            .frame(height: 2)
                            .shadow(color: Palette.aqua, radius: 8)
                    }
                    .position(x: geo.size.width / 2, y: y)
                    .opacity(sin(clamp(cycle, 0, 1) * .pi))
            }
        }
    }
}
