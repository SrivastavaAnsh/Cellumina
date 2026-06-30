//
//  AmoebaInfoOverlay.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//

import SwiftUI

struct AmoebaInfoPayload: Equatable, Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String
    
    let overview: [String]
    var structure: [String] = []
    var location: [String] = []
    
    var whatItDoes: [String] = []
    var controlRegulation: [String] = []
    var clinicalRelevance: [String] = []
}

extension AmoebaInfoPayload {
    static let nucleus = AmoebaInfoPayload(
        title: "Nucleus",
        subtitle: "The control center of the amoeba.",
        overview: [
            "Stores DNA (genetic instructions)",
            "Controls metabolism and growth",
            "Coordinates reproduction (binary fission)"
        ],
        structure: [
            "Double membrane envelope",
            "Contains nucleoplasm and chromatin"
        ],
        location: [
            "Usually central, but moves with cytoplasmic streaming"
        ],
        whatItDoes: [
            "Transcribes RNA for protein synthesis",
            "Regulates cell division",
            "Manages cell's response to environmental stress"
        ],
        controlRegulation: [
            "Gene expression is highly regulated",
            "Responds to external signals for movement and feeding"
        ],
        clinicalRelevance: [
            "Some amoebae (like Naegleria fowleri) are pathogens.",
            "Nuclear functions are targets for anti-amoebic drugs.",
            "Studying it helps understand eukaryotic evolution."
        ]
    )

    static let vacuole = AmoebaInfoPayload(
        title: "Contractile Vacuole",
        subtitle: "The amoeba’s water pump.",
        overview: [
            "Collects excess water inside the cell",
            "Pulses to expel water (osmoregulation)",
            "Prevents bursting in freshwater conditions"
        ],
        structure: [
            "Membrane-bound sac",
            "Surrounded by a network of small vesicles and mitochondria"
        ],
        location: [
            "Usually near the posterior end of the moving amoeba"
        ],
        whatItDoes: [
            "Prevents the amoeba from bursting in freshwater environments",
            "Expels metabolic waste (ammonia) along with water"
        ],
        controlRegulation: [
            "Rate of pulsation depends on external osmolarity",
            "Requires continuous ATP from nearby mitochondria"
        ],
        clinicalRelevance: [
            "Crucial for survival of free-living pathogenic amoebae in freshwater before infecting humans.",
            "Not present in parasitic forms inside the human body (isotonic environment)."
        ]
    )

    static let membrane = AmoebaInfoPayload(
        title: "Cell Membrane",
        subtitle: "Flexible boundary that enables morphing and feeding.",
        overview: [
            "Forms pseudopodia for movement",
            "Wraps around food during phagocytosis",
            "Separates internal cell environment from outside"
        ],
        structure: [
            "Phospholipid bilayer with embedded proteins",
            "Coated with a fuzzy layer of glycoproteins (glycocalyx)"
        ],
        location: [
            "Outer surface of the amoeba"
        ],
        whatItDoes: [
            "Engulfs food particles via phagocytosis (forming food vacuoles)",
            "Regulates entry/exit of ions and molecules",
            "Involved in sensing the environment (chemotaxis)"
        ],
        controlRegulation: [
            "Dynamic restructuring driven by the actin-myosin cytoskeleton",
            "Receptor-mediated signaling triggers pseudopod formation"
        ],
        clinicalRelevance: [
            "Membranes of pathogenic amoebae contain virulence factors (lectins) that bind to human host cells.",
            "Target for cell-lysis drugs and immune system attacks."
        ]
    )
}

struct AmoebaOrganelleSheet: View {
    @Environment(\.dismiss) private var dismiss
    let payload: AmoebaInfoPayload
    
    @State private var showCore = true
    @State private var showFunctions = false
    @State private var showRegulation = false
    @State private var showClinical = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    card {
                        DisclosureGroup(isExpanded: $showCore) {
                            subHeading("Overview", color: .blue)
                            bulletListLines(payload.overview, accent: .blue)
                            
                            if !payload.structure.isEmpty {
                                Divider().opacity(0.15)
                                subHeading("Structure", color: .purple)
                                bulletListLines(payload.structure, accent: .purple)
                            }
                            
                            if !payload.location.isEmpty {
                                Divider().opacity(0.15)
                                subHeading("Location", color: .teal)
                                bulletListLines(payload.location, accent: .teal)
                            }
                        } label: {
                            sectionHeader("Core basics", icon: "book.fill", color: .blue)
                        }
                    }
                    
                    if !payload.whatItDoes.isEmpty {
                        card {
                            DisclosureGroup(isExpanded: $showFunctions) {
                                subHeading("Key functions", color: .green)
                                bulletListLines(payload.whatItDoes, accent: .green)
                            } label: {
                                sectionHeader("What it does", icon: "gearshape.2.fill", color: .green)
                            }
                        }
                    }
                    
                    if !payload.controlRegulation.isEmpty {
                        card {
                            DisclosureGroup(isExpanded: $showRegulation) {
                                bulletListLines(payload.controlRegulation, accent: .indigo)
                            } label: {
                                sectionHeader("Control & regulation", icon: "slider.horizontal.3", color: .indigo)
                            }
                        }
                    }
                    
                    if !payload.clinicalRelevance.isEmpty {
                        card(style: .tinted(.red)) {
                            DisclosureGroup(isExpanded: $showClinical) {
                                bulletListLines(payload.clinicalRelevance, accent: .red)
                            } label: {
                                sectionHeader("Clinical relevance", icon: "cross.case.fill", color: .red)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .onChange(of: showCore) { _, _ in Haptics.tap() }
                .onChange(of: showFunctions) { _, _ in Haptics.tap() }
                .onChange(of: showRegulation) { _, _ in Haptics.tap() }
                .onChange(of: showClinical) { _, _ in Haptics.tap() }
            }
            .navigationTitle(payload.title == "How to play" ? "Info" : "Amoeba Part")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { 
                        Haptics.tap()
                        dismiss() 
                    }
                }
            }
        }
        .tint(.pink)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(payload.title)
                .font(.title2.weight(.bold))

            Text(payload.subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func bulletListLines(_ items: [String], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { raw in
                bulletRow(raw, accent: accent)
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
