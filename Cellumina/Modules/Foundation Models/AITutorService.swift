//
//  AITutorService.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 15/02/26.
//


import Foundation
import UIKit

#if canImport(FoundationModels)
import FoundationModels
import Combine
#endif

@MainActor
final class AITutorService: ObservableObject {

    enum AIError: Error, LocalizedError {
        case unavailable
        case failed(String)

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "Apple Foundation Models are not available on this OS/device."
            case .failed(let msg):
                return msg
            }
        }
    }

    // MARK: - Prompts for animal, plant and bacterial cell
    func cellSummary(for cell: ExplorerCellType) async throws -> String {
        let prompt = """
        You are a biology tutor inside an educational iPad app.
        Write a clear, student-friendly summary of a \(cell.title).

        Requirements:
        - Keep it concise but useful (8-12 bullet points max).
        - Explain: what it is, what it does, what makes it unique.
        - Mention key organelles/structures relevant to this cell type.
        - No markdown headings. Use simple bullets.
        - Tone: helpful, confident, not cheesy.
        """
        return try await generateText(prompt: prompt)
    }

    // MARK: - Prompt for organelles
    func organelleSummary(for organelle: ExplorerOrganelleID, in cell: ExplorerCellType) async throws -> String {
        let prompt = """
        You are a biology tutor inside an educational iPad app.
        Explain "\(organelle.displayName)" specifically in the context of a \(cell.title).

        Requirements:
        - 8-10 bullet points.
        - Explain: What it is, what it does, why it matters in THIS cell type.
        - If it’s absent in some cells, clarify that gently.
        - End with 1 short “why you should care” bullet.
        - No markdown headings. Use simple bullets.
        """
        return try await generateText(prompt: prompt)
    }
    
    
    // MARK: - Cell Network Foundation model prompt
    func networkSummary(for mode: SignalType) async throws -> String {
        let prompt = """
        You are a biology tutor inside an educational iPad app.
        Explain \(mode.rawValue) signaling clearly for students.

        Requirements:
        - 8-10 bullet points maximum.
        - Cover: definition, distance/range, how the signal travels, receptor binding, typical examples.
        - Mention 1–2 real-world examples (e.g., insulin for endocrine).
        - Add 1 bullet comparing it to the other two signaling types.
        - No headings. Use simple bullets.
        - Keep it clean, confident, and not cheesy.
        """
        return try await generateText(prompt: prompt)
    }
    
    
    // MARK: - Amoeba Foundation model prompt
    func amoebaSummary(for mode: AmoebaAISummarySheet.Mode) async throws -> String {
        let focus: String = {
            switch mode {
            case .overview: return "overview (what it is, where it lives, key traits) of amoeba"
            case .parts: return "parts and structures (membrane, cytoplasm, nucleus, vacuoles, pseudopodia) of the amoeba"
            case .life: return "life processes (movement, feeding/phagocytosis, digestion, behavior)"
            case .survival: return "survival (osmoregulation/contractile vacuole, reproduction/binary fission, adaptation)"
            }
        }()

        let prompt = """
        You are a biology tutor inside an educational iPad app.
        Write a clear, student-friendly summary of Amoeba focused on: \(focus).

        Requirements:
        - 6–8 bullet points max.
        - Use simple bullets (•).
        - No headings, no markdown.
        - only stick to the points said in the prompt
        - Keep it accurate, crisp, and easy to learn.
        - End with 1 short real-life relevance bullet (“why you should care”).
        """
        return try await generateText(prompt: prompt)
    }

    // MARK: - Core generation
    private func generateText(prompt: String) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let model = SystemLanguageModel(useCase: .general, guardrails: .default)

                switch model.availability {
                case .available:
                    break
                case .unavailable(let reason):
                    throw AIError.failed("System language model unavailable: \(String(describing: reason))")
                }

                let session = LanguageModelSession(model: model)
                let response = try await session.respond(to: Prompt(prompt))
                let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
                if text.isEmpty { throw AIError.failed("Empty response") }
                return prettifyBullets(text)
            } catch {
                throw AIError.failed(error.localizedDescription)
            }
        } else {
            throw AIError.unavailable
        }
        #else
        throw AIError.unavailable
        #endif
    }
    
    
    private func prettifyBullets(_ raw: String) -> String {
        let s = raw.replacingOccurrences(of: "\r\n", with: "\n")
                   .replacingOccurrences(of: "\r", with: "\n")

        let lines = s.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }

        var out: [String] = []
        for line in lines where !line.isEmpty {
            out.append(line)
            if line.hasPrefix("-") || line.hasPrefix("•") {
                out.append("")
            }
        }
        while out.last?.isEmpty == true { out.removeLast() }
        return out.joined(separator: "\n")
    }
}
