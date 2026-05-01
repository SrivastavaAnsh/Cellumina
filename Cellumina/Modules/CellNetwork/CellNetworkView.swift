//
//  CellNetworkView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 10/02/26.
//

import SwiftUI
import SpriteKit

struct CellNetworkView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State private var mode: SignalType = .paracrine
    @State private var scene = CellNetworkScene()
    
    @State private var overviewExpanded: Bool = true
    @State private var aboutExpanded: Bool = true

    @State private var showAISummary = false

    var body: some View {
        GeometryReader { rootGeo in
            let isLandscape = rootGeo.size.width > rootGeo.size.height

            VStack(spacing: 12) {
                overviewCard(isLandscape: isLandscape)
                    .padding(.horizontal)
                    .padding(.top, 10)

                Picker("", selection: $mode) {
                    ForEach(SignalType.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .tint(modeTint)
                .onChange(of: mode) { _, newMode in
                    scene.setMode(newMode)
                }

                GeometryReader { geo in
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .allowsHitTesting(true)
                        .onAppear {
                            scene.configure()
                            scene.setInterfaceStyle(uiStyle)
                            scene.setMode(mode)
                            scene.updateSize(geo.size)
                        }
                        .onChange(of: geo.size) { _, newSize in
                            scene.updateSize(newSize)
                        }
                        .onChange(of: colorScheme) { _, _ in
                            scene.setInterfaceStyle(uiStyle)
                        }
                }
                .ignoresSafeArea(edges: .bottom)

                aboutCard(isLandscape: isLandscape)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            .navigationTitle("Cell Network")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
            .onAppear {
                applyLandscapeRuleIfNeeded(isLandscape: isLandscape)
            }
            .onChange(of: isLandscape) { _, newValue in
                applyLandscapeRuleIfNeeded(isLandscape: newValue)
            }
        }
    }

    private var uiStyle: UIUserInterfaceStyle {
        colorScheme == .dark ? .dark : .light
    }

    // MARK: - Color
    private var modeTint: Color {
        switch mode {
            case .paracrine: return .blue
            case .autocrine: return .mint
            case .endocrine: return .cyan
        }
    }

    // MARK: - Landscape behavior
    private func applyLandscapeRuleIfNeeded(isLandscape: Bool) {
        guard isLandscape else {
            return
        }
        overviewExpanded = true
        aboutExpanded = false
    }

    private func toggleOverview(isLandscape: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if isLandscape {
                // If opening overview -> close about in landscape
                overviewExpanded.toggle()
                if overviewExpanded {
                    aboutExpanded = false
                }
            } else {
                overviewExpanded.toggle()
            }
        }
    }

    private func toggleAbout(isLandscape: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if isLandscape {
                // If opening about -> close overview
                aboutExpanded.toggle()
                if aboutExpanded { overviewExpanded = false }
            } else {
                aboutExpanded.toggle()
            }
        }
    }

    // MARK: - Cards
    private func overviewCard(isLandscape: Bool) -> some View {
        card {
            Button {
                toggleOverview(isLandscape: isLandscape)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(modeTint.opacity(0.14))
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .foregroundStyle(modeTint)
                    }
                    .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Cell Networking")
                            .font(.title3.weight(.semibold))

                        Text("How cells communicate using signals & receptors")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: overviewExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)

            if overviewExpanded {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    overviewBullet("Cell networking refers to communication between cells through signaling molecules and receptors.")
                    overviewBullet("These signals activate internal pathways that allow cells to coordinate functions like gene expression, metabolism, movement, and collective responses.")
                    overviewBullet("This communication happens through paracrine, autocrine, and endocrine signaling.")
                }

                Divider()

                HStack(spacing: 10) {
                    Image(systemName: "arrow.right.arrow.left")
                        .foregroundStyle(modeTint)
                    Text("Flow: Signal → Receptor → Cascade → Response")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary.opacity(0.6))
                }
            }
        }
    }

    private func aboutCard(isLandscape: Bool) -> some View {
        card {
            Button {
                toggleAbout(isLandscape: isLandscape)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(modeTint.opacity(0.14))
                        Image(systemName: "sparkles")
                            .foregroundStyle(modeTint)
                    }
                    .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("About")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(mode.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        showAISummary = true
                    } label: {
                        Label("AI Summary", systemImage: "sparkles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .tint(modeTint)
                    .controlSize(.small)

                    Image(systemName: aboutExpanded ? "chevron.down" : "chevron.up")
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)

            if aboutExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(modeAboutBullets, id: \.self) { line in
                        bullet(line)
                    }
                }
                .font(.callout)
                .foregroundStyle(.primary)

                Divider()

                Text("What you’re seeing:")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(modeTint)

                VStack(alignment: .leading, spacing: 8) {
                    bullet("Tap a signal cell → it releases ligand particles(signals).")
                    bullet(modeVisualExplainerLine2)
                    bullet("When a ligand hits a receptor → receptor glows & the nucleus activates.")
                }
                .font(.callout)
                .foregroundStyle(.primary)

                Divider()

                Text(scene.modeHelpText(for: mode))
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.7))
            }
        }
        .sheet(isPresented: $showAISummary) {
            NetworkAISummarySheet(mode: mode)
        }
    }

    private var modeVisualExplainerLine2: String {
        switch mode {
        case .paracrine:
            return "Signals drift toward a nearby cell and bind its membrane receptors."
        case .autocrine:
            return "Signals loop back and bind receptors on the same cell."
        case .endocrine:
            return "Signals enter the vessel lane, travel across, then reach a distant target cell."
        }
    }

    private var modeAboutBullets: [String] {
        switch mode {
        case .paracrine:
            return [
                "Paracrine signaling is local messaging. It is a cell that releases signals that affect nearby cells.",
                "Signals diffuse through extracellular fluid and break down quickly, so the effect stays short-range.",
                "Best for fast tissue coordination like wound healing, inflammation, and development."
            ]

        case .autocrine:
            return [
                "Autocrine signaling is self-messaging. It is a cell that releases signals and also has receptors for it.",
                "Creates a feedback loop that can amplify or stabilize a response (common in immune signaling).",
                "If the feedback loop isn’t properly controlled, the cell can keep activating itself, which contributes to uncontrolled cell division in some cancers."
            ]

        case .endocrine:
            return [
                "Endocrine signaling is long-distance messaging.",
                "Hormones travel through the bloodstream to reach distant target cells.",
                "Only cells with the correct receptors respond, enabling body-wide control like metabolism and stress response."
            ]
        }
    }

    // MARK: - UI Helpers
    private func card(@ViewBuilder _ content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private func overviewBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.callout.weight(.bold))
                .foregroundStyle(modeTint)
                .padding(.top, 1)

            Text(text)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("•")
                .font(.callout.weight(.bold))
                .foregroundStyle(modeTint.opacity(0.9))

            Text(text)
                .font(.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CellNetworkView()
}
