//
//  AmoebaInfoOverlay.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SwiftUI

struct AmoebaInfoPayload: Equatable {
    let title: String
    let subtitle: String
    let bullets: [String]
}

extension AmoebaInfoPayload {
    static let nucleus = AmoebaInfoPayload(
        title: "Nucleus",
        subtitle: "The control center of the amoeba.",
        bullets: [
            "Stores DNA (genetic instructions)",
            "Controls metabolism and growth",
            "Coordinates reproduction (binary fission)"
        ]
    )

    static let vacuole = AmoebaInfoPayload(
        title: "Contractile Vacuole",
        subtitle: "The amoeba’s water pump.",
        bullets: [
            "Collects excess water inside the cell",
            "Pulses to expel water (osmoregulation)",
            "Prevents bursting in freshwater conditions"
        ]
    )

    static let membrane = AmoebaInfoPayload(
        title: "Cell Membrane",
        subtitle: "Flexible boundary that enables morphing and feeding.",
        bullets: [
            "Forms pseudopodia for movement",
            "Wraps around food during phagocytosis",
            "Separates internal cell environment from outside"
        ]
    )
}

struct AmoebaInfoOverlay: View {
    @Environment(\.colorScheme) private var scheme

    @Binding var isPresented: Bool
    let payload: AmoebaInfoPayload?

    private var backdropOpacity: Double {
        scheme == .dark ? 0.55 : 0.25
    }

    private var cardFill: Color {
        scheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }

    private var cardStroke: Color {
        scheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.08)
    }

    private var cardShadow: Color {
        scheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.18)
    }

    var body: some View {
        if isPresented, let payload {
            ZStack {
                Color.black.opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(payload.title)
                            .font(.title3).bold()

                        Spacer()

                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Text(payload.subtitle)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(payload.bullets, id: \.self) { b in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•").bold()
                                Text(b)
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                        .shadow(color: cardShadow, radius: 22, x: 0, y: 10)
                )
                .padding(.horizontal, 16)
                .frame(maxWidth: 560)
                .transition(.scale(scale: 0.98).combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.18), value: isPresented)
        }
    }
}
