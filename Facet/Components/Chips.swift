//
//  Chips.swift
//  Facet
//
//  Small labelled elements: eyebrow labels, badges, tags, confidence chips and a
//  section header. Kept together because they share the same visual language.
//

import SwiftUI

/// Uppercase, letter-spaced context label.
struct Eyebrow: View {
    var text: String
    var body: some View {
        Text(text).eyebrowStyle()
    }
}

/// A small pill (e.g. "92 quality", "Read-only").
struct Badge: View {
    var text: String
    var tint: Color = Palette.aqua
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 9).padding(.vertical, 4)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 1))
    }
}

/// A smart-tag chip with an accent hash prefix.
struct TagChip: View {
    var text: String
    var body: some View {
        HStack(spacing: 2) {
            Text("#").foregroundStyle(Palette.aqua)
            Text(text).foregroundStyle(Palette.text2)
        }
        .font(.system(size: 12.5, weight: .medium))
        .padding(.horizontal, 12).padding(.vertical, 7)
        .glassCard(cornerRadius: 999, highlight: false)
    }
}

/// A confidence / provenance chip.
struct ConfidenceChip: View {
    var provenance: ResultProvenance
    var body: some View {
        let (text, tint) = style
        return Text(text)
            .font(.facetMono(10.5, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(tint.opacity(0.14), in: Capsule())
    }
    private var style: (String, Color) {
        switch provenance {
        case .similarity(let s):
            let text = "\(Int((s * 100).rounded()))% match"
            return (text, s >= 0.85 ? Palette.aqua : Palette.warn)
        case .userProvided:
            return ("Source: you", Palette.iris)
        }
    }
}

/// A section heading with an optional trailing action.
struct SectionHeader: View {
    var title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.facetHeadline).foregroundStyle(Palette.text)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle) { Haptics.tap(); action() }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Palette.aqua)
            }
        }
    }
}

/// The recurring privacy reassurance note.
struct PrivacyNote: View {
    var symbol: String = "checkmark.shield.fill"
    var text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: symbol)
                .foregroundStyle(Palette.aqua)
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(Palette.text2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.aqua.opacity(0.05), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.aqua.opacity(0.18), lineWidth: 1)
        }
    }
}
