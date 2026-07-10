//
//  RootView.swift
//  Facet
//
//  The app shell. It layers the ambient background, the active stage (which
//  cross-fades on change), and the floating tab bar. Individual stages are kept
//  deliberately dumb — navigation lives in `AppRouter`.
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SettingsStore.self) private var settings

    var body: some View {
        ZStack {
            AmbientBackground(particleCount: settings.particleBudget)

            stage
                .id(router.screen)
                .transition(stageTransition)

            VStack {
                Spacer()
                TabBar()
            }
            .ignoresSafeArea(.keyboard)
        }
        .animation(Motion.stage, value: router.screen)
    }

    @ViewBuilder
    private var stage: some View {
        switch router.screen {
        case .home:     HomeView()
        case .scan:     ScanView()
        case .orbit:    OrbitView()
        case .insights: InsightsView()
        case .search:   SearchView()
        case .results:  ResultsView()
        case .settings: SettingsView()
        }
    }

    private var stageTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98)),
            removal: .opacity.combined(with: .scale(scale: 1.01)))
    }
}

/// A consistent scrollable container for stages: standard insets and room for the
/// floating tab bar.
struct ScreenScaffold<Content: View>: View {
    var spacing: CGFloat = 16
    var content: Content

    init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 120)   // clear the floating tab bar
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
