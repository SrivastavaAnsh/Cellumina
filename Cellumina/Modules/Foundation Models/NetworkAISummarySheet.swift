//
//  NetworkAISummarySheet.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 15/02/26.
//


import SwiftUI

struct NetworkAISummarySheet: View {

    let mode: SignalType

    @Environment(\.dismiss) private var dismiss

    @StateObject private var ai = AITutorService()
    @StateObject private var speech = SpeechController()

    @State private var text: String = ""
    @State private var isLoading: Bool = false
    @State private var errorText: String? = nil

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
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
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
                    .tint(tintColor)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Haptics.tap()
                        speech.stop()
                        dismiss()
                    }
                    .tint(tintColor)
                }
            }
            .onAppear {
                Task {
                    await refresh()
                }
            }
        }
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.title3.weight(.semibold))
                    Text("AI summary of \(mode.rawValue) Signaling")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Haptics.tap()
                    if speech.isSpeaking {
                        speech.stop()
                    } else {
                        speech.speak(text)
                    }
                } label: {
                    Label(speech.isSpeaking ? "Stop" : "Speak",
                          systemImage: speech.isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(tintColor)
                .disabled(isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Divider()

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(tintColor)
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

    private var tintColor: Color {
        switch mode {
        case .paracrine: return .blue
        case .autocrine: return .mint
        case .endocrine: return .cyan
        }
    }

    private func refresh() async {
        speech.stop()
        errorText = nil
        isLoading = true
        defer { isLoading = false }

        do {
            text = try await ai.networkSummary(for: mode)
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            errorText = msg
            text = "AI isn’t available right now. \(msg)"
        }
    }
}

#Preview {
    NetworkAISummarySheet(mode: .paracrine)
}
