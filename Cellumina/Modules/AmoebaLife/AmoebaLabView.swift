//
//  AmoebaLabView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//

import SwiftUI
import SpriteKit

struct AmoebaLabView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    @State private var scene = AmoebaScene()
    @State private var hud = AmoebaHUDState()

    @State private var showHowToPlay = false
    @State private var infoPayload: AmoebaInfoPayload? = nil

    @State private var showEnergyEmptyAlert = false
    @State private var infoTab: AmoebaInfoTab = .overview

    private let playHeight: CGFloat = 380

    var body: some View {
        GeometryReader { outerGeo in
            let isLandscape = outerGeo.size.width > outerGeo.size.height

            Group {
                if isLandscape {
                    HStack(spacing: 16) {
                        leftPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                        Divider()
                            .opacity(0.25)

                        rightPane
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(width: outerGeo.size.width, height: outerGeo.size.height, alignment: .top)
                } else {
                    VStack(spacing: 14) {
                        header
                            .padding(.top, 10)

                        playBox
                            .frame(height: playHeight)
                            .padding(.horizontal, 16)

                        hudPanel
                            .padding(.horizontal, 16)

                        AmoebaFullInfoSection(tab: $infoTab)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
            .background(Color(.systemBackground))
            .sheet(item: $infoPayload) { payload in
                AmoebaOrganelleSheet(payload: payload)
            }
            .sheet(isPresented: $showHowToPlay) {
                HowToPlaySheet()
            }
            .onAppear {
                scene.setInterfaceStyle(scheme == .dark ? .dark : .light)
            }
            .onChange(of: scheme) { _, newScheme in
                scene.setInterfaceStyle(newScheme == .dark ? .dark : .light)
            }
        }
        .alert("Energy Depleted", isPresented: $showEnergyEmptyAlert) {
            Button("Reset Amoeba") {
                Haptics.tap()
                scene.isPaused = false
                scene.resetRun()
                showEnergyEmptyAlert = false
            }
        } message: {
            Text("Your amoeba ran out of energy.")
        }
    }

    private var leftPane: some View {
        VStack(spacing: 14) {
            header
                .padding(.top, 6)

            playBox
                .frame(height: playHeight)

            hudPanel

            Spacer(minLength: 0)
        }
    }

    private var rightPane: some View {
        AmoebaFullInfoSection(tab: $infoTab)
            .padding(.bottom, 24)
    }

    private var playBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(0.10), lineWidth: 1)
                )

            GeometryReader { geo in
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .onAppear {
                        scene.size = geo.size
                        scene.scaleMode = .resizeFill

                        scene.onHUD = { newHUD in
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.12)) {
                                    self.hud = newHUD
                                }
                            }
                        }

                        scene.onInfo = { payload in
                            DispatchQueue.main.async {
                                Haptics.tap()
                                self.infoPayload = payload
                            }
                        }
                        
                        scene.onEnergyEmpty = {
                            DispatchQueue.main.async {
                                self.showEnergyEmptyAlert = true
                            }
                        }

                        scene.configure(reduceMotion: reduceMotion)
                        scene.setInterfaceStyle(scheme == .dark ? .dark : .light)
                    }
                    .onChange(of: geo.size) { _, newSize in
                        scene.size = newSize
                        scene.onResize(to: newSize)
                    }
                    .onChange(of: reduceMotion) { _, v in
                        scene.setReduceMotion(v)
                    }
            }
            .padding(10)
        }
    }

    private var header: some View {
        HStack {
            Text("Amoeba")
                .font(.largeTitle)
                .bold()

            Spacer()

            Button {
                Haptics.tap()
                showHowToPlay = true
            } label: {
                Image(systemName: "info.circle").font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    private var hudPanel: some View {
        VStack(spacing: 10) {
            VStack(spacing: 8) {
                BarRow(label: "Energy", value: hud.energy, systemImage: "bolt.fill")
                BarRow(label: "Water", value: hud.water, systemImage: "drop.fill")
            }

            HStack {
                Text(hud.phaseTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    Haptics.tap()
                    scene.resetRun()
                } label: {
                    Text("Reset")
                }
                .buttonStyle(.borderedProminent)
                .tint(infoTab.accent)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

private struct BarRow: View {
    let label: String
    let value: CGFloat
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage).frame(width: 18)
            Text(label).frame(width: 60, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.85))
                        .frame(
                            width: max(0, min(geo.size.width, geo.size.width * value)),
                            height: 12
                        )
                }
            }
            .frame(height: 12)

            Text("\(Int(value * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

struct AmoebaHUDState: Equatable {
    var energy: CGFloat = 0.50
    var water: CGFloat = 0.25
    var phaseTitle: String = "Move • Eat • Learn"
}

struct HowToPlaySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.pink.gradient)
                        .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("How to play")
                            .font(.title.bold())
                        Text("Drag in the box to move. Eat bacteria to gain energy.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        instructionRow(icon: "hand.draw.fill", color: .blue, text: "Drag inside the box to move the amoeba.")
                        instructionRow(icon: "bolt.fill", color: .orange, text: "Touch bacteria to engulf them and gain energy.")
                        instructionRow(icon: "info.circle.fill", color: .purple, text: "Tap the nucleus or vacuole for fun facts.")
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

    private func instructionRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}
#Preview {
    AmoebaLabView()
}
