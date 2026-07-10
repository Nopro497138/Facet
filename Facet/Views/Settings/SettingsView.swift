//
//  SettingsView.swift
//  Facet
//
//  Grouped, iOS-native settings covering appearance, intelligence, privacy and
//  system. Controls bind directly to the persisted `SettingsStore`.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var store
    @Environment(LibraryStore.self) private var library
    @State private var confirmErase = false

    var body: some View {
        @Bindable var store = store

        ScreenScaffold {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "Preferences")
                Text("Settings").font(.facetTitle(26)).foregroundStyle(Palette.text)
            }
            .padding(.top, 4)

            // Appearance
            group("Appearance") {
                SettingsRow(icon: "circle.lefthalf.filled", colors: [Palette.aqua, Palette.aquaDeep], title: "Theme") {
                    SegmentedControl(options: AppearanceMode.allCases.map(\.rawValue),
                                     selection: $store.settings.appearance)
                }
                rowDivider
                SettingsRow(icon: "sparkles", colors: [Palette.iris, Palette.irisDeep],
                            title: "Accent", subtitle: "Spectral aqua") {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Gradients.spectralDiagonal).frame(width: 18, height: 18)
                }
                rowDivider
                SettingsRow(icon: "wand.and.rays.inverse", colors: [Palette.coral, Color(hex: 0xC97A66)],
                            title: "Reduce motion", subtitle: "Calmer animations throughout") {
                    Toggle("", isOn: $store.settings.reduceMotion).labelsHidden().tint(Palette.aqua)
                }
            }

            // Intelligence
            group("Intelligence") {
                SettingsRow(icon: "cpu", colors: [Palette.aqua, Palette.iris],
                            title: "On-device AI", subtitle: "All analysis stays local") {
                    Toggle("", isOn: $store.settings.onDeviceAI).labelsHidden().tint(Palette.aqua)
                }
                rowDivider
                SettingsRow(icon: "chart.bar.doc.horizontal", colors: [Palette.iris, Palette.irisDeep],
                            title: "Emotion & age estimates", subtitle: "Always labelled as estimates") {
                    Toggle("", isOn: $store.settings.showEstimates).labelsHidden().tint(Palette.aqua)
                }
                rowDivider
                SettingsRow(icon: "cube.transparent", colors: [Palette.aqua, Palette.aquaDeep],
                            title: "Model management", subtitle: "Vision · FaceMesh · on-device") {
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Palette.faint)
                }
            }

            // Privacy & data
            group("Privacy & data") {
                SettingsRow(icon: "checkmark.shield.fill", colors: [Palette.aqua, Palette.aquaDeep],
                            title: "Never upload without consent", subtitle: "Photos leave the device only on your action") {
                    Toggle("", isOn: $store.settings.neverUploadWithoutConsent).labelsHidden().tint(Palette.aqua)
                }
                rowDivider
                SettingsRow(icon: "lock.rectangle.stack", colors: [Palette.iris, Palette.irisDeep],
                            title: "Authorized sources", subtitle: "\(ConnectedService.connected.count) connected · read-only") {
                    Text("Manage").font(.system(size: 13)).foregroundStyle(Palette.muted)
                }
                rowDivider
                Button { confirmErase = true } label: {
                    SettingsRow(icon: "trash", colors: [Palette.coral, Color(hex: 0xC76655)],
                                title: "Delete all analysis", subtitle: "Clears the local index & embeddings") {
                        Text("Erase").font(.system(size: 13, weight: .medium)).foregroundStyle(Palette.critical)
                    }
                }
                .buttonStyle(.plain)
            }

            // System
            group("System") {
                SettingsRow(icon: "bolt.fill", colors: [Palette.aqua, Palette.iris],
                            title: "Performance mode", subtitle: "120 Hz ProMotion · GPU effects") {
                    SegmentedControl(options: PerformanceMode.allCases.map(\.rawValue),
                                     selection: $store.settings.performance)
                }
                rowDivider
                SettingsRow(icon: "square.and.arrow.up", colors: [Palette.iris, Palette.irisDeep],
                            title: "Export insights", subtitle: "JSON · CSV · PDF report") {
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Palette.faint)
                }
                rowDivider
                SettingsRow(icon: "info.circle", colors: [Palette.aqua, Palette.aquaDeep],
                            title: "Diagnostics & About", subtitle: "Facet \(appVersion) · \(library.photosIndexed) indexed") {
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Palette.faint)
                }
            }

            footer
        }
        .confirmationDialog("Delete all on-device analysis?",
                            isPresented: $confirmErase, titleVisibility: .visible) {
            Button("Erase everything", role: .destructive) {
                Haptics.success()
                withAnimation(Motion.card) { library.removeAll() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your local index and face embeddings. It cannot be undone.")
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            AppIconMark(size: 44)
            Text("Facet · Face Intelligence").font(.system(size: 12, weight: .medium)).foregroundStyle(Palette.text2)
            Text("On-device · Privacy-first · v\(appVersion)").font(.system(size: 11)).foregroundStyle(Palette.faint)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: Group container

    @ViewBuilder
    private func group<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(.system(size: 11.5, weight: .semibold)).tracking(1.4)
                .textCase(.uppercase).foregroundStyle(Palette.muted)
                .padding(.horizontal, 4)
            VStack(spacing: 0) { content() }
                .glassCard(cornerRadius: 20)
        }
        .padding(.top, 4)
    }

    private var rowDivider: some View {
        Rectangle().fill(Palette.hairline2).frame(height: 1).padding(.leading, 57)
    }
}

// MARK: - Row

private struct SettingsRow<Trailing: View>: View {
    var icon: String
    var colors: [Color]
    var title: String
    var subtitle: String? = nil
    var trailing: Trailing

    init(icon: String, colors: [Color], title: String, subtitle: String? = nil,
         @ViewBuilder trailing: () -> Trailing) {
        self.icon = icon
        self.colors = colors
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 14.5)).foregroundStyle(Palette.text)
                if let subtitle {
                    Text(subtitle).font(.system(size: 11.5)).foregroundStyle(Palette.muted)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}

// MARK: - Segmented control

private struct SegmentedControl: View {
    var options: [String]
    @Binding var selection: String
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 3) {
            ForEach(options, id: \.self) { option in
                let selected = option == selection
                Text(option)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(selected ? Color(hex: 0x05120F) : Palette.muted)
                    .padding(.horizontal, 11).padding(.vertical, 5)
                    .background {
                        if selected {
                            Capsule().fill(Palette.aqua)
                                .matchedGeometryEffect(id: "seg", in: ns)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        Haptics.change()
                        withAnimation(Motion.control) { selection = option }
                    }
            }
        }
        .padding(3)
        .background(Color.white.opacity(0.06), in: Capsule())
    }
}
