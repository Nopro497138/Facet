//
//  ScanView.swift
//  Facet
//
//  The scan experience. The user chooses a photo; Facet animates a futuristic
//  scanning sequence (rotating rings, sweeping scan line, depth mesh + landmark
//  overlay) while the real Vision analysis runs, then reveals the result.
//

import SwiftUI
import PhotosUI

struct ScanView: View {
    @Environment(AppRouter.self) private var router
    @Environment(LibraryStore.self) private var library
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var vm = ScanViewModel()
    @State private var pickerItem: PhotosPickerItem?
    @State private var importing = false

    var body: some View {
        ScreenScaffold {
            header

            switch vm.phase {
            case .idle:
                emptyState
            default:
                stage
                progressCard
                if vm.phase == .done { doneActions }
                if case .failed(let message) = vm.phase { failure(message) }
            }
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await importAndScan(item) }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Eyebrow(text: "Neural analysis")
            Text(title)
                .font(.facetTitle(26))
                .foregroundStyle(Palette.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var title: String {
        switch vm.phase {
        case .idle:      return "Scan a face"
        case .scanning:  return "Scanning face"
        case .done:      return vm.analysis?.faceDetected == false ? "No face found" : "Analysis complete"
        case .failed:    return "Couldn't analyse"
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            FaceSubjectView(showMesh: true)
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Palette.iris.opacity(0.25), lineWidth: 1))
                .shadow(color: Palette.aqua.opacity(0.35), radius: 40)
                .padding(.vertical, 12)

            Text("Choose a photo to analyse entirely on-device.")
                .font(.facetBody)
                .foregroundStyle(Palette.text2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: 9) {
                    if importing { ProgressView().tint(Color(hex: 0x04120F)) }
                    else { Image(systemName: "photo.on.rectangle.angled") }
                    Text(importing ? "Preparing…" : "Choose a photo")
                }
                .primaryLabel()
            }
            .disabled(importing)

            PrivacyNote(text: "Facet analyses the photo on your device. Nothing is uploaded, and the image never leaves your iPhone unless you explicitly share it.")
        }
    }

    // MARK: Scanning stage

    private var stage: some View {
        ZStack {
            ScanRings(active: vm.phase == .scanning)
                .frame(width: 300, height: 300)

            ZStack {
                FaceSubjectView(image: vm.selectedImage, showMesh: true,
                                meshOpacity: vm.phase == .scanning ? 1 : 0.85)
                    .frame(width: 190, height: 190)
                    .clipShape(Circle())

                if vm.phase == .scanning {
                    ScanLine().frame(width: 190, height: 190).clipShape(Circle())
                }

                // HUD readouts.
                scanHUD
            }
            .frame(width: 190, height: 190)
            .overlay(Circle().strokeBorder(Palette.iris.opacity(0.25), lineWidth: 1))
            .shadow(color: Palette.aqua.opacity(0.4), radius: 40)
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
    }

    private var scanHUD: some View {
        let mono = Font.facetMono(10)
        return ZStack {
            VStack { HStack { Text("DEPTH").foregroundStyle(Palette.aqua); Spacer(); Text("MESH 2.4k").foregroundStyle(Palette.aqua) }; Spacer() }
            VStack { Spacer(); HStack { Text("68 pts").foregroundStyle(Palette.aqua); Spacer(); Text("IR ok").foregroundStyle(Palette.iris) } }
        }
        .font(mono)
        .padding(10)
        .opacity(vm.phase == .scanning ? 0.85 : 0)
    }

    private var progressCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles").foregroundStyle(Palette.aqua)
                    Text(vm.statusMessage).font(.system(size: 13.5)).foregroundStyle(Palette.text2)
                    Spacer()
                    Text("\(Int(vm.progress * 100))%").font(.facetMono(13)).foregroundStyle(Palette.text)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule().fill(Gradients.spectral)
                            .frame(width: geo.size.width * vm.progress)
                            .shadow(color: Palette.aqua.opacity(0.6), radius: 8)
                    }
                }
                .frame(height: 5)
                .animation(Motion.panel, value: vm.progress)

                VStack(spacing: 9) {
                    ForEach(Array(vm.stepTitles.enumerated()), id: \.offset) { index, step in
                        StepRow(title: step,
                                done: vm.activeStep > index,
                                active: vm.activeStep == index && vm.phase == .scanning,
                                index: index + 1)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var doneActions: some View {
        VStack(spacing: 11) {
            PrimaryButton(title: "View insights", systemImage: "chart.bar.xaxis") {
                router.activeAnalysis = vm.analysis
                router.go(to: .insights)
            }
            GhostButton(title: "View connected sources") {
                router.activeAnalysis = vm.analysis
                router.go(to: .orbit)
            }
        }
    }

    private func failure(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message).font(.facetBody).foregroundStyle(Palette.text2).multilineTextAlignment(.center)
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text("Try another photo").primaryLabel()
            }
        }
    }

    // MARK: Actions

    private func importAndScan(_ item: PhotosPickerItem) async {
        importing = true
        guard let image = await PhotoImporter.load(item) else { importing = false; return }
        importing = false
        await vm.startScan(with: image, into: library, reduceMotion: reduceMotion)
        router.activeAnalysis = vm.analysis
    }
}

// MARK: - Step row

private struct StepRow: View {
    var title: String
    var done: Bool
    var active: Bool
    var index: Int

    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(done ? Palette.aqua.opacity(0.16) : .clear)
                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(active ? Palette.aqua : Palette.hairline, lineWidth: 1))
                    .frame(width: 20, height: 20)
                if done {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(Palette.aqua)
                } else {
                    Text("\(index)").font(.system(size: 11, weight: .medium))
                        .foregroundStyle(active ? Palette.aqua : Palette.faint)
                }
            }
            .shadow(color: active ? Palette.aqua.opacity(0.4) : .clear, radius: 8)

            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(done ? Palette.text2 : (active ? Palette.text : Palette.faint))
            Spacer()
        }
        .animation(Motion.panel, value: done)
        .animation(Motion.panel, value: active)
    }
}

// MARK: - Styled PhotosPicker label

extension View {
    /// Style a label to match `PrimaryButton` (used inside PhotosPicker).
    func primaryLabel() -> some View {
        self
            .font(.system(size: 16.5, weight: .semibold))
            .foregroundStyle(Color(hex: 0x04120F))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Gradients.primaryButton, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Palette.aqua.opacity(0.5), radius: 18, x: 0, y: 10)
    }
}
