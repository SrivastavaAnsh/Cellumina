//
//  CellExplorerView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 05/02/26.
//

import SwiftUI
import SpriteKit

struct CellExplorerView: View {
    
    @State private var showRealisticImage: Bool = false

    @State private var selected: ExplorerCellType = .animal
    @State private var segment: ExplorerInfoSegment = .overview

    @State private var scene = CellExplorerScene()
    @State private var selectedOrganelle: ExplorerOrganelle? = nil

    @State private var aiCell: ExplorerCellType? = nil

    private var organelles: [ExplorerOrganelle] {
        ExplorerOrganelle.catalog().filter { $0.onlyIn.contains(selected) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    header

                    cellTypeChooser
                        .padding(.horizontal, UIConstants.pad)

                    GeometryReader { geo in
                        ZStack(alignment: .topTrailing) {
                            if showRealisticImage, let imgName = realisticImageName(for: selected) {
                                Image(imgName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .offset(y: -17)
                                    .clipped()
                                    .allowsHitTesting(false)
                            } else {
                                SpriteView(scene: scene, options: [.allowsTransparency])
                                    .onAppear {
                                        scene.configure()

                                        scene.onOrganelleTapped = { key in
                                            if let hit = organelles.first(where: { $0.id.rawValue == key }) {
                                                selectedOrganelle = hit
                                                return
                                            }
                                            if let fallback = ExplorerOrganelle.catalog().first(where: { $0.id.rawValue == key }),
                                               fallback.onlyIn.contains(selected) {
                                                selectedOrganelle = fallback
                                            }
                                        }
                                        scene.setViewport(size: geo.size)
                                        scene.load(cell: selected)
                                    }
                                    .onChange(of: geo.size) { _, newSize in
                                        scene.setViewport(size: newSize)
                                    }
                            }
                            
                            Button {
                                Haptics.tap()
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    showRealisticImage.toggle()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: showRealisticImage ? "wand.and.sparkles.inverse" : "photo")
                                        .font(.system(size: 20))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(selected.tint.opacity(0.95))
                            .padding(12)
                        }
                    }
                    .frame(height: 420)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.corner, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: UIConstants.corner, style: .continuous)
                            .stroke(UIConstants.stroke, lineWidth: 1)
                    )
                    .shadow(color: UIConstants.shadow, radius: 16, x: 0, y: 10)
                    .padding(.horizontal, UIConstants.pad)
                    .onChange(of: selected) { _, newValue in
                        selectedOrganelle = nil
                        segment = .overview
                        showRealisticImage = false

                        scene.load(cell: newValue)
                    }

                    CellTypeCard(type: selected) {
                        aiCell = selected
                    }
                    .padding(.horizontal, UIConstants.pad)

                    Picker("Info", selection: $segment) {
                        ForEach(ExplorerInfoSegment.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, UIConstants.pad)

                    infoPanel
                        .padding(.horizontal, UIConstants.pad)
                        .padding(.bottom, 18)
                }
                .padding(.top, 10)
            }
//            .navigationTitle("Explorer")
//            .navigationBarTitleDisplayMode(.inline)

            .sheet(item: $selectedOrganelle) { organelle in
                OrganelleSheet(info: organelle, tint: selected.tint)
            }

            .sheet(item: $aiCell) { cell in
                AISummarySheet(cell: cell)
                    .presentationDetents([.large])
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Explorer")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Tap organelles to learn what they do and and why they matter.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, UIConstants.pad)
    }

    // MARK: - Cell Type Chooser
    private var cellTypeChooser: some View {
        HStack(spacing: 12) {
            chooserButton(.animal)
            chooserButton(.plant)
            chooserButton(.bacteria)
        }
    }
    
    private func realisticImageName(for type: ExplorerCellType) -> String? {
        switch type {
        case .animal: return "animalCell"
        case .plant: return "plantCell"
        case .bacteria: return "bacterialCell"
        }
    }

    private func chooserButton(_ type: ExplorerCellType) -> some View {
        Button {
            Haptics.tap()
            selected = type
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(type.shortTitle)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: type.icon)
                        .foregroundStyle(type.tint)
                }
                Text(type.quickLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
            .background(UIConstants.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected == type ? type.tint.opacity(0.6) : UIConstants.stroke,
                            lineWidth: selected == type ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var infoPanel: some View {
        switch segment {
        case .overview:
            OverviewPanel(type: selected)
        case .inside:
            OrganellesPanel(type: selected, organelles: organelles) { tap in
                selectedOrganelle = tap
            }
        case .facts:
            FactsPanel(type: selected)
        }
    }
}

private struct CellTypeCard: View {
    let type: ExplorerCellType
    let onAISummary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.title2)
                        .bold()
                    Text(type.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Haptics.tap()
                    onAISummary()
                } label: {
                    Label("AI Summary", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(type.tint)

                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(type.tint)
                    .padding(.top, 4.5)
            }

            Text(type.longDescription.strippingStatusEmojis())
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(UIConstants.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(UIConstants.stroke, lineWidth: 1)
        )
    }
}

// MARK: - Overview panel
private struct OverviewPanel: View {
    let type: ExplorerCellType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            infoCard(title: "What it is", tint: type.tint.opacity(0.10), titleColor: .pink) {
                bulletText(type.whatItIs.strippingStatusEmojis())
            }

            infoCard(title: "What it does", tint: type.tint.opacity(0.10), titleColor: .green) {
                bulletText(type.whatItDoes.strippingStatusEmojis())
            }

            infoCard(title: "Key systems", tint: type.tint.opacity(0.10), titleColor: .orange) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(type.keySystems, id: \.self) { raw in
                        HStack(alignment: .top, spacing: 10) {
                            Text("•")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(type.tint)
                                .padding(.top, 1)
                            Text(raw.strippingStatusEmojis())
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(UIConstants.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(UIConstants.stroke, lineWidth: 1)
        )
    }

    // MARK: - Building blocks
    private func infoCard(title: String, tint: Color, titleColor: Color, @ViewBuilder content: () -> some View ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(titleColor)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func bulletText(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(text.asBullets(maxItems: 6), id: \.self) { line in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(type.tint)
                        .padding(.top, 1)
                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct OrganellesPanel: View {
    let type: ExplorerCellType
    let organelles: [ExplorerOrganelle]
    let onTap: (ExplorerOrganelle) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tap any organelle below (or in the diagram).")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVStack(spacing: 10) {
                ForEach(organelles) { o in
                    Button {
                        Haptics.tap()
                        onTap(o)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .foregroundStyle(o.id.animationColor(for: type))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(o.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(o.oneLiner.strippingStatusEmojis())
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(UIConstants.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(UIConstants.stroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct FactsPanel: View {
    let type: ExplorerCellType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick facts")
                .font(.headline)
                .foregroundStyle(.teal.opacity(0.95))

            ForEach(type.funFacts, id: \.self) { raw in
                let f = raw.strippingStatusEmojis()
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(type.tint.opacity(0.9))
                        .padding(.top, 1)
                    Text(f)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Organelle Sheet
private struct OrganelleSheet: View {
    let info: ExplorerOrganelle
    let tint: Color
    @Environment(\.dismiss) private var dismiss

    @State private var showCore = true
    @State private var showFunctions = false
    @State private var showRegulation = false
    @State private var showClinical = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    header
                    chipsRow

                    card {
                        DisclosureGroup(isExpanded: $showCore) {

                            subHeading("Overview", color: .blue)
                            bulletLines(info.overview, accent: .blue, maxItems: 5)

                            Divider().opacity(0.15)

                            subHeading("Structure", color: .purple)
                            bulletLines(info.structure, accent: .purple, maxItems: 6)

                            Divider().opacity(0.15)

                            subHeading("Location", color: .teal)
                            bulletLines(info.location, accent: .teal, maxItems: 4)

                            Divider().opacity(0.15)

                        } label: {
                            sectionHeader("Core basics", icon: "book.fill", color: .blue)
                        }
                    }

                    card {
                        DisclosureGroup(isExpanded: $showFunctions) {

                            subHeading("Key functions", color: .green)

                            let merged = info.keyFunctions.prefix(6) + info.interactions.prefix(6)

                            bulletListLines(Array(merged), accent: .green, maxItems: 10)

                        } label: {
                            sectionHeader("What it does", icon: "gearshape.2.fill", color: .green)
                        }
                    }

                    if !info.regulationAndControl.isEmpty {
                        card {
                            DisclosureGroup(isExpanded: $showRegulation) {
                                bulletListLines(info.regulationAndControl, accent: .indigo, maxItems: 6)
                            } label: {
                                sectionHeader("Control & regulation", icon: "slider.horizontal.3", color: .indigo)
                            }
                        }
                    }

                    if !info.clinicalRelevance.isEmpty {
                        card(style: .tinted(.red)) {
                            DisclosureGroup(isExpanded: $showClinical) {
                                bulletListLines(info.clinicalRelevance, accent: .red, maxItems: 6)
                            } label: {
                                sectionHeader("Clinical relevance", icon: "cross.case.fill", color: .red)
                            }
                        }
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .navigationTitle("Organelle")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(tint)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(info.name)
                .font(.title2.weight(.bold))

            Text(info.oneLiner.strippingStatusEmojis())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chipsRow: some View {
        let chips = organelleChips(for: info.id)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.text) { chip in
                    Text(chip.text)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(chip.color.opacity(0.16), in: Capsule())
                        .foregroundStyle(chip.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func organelleChips(for id: ExplorerOrganelleID) -> [(text: String, color: Color)] {
        switch id {
        case .nucleus, .nucleolus:
            return [("Genetics", .blue), ("Control", .purple)]
        case .mitochondrion:
            return [("Energy", .orange), ("Metabolism", .brown)]
        case .ribosome:
            return [("Protein", .green), ("Universal", .teal)]
        case .golgi, .er:
            return [("Transport", .indigo), ("Manufacturing", .purple)]
        case .lysosome:
            return [("Recycling", .yellow), ("Defense", .red)]
        case .chloroplast:
            return [("Photosynthesis", .green), ("Light", .mint)]
        case .vacuole:
            return [("Storage", .cyan), ("Pressure", .teal)]
        case .cellWall:
            return [("Structure", .green), ("Protection", .brown)]
        case .nucleoid, .plasmid:
            return [("Bacterial DNA", .orange), ("Fast Adaptation", .red)]
        case .flagellum, .pili:
            return [("Motility", .brown), ("Attachment", .indigo)]
        }
    }

    private enum CardStyle {
        case normal
        case tinted(Color)
    }

    private func card(style: CardStyle = .normal, @ViewBuilder _ content: () -> some View) -> some View {
        let bg: AnyShapeStyle = {
            switch style {
            case .normal:
                return AnyShapeStyle(.ultraThinMaterial)
            case .tinted(let c):
                return AnyShapeStyle(c.opacity(0.10))
            }
        }()

        return VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(bg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subHeading(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func bulletLines(_ text: String, accent: Color, maxItems: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(text.asBullets(maxItems: maxItems), id: \.self) { line in
                bulletRow(line.strippingStatusEmojis(), accent: accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }

    private func bulletListLines(_ items: [String], accent: Color, maxItems: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.prefix(maxItems), id: \.self) { raw in
                bulletRow(raw.strippingStatusEmojis(), accent: accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }

    private func bulletRow(_ text: String, accent: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(accent.opacity(0.95))
                .padding(.top, 1)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}



