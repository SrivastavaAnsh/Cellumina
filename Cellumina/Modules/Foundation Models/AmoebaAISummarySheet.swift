//
//  AmoebaAISummarySheet.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 15/02/26.
//

import SwiftUI

struct AmoebaAISummarySheet: View {

    @Environment(\.dismiss) private var dismiss
    
    @Binding var tab: AmoebaInfoTab

    @StateObject private var ai = AITutorService()
    @StateObject private var speech = SpeechController()
    
    @State private var text: String = ""
    @State private var isLoading: Bool = false
    @State private var errorText: String? = nil
    
    enum Mode: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case parts = "Parts"
        case life = "Life"
        case survival = "Survival"
        var id: String {
            rawValue
        }
    }

    private var accentTintColor: Color {
        tab.accent
    }

    private var aiMode: Mode {
        switch tab {
        case .overview: return .overview
        case .parts: return .parts
        case .life: return .life
        case .survival: return .survival
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    contentCard
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .tint(accentTintColor)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("AI Summary")
                            .font(.headline)
                            .lineLimit(1)

                        Text("Powered by Foundation Models")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                    .tint(accentTintColor)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        speech.stop()
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .tint(accentTintColor)
                }
            }
            .onAppear {
                Task {
                    await refresh()
                }
            }

            .onChange(of: tab) { _, _ in
                Task {
                    await refresh()
                }
            }
        }
        .id(tab)
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Amoeba")
                        .font(.title3.weight(.semibold))
                    Text("AI summary: \(tab.title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    if speech.isSpeaking {
                        speech.stop()
                    } else {
                        speech.speak(text)
                    }
                } label: {
                    Label(
                        speech.isSpeaking ? "Stop" : "Speak",
                        systemImage: speech.isSpeaking ? "stop.fill" : "speaker.wave.2.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentTintColor)
                .disabled(isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Divider()

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Generating…")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } else if let err = errorText {
                VStack(alignment: .leading, spacing: 10) {
                    Text("AI isn’t available right now.")
                        .font(.headline)

                    Text(err)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } else {
                Text(text.isEmpty ? " " : text)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func refresh() async {
        speech.stop()
        errorText = nil
        isLoading = true
        defer { isLoading = false }

        do {
            text = try await ai.amoebaSummary(for: aiMode)
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            errorText = msg
            text = "AI isn’t available right now. \(msg)"
        }
    }
}
