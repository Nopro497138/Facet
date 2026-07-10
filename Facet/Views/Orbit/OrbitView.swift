//
//  OrbitView.swift
//  Facet
//
//  A 3D orbit of connected-service logos around the analysed face. Each tile is
//  positioned on a tilted ring with depth-driven scale, blur, opacity and
//  z-ordering, plus pointer/drag parallax.
//
//  POLICY: these represent services the user connects and authorizes — not
//  identity matches. The note below makes that explicit in the UI.
//

import SwiftUI

struct OrbitView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var parallax: CGSize = .zero
    private let services = ConnectedService.catalog

    var body: some View {
        ScreenScaffold {
            header
            orbitStage
            noteCard
            PrimaryButton(title: "Search my authorized sources", systemImage: "magnifyingglass") {
                router.go(to: .search)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(Palette.iris).frame(width: 7, height: 7)
                Text("Connected sources")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xC3CCFF))
            }
            .padding(.horizontal, 11).padding(.vertical, 5)
            .background(Palette.iris.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(Palette.iris.opacity(0.28), lineWidth: 1))

            Text("Your configured services")
                .font(.facetTitle(24))
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var orbitStage: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                let cx = geo.size.width / 2
                let cy = geo.size.height / 2
                let radiusX = min(geo.size.width, 360) / 2 - 16
                let radiusY = 54.0

                ZStack {
                    centerSubject(t: t)
                        .position(x: cx, y: cy)
                        .zIndex(0)

                    ForEach(Array(services.enumerated()), id: \.element.id) { index, service in
                        let angle = Double(index) / Double(services.count) * 2 * .pi + t * 0.4
                        let depth = sin(angle)                       // -1 (back) … 1 (front)
                        let x = cos(angle) * radiusX
                        let bob = reduceMotion ? 0 : sin(t * 1.2 + Double(index)) * 4
                        let y = depth * radiusY + bob
                        let scale = 0.62 + (depth + 1) / 2 * 0.5
                        let opacity = 0.4 + (depth + 1) / 2 * 0.6
                        let blur = (1 - (depth + 1) / 2) * 3

                        BrandTile(service: service, side: 52)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .blur(radius: blur)
                            .position(x: cx + x, y: cy + y)
                            .zIndex(depth)
                    }
                }
                .rotation3DEffect(.degrees(Double(parallax.height) * -0.05), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(Double(parallax.width) * 0.06), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(height: 420)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { parallax = $0.translation }
                .onEnded { _ in withAnimation(Motion.card) { parallax = .zero } }
        )
    }

    private func centerSubject(t: Double) -> some View {
        ZStack {
            Circle()
                .strokeBorder(Palette.aqua.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 8]))
                .frame(width: 210, height: 210)
                .rotationEffect(.radians(reduceMotion ? 0 : t * 0.1))

            FaceSubjectView(image: router.activeAnalysis?.image,
                            showMesh: router.activeAnalysis?.image == nil)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Palette.iris.opacity(0.3), lineWidth: 1))
                .shadow(color: Palette.aqua.opacity(0.5), radius: 40)
                .shadow(color: Palette.iris.opacity(0.4), radius: 60)
        }
    }

    private var noteCard: some View {
        GlassCard(padding: 14) {
            Text("These are **services you connect** and sources you authorize — not identity matches. Facet never claims to recognize unknown people or search the open internet.")
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .lineSpacing(3)
        }
    }
}
