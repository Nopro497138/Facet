//
//  ParticleField.swift
//  Facet
//
//  A GPU-friendly ambient particle field drawn in a single `Canvas`, driven by
//  `TimelineView`. Positions are computed analytically from elapsed time (no
//  per-frame mutable state), so it stays smooth and cheap. Honours Reduce Motion
//  and the performance-mode particle budget.
//

import SwiftUI

private struct Particle {
    var x: Double          // base position 0…1
    var y: Double
    var vx: Double         // drift per second
    var vy: Double
    var radius: Double     // points
    var alpha: Double
    var warm: Bool         // aqua vs iris tint
}

struct ParticleField: View {
    var count: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let particles: [Particle]

    init(count: Int) {
        self.count = count
        var generator = SystemRandomNumberGenerator()
        self.particles = (0..<max(count, 0)).map { _ in
            Particle(
                x: .random(in: 0...1, using: &generator),
                y: .random(in: 0...1, using: &generator),
                vx: .random(in: -0.012...0.012, using: &generator),
                vy: .random(in: -0.012...0.012, using: &generator),
                radius: .random(in: 0.6...2.0, using: &generator),
                alpha: .random(in: 0.1...0.55, using: &generator),
                warm: Bool.random(using: &generator)
            )
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for p in particles {
                    // Wrap drift within 0…1, then scale to the canvas.
                    let nx = (p.x + p.vx * t).truncatingRemainder(dividingBy: 1)
                    let ny = (p.y + p.vy * t).truncatingRemainder(dividingBy: 1)
                    let x = (nx < 0 ? nx + 1 : nx) * size.width
                    let y = (ny < 0 ? ny + 1 : ny) * size.height
                    let rect = CGRect(x: x, y: y, width: p.radius * 2, height: p.radius * 2)
                    let tint = (p.warm ? Palette.aqua : Palette.iris).opacity(p.alpha)
                    context.fill(Path(ellipseIn: rect), with: .color(tint))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
