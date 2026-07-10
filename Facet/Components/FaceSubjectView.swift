//
//  FaceSubjectView.swift
//  Facet
//
//  A privacy-forward, abstract representation of a scanned subject: a depth-mesh
//  face rendered in the spectral palette. Deliberately NOT a real person — it is
//  used as a placeholder/thumbnail and as the target of the scan animation.
//
//  When a real analysis is available, `landmarks` can be supplied to overlay the
//  detected points on top of the user's own photo (see `ScanView`).
//

import SwiftUI

struct FaceSubjectView: View {
    /// Optional real photo to show underneath the mesh (the user's chosen image).
    var image: UIImage? = nil
    /// Draw the depth-contour mesh + landmarks overlay.
    var showMesh: Bool = true
    /// Mesh line opacity, animatable for the scan reveal.
    var meshOpacity: Double = 1

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height) / 200.0
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RadialGradient(colors: [Color(hex: 0x12203C), Color(hex: 0x060A14)],
                                   center: UnitPoint(x: 0.42, y: 0.34), startRadius: 4, endRadius: geo.size.width)
                }

                if showMesh {
                    Canvas { context, _ in
                        if image == nil {
                            // Abstract face silhouette (only when there's no real photo).
                            var face = Path()
                            let pts = [(100.0, 34.0), (62, 60), (60, 108), (78, 146), (100, 158), (122, 146), (140, 108), (138, 60)]
                            face.move(to: scaled(pts[0], s))
                            for p in pts.dropFirst() { face.addLine(to: scaled(p, s)) }
                            face.closeSubpath()
                            context.fill(face, with: .linearGradient(
                                Gradient(colors: [Color(hex: 0x2B3F6E), Color(hex: 0x141F3C)]),
                                startPoint: .zero, endPoint: CGPoint(x: geo.size.width, y: geo.size.height)))
                        }

                        let line = Palette.aqua.opacity(0.5 * meshOpacity)
                        for contour in Self.contours {
                            var path = Path()
                            path.move(to: scaled(contour.0, s))
                            path.addQuadCurve(to: scaled(contour.2, s), control: scaled(contour.1, s))
                            context.stroke(path, with: .color(line), lineWidth: 0.8 * s)
                        }
                        for l in Self.landmarks {
                            let r = 2.4 * s
                            let rect = CGRect(x: scaled(l, s).x - r, y: scaled(l, s).y - r, width: r * 2, height: r * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.9 * meshOpacity)))
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func scaled(_ p: (Double, Double), _ s: CGFloat) -> CGPoint {
        CGPoint(x: p.0 * s, y: p.1 * s)
    }

    // Depth-contour curves: (start, control, end) in a 200×200 design space.
    private static let contours: [((Double, Double), (Double, Double), (Double, Double))] = [
        ((62, 60), (100, 50), (138, 60)),
        ((60, 82), (100, 72), (140, 82)),
        ((60, 104), (100, 96), (140, 104)),
        ((66, 124), (100, 120), (134, 124)),
        ((74, 142), (100, 140), (126, 142)),
        ((100, 42), (100, 100), (100, 156)),
        ((80, 52), (80, 100), (80, 148)),
        ((120, 52), (120, 100), (120, 148))
    ]

    private static let landmarks: [(Double, Double)] = [
        (80, 90), (120, 90), (100, 112), (86, 132), (114, 132), (100, 34), (100, 158)
    ]
}
