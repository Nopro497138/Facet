//
//  TabBar.swift
//  Facet
//
//  A floating glass tab bar with four destinations and a prominent central Scan
//  action. The active destination is marked by a sliding pill (matched geometry),
//  which communicates state far better than an instant colour change.
//

import SwiftUI

struct TabBar: View {
    @Environment(AppRouter.self) private var router
    @Namespace private var pill

    private let tabs: [Screen] = [.home, .orbit, .search, .settings]

    var body: some View {
        HStack(spacing: 4) {
            tabButton(tabs[0])
            tabButton(tabs[1])
            scanButton
            tabButton(tabs[2])
            tabButton(tabs[3])
        }
        .padding(6)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    private func tabButton(_ screen: Screen) -> some View {
        let selected = router.screen == screen
        return Button {
            Haptics.change()
            router.go(to: screen)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: screen.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(height: 20)
                Text(screen.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selected ? Palette.text : Palette.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.aqua.opacity(0.18), Palette.iris.opacity(0.18)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Palette.iris.opacity(0.35), lineWidth: 1))
                        .matchedGeometryEffect(id: "tabpill", in: pill)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var scanButton: some View {
        Button {
            Haptics.press()
            router.go(to: .scan)
        } label: {
            Image(systemName: "viewfinder")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: 0x04120F))
                .frame(width: 56, height: 56)
                .background(Gradients.primaryButton, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 0.5).blendMode(.overlay))
                .shadow(color: Palette.aqua.opacity(0.6), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .offset(y: -10)
        .frame(maxWidth: .infinity)
    }
}
