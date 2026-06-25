//
//  AmoebaFullInfoSection.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SwiftUI

enum AmoebaInfoTab: Int, CaseIterable, Identifiable {
    case overview, parts, life, survival
    var id: Int {
        rawValue
    }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .parts: return "Parts"
        case .life: return "Life"
        case .survival: return "Survival"
        }
    }

    // cards color
    var accent: Color {
        switch self {
        case .overview: return .blue.opacity(0.80)
        case .parts: return .cyan.opacity(0.80)
        case .life: return .green.opacity(0.80)
        case .survival: return .mint.opacity(0.80)
        }
    }
}

struct AmoebaFullInfoSection: View {

    @Environment(\.colorScheme) private var scheme
    @State private var showAISummary = false

    @Binding var tab: AmoebaInfoTab

    // container color
    private var containerFill: Color {
        scheme == .dark ? Color(.secondarySystemBackground) : Color.white
    }

    private var containerStroke: Color {
        scheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06)
    }

    private var segmentedTint: Color {
        scheme == .dark ? Color.white.opacity(0.14) : Color.gray.opacity(0.35)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("About Amoeba")
                    .font(.title3)
                    .bold()

                Spacer()

                Button {
                    Haptics.tap()
                    showAISummary = true
                } label: {
                    Label("AI Summary", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(tab.accent)
                .controlSize(.small)
            }

            Picker("", selection: $tab) {
                ForEach(AmoebaInfoTab.allCases) { t in
                    Text(t.title).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .tint(segmentedTint)

            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 0)
                        .id("TOP")

                    tabBody
                        .padding(.top, 2)
                        .padding(.bottom, 6)
                }
                .scrollIndicators(.hidden)
                .onChange(of: tab) { _, _ in
                    withAnimation(.easeInOut(duration: 0.30)) {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(containerFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(containerStroke, lineWidth: 1)
        )
        .padding(.vertical, 6)
        .sheet(isPresented: $showAISummary) {
            AmoebaAISummarySheet(tab: $tab)
        }
    }

    // MARK: - Tabs
    @ViewBuilder
    private var tabBody: some View {
        switch tab {
        case .overview:
            overviewView
        case .parts:
            partsView
        case .life:
            lifeView
        case .survival:
            survivalView
        }
    }

    // MARK: - segment's content
    private var overviewView: some View {
        VStack(spacing: 12) {
            card(
                title: "What is an amoeba",
                text: "An amoeba is a single-celled (unicellular) organism found mostly in freshwater. It has no fixed shape and constantly changes form as it moves and feeds."
            )

            card(
                title: "Where it lives",
                bullets: [
                    "Freshwater ponds, lakes, slow streams",
                    "Wet soil and damp surfaces",
                    "Some species can live as parasites"
                ]
            )
        }
    }

    private var partsView: some View {
        VStack(spacing: 12) {
            card(
                title: "Main cell parts",
                bullets: [
                    "Cell membrane: flexible boundary that lets it morph",
                    "Cytoplasm: jelly-like interior where reactions happen",
                    "Nucleus: controls activities and stores DNA",
                    "Food vacuole: stores & digests food",
                    "Contractile vacuole: pumps out extra water (osmoregulation)"
                ]
            )

            card(
                title: "Why no fixed shape?",
                text: "Amoeba doesn’t have a rigid cell wall. Its flexible membrane and flowing cytoplasm let it constantly remodel its shape."
            )
        }
    }

    private var lifeView: some View {
        VStack(spacing: 12) {
            card(
                title: "Movement (Pseudopodia)",
                text: "Amoeba moves by extending pseudopodia (“false feet”). Cytoplasm flows into the extension, pulling the rest of the cell forward."
            )

            card(
                title: "Feeding (Phagocytosis)",
                bullets: [
                    "Surrounds food using pseudopodia",
                    "Forms a food vacuole around it",
                    "Enzymes digest food; nutrients are absorbed"
                ]
            )

            card(
                title: "In the lab",
                bullets: [
                    "Drag inside the box to move the amoeba",
                    "Touch bacteria to engulf it (energy increases)"
                ]
            )
        }
    }

    private var survivalView: some View {
        VStack(spacing: 12) {
            card(
                title: "Osmoregulation (Contractile vacuole)",
                text: "In freshwater, water enters the cell by osmosis. The contractile vacuole collects and expels excess water to prevent bursting."
            )

            card(
                title: "Reproduction (Binary fission)",
                bullets: [
                    "DNA duplicates inside the nucleus",
                    "Nucleus divides & cell splits into two identical daughter amoebas"
                ]
            )

            card(
                title: "Fast facts",
                bullets: [
                    "Single cell performs all life functions",
                    "Respiration & waste removal happen by diffusion",
                    "Most species are harmless; some can be parasitic"
                ]
            )
        }
    }

    private func cardBackground() -> some View {
        let tint = tab.accent

        return ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(scheme == .dark ? Color(.tertiarySystemBackground) : .clear)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.18))
        }
    }

    private func cardStrokeColor() -> Color {
        let tint = tab.accent
        return scheme == .dark ? tint.opacity(0.28) : tint.opacity(0.35)
    }

    // cards for title, title and title, bullets
    private func card(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .bold()
                .foregroundStyle(.primary)

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground())
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cardStrokeColor(), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func card(title: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .bold()
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(bullets.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.primary)
                        Text(bullets[i])
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground())
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cardStrokeColor(), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    AmoebaFullInfoSection(tab: .constant(.overview))
}
