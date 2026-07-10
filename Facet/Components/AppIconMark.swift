//
//  AppIconMark.swift
//  Facet
//
//  The Facet mark as a live SwiftUI view: a low-poly faceted "scan mask" that
//  refracts the spectral palette (aqua → iris, with one warm coral note at the
//  chin). Used for the launch/splash flourish and in-app branding. The very same
//  geometry backs the exported AppIcon PNG.
//

import SwiftUI

struct AppIconMark: View {
    var size: CGFloat = 64
    /// Draw the dark rounded background (off when placing on an existing surface).
    var showBackground: Bool = true

    // Facet vertices in a 1024 design space.
    private static let A = CGPoint(x: 512, y: 258)
    private static let B = CGPoint(x: 706, y: 372)
    private static let C = CGPoint(x: 726, y: 566)
    private static let D = CGPoint(x: 604, y: 726)
    private static let E = CGPoint(x: 512, y: 780)
    private static let F = CGPoint(x: 420, y: 726)
    private static let G = CGPoint(x: 298, y: 566)
    private static let H = CGPoint(x: 318, y: 372)
    private static let M = CGPoint(x: 512, y: 468)
    private static let N = CGPoint(x: 512, y: 588)

    private struct Facet { let pts: [CGPoint]; let color: Color }

    private static let facets: [Facet] = [
        .init(pts: [A, H, M], color: Color(hex: 0x5CEBDA)),
        .init(pts: [A, M, B], color: Color(hex: 0x6FE9D2)),
        .init(pts: [H, G, M], color: Color(hex: 0x6E8BFF)),
        .init(pts: [B, M, C], color: Color(hex: 0x7E8CFF)),
        .init(pts: [G, N, M], color: Color(hex: 0x43D4CC)),
        .init(pts: [C, N, M], color: Color(hex: 0x54C6E1)),
        .init(pts: [G, F, N], color: Color(hex: 0x5A63E6)),
        .init(pts: [C, D, N], color: Color(hex: 0x6A63DE)),
        .init(pts: [F, E, N], color: Color(hex: 0xFF9C8E)),   // warm note
        .init(pts: [D, E, N], color: Color(hex: 0xF98394))
    ]

    var body: some View {
        Canvas { context, canvas in
            let scale = min(canvas.width, canvas.height) / 1024.0
            func P(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x * scale, y: p.y * scale) }

            if showBackground {
                let bg = Path(CGRect(origin: .zero, size: canvas))
                context.fill(bg, with: .linearGradient(
                    Gradient(colors: [Color(hex: 0x111A30), Color(hex: 0x0A1020), Color(hex: 0x05070F)]),
                    startPoint: .zero, endPoint: CGPoint(x: canvas.width, y: canvas.height)))
            }

            // Facets.
            for facet in Self.facets {
                var path = Path()
                path.move(to: P(facet.pts[0]))
                path.addLine(to: P(facet.pts[1]))
                path.addLine(to: P(facet.pts[2]))
                path.closeSubpath()
                context.fill(path, with: .color(facet.color))
            }

            // Bright silhouette edge.
            var outline = Path()
            outline.move(to: P(Self.A))
            [Self.B, Self.C, Self.D, Self.E, Self.F, Self.G, Self.H].forEach { outline.addLine(to: P($0)) }
            outline.closeSubpath()
            context.stroke(outline, with: .color(Color(hex: 0xEAFBFF).opacity(0.35)), lineWidth: 4 * scale)

            // Focal scan node.
            let r = 15 * scale
            let node = CGRect(x: P(Self.M).x - r, y: P(Self.M).y - r, width: r * 2, height: r * 2)
            context.fill(Path(ellipseIn: node.insetBy(dx: -r * 2, dy: -r * 2)),
                         with: .color(Color(hex: 0xEAFFFB).opacity(0.35)))
            context.fill(Path(ellipseIn: node), with: .color(Color(hex: 0xF4FFFD)))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous))
    }
}
