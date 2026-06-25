//
//  AISummarySheet.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 15/02/26.
//

import SwiftUI

struct AISummarySheet: View {

    enum Mode: String, CaseIterable, Identifiable {
        case cell = "Cell"
        case organelle = "Organelles"
        var id: String {
            rawValue
        }
    }

    let cell: ExplorerCellType

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var ai = AITutorService()
    @StateObject private var speech = SpeechController()

    @State private var text: String = ""
    @State private var isLoading: Bool = false
    @State private var errorText: String? = nil

    @State private var mode: Mode = .cell
    @State private var selectedOrganelle: ExplorerOrganelleID? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    Picker("", selection: $mode) {
                        ForEach(Mode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 6)

                    if mode == .organelle {
                        organellePillRow
                            .padding(.top, 10)
                    }

                    contentCard
                        .padding(.top, mode == .organelle ? 6 : 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color(.systemGroupedBackground))
            .scrollIndicators(.hidden)
            .navigationTitle("")
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
                    .tint(cell.tint)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        speech.stop()
                        dismiss()
                    }
                    .tint(cell.tint)
                }
            }
            .onAppear { Task { await refresh() } }

            .onChange(of: mode) { _, newValue in
                if newValue == .cell { selectedOrganelle = nil }
                Task { await refresh() }
            }

            .onChange(of: selectedOrganelle) { _, _ in
                guard mode == .organelle else {
                    return
                }
                Task { await refresh() }
            }
        }
    }

    // MARK: - organelles
    private var organellePillRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Organelles in this cell")
                .font(.headline)

            if cell.aiOrganelles.isEmpty {
                Text("No organelles available for this cell.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(cell.aiOrganelles, id: \.self) { org in
                            OrganellesPill(
                                title: org.displayName,
                                isSelected: isSelected(org),
                                tint: cell.tint.opacity(0.70)
                            ) {
                                Haptics.tap()
                                withAnimation(.snappy(duration: 0.18)) {
                                    selectedOrganelle = org
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - content card
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleLine)
                        .font(.title3.weight(.semibold))
                    Text(subtitleLine)
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
                    Label(
                        speech.isSpeaking ? "Stop" : "Speak",
                        systemImage: speech.isSpeaking ? "stop.fill" : "speaker.wave.2.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(cell.tint.opacity(0.80))
                .disabled(isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Divider()

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(cell.tint)
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

    // MARK: - Helpers
    private func isSelected(_ org: ExplorerOrganelleID) -> Bool {
        mode == .organelle && selectedOrganelle == org
    }

    private var titleLine: String {
        switch mode {
        case .cell:
            return cell.title
        case .organelle:
            return selectedOrganelle?.displayName ?? "Pick an organelle"
        }
    }
    
    private var subtitleLine: String {
        switch mode {
        case .cell:
            return "AI summary of \(cell.title)"
        case .organelle:
            return "AI summary in context of \(cell.title)"
        }
    }

    private func refresh() async {

        speech.stop()
        errorText = nil

        if mode == .organelle && selectedOrganelle == nil {
            text = "Pick an organelle above to generate its summary."
            isLoading = false
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try Task.checkCancellation()

            let output: String
            switch mode {
            case .cell:
                output = try await ai.cellSummary(for: cell)

            case .organelle:
                guard let org = selectedOrganelle else {
                    return
                }
                output = try await ai.organelleSummary(for: org, in: cell)
            }

            try Task.checkCancellation()
            text = output

        } catch is CancellationError {
            print("Cnacellqation Error, No code needed")
            // no code needed
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            errorText = msg
            text = "AI isn’t available right now. \(msg)"
        }
    }
}

private struct OrganellesPill: View {
    let title: String
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? selectedTextColor : .primary)
        .background {
            Capsule(style: .continuous)
                .fill(isSelected ? tint : Color.primary.opacity(0.06))
        }
        .overlay {
            Capsule(style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: isSelected ? 0 : 1)
        }
    }

    private var selectedTextColor: Color {
        .white
    }
}

#Preview {
    AISummarySheet(cell: .animal)
}
#Preview {
    AISummarySheet(cell: .plant)
}
#Preview {
    AISummarySheet(cell: .bacteria)
}
