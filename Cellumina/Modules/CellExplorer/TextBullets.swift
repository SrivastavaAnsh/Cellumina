//
//  TextBullets.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 05/02/26.
//

import Foundation

extension String {
    func strippingStatusEmojis() -> String {
        let markers = ["🔴"]
        var s = self.trimmingCharacters(in: .whitespacesAndNewlines)

        var changed = true
        while changed {
            changed = false
            for m in markers where s.hasPrefix(m) {
                s = String(s.dropFirst(m.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                changed = true
            }
        }
        return s
    }

    func asBullets(maxItems: Int = 6) -> [String] {
        let rawLines = self
            .replacingOccurrences(of: "\r", with: "")
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var items: [String] = []
        for line0 in rawLines {
            let line = line0.strippingStatusEmojis()
            
            if line.hasPrefix("•") || line.hasPrefix("-") {
                let cleaned = line
                    .replacingOccurrences(of: "•", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .strippingStatusEmojis()
                if !cleaned.isEmpty { items.append(cleaned) }
            } else {
                let parts = line
                    .split(separator: ".")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                if parts.count > 1 {
                    items.append(contentsOf: parts.map { "\($0)." }.map { $0.strippingStatusEmojis() })
                } else {
                    if !line.isEmpty { items.append(line) }
                }
            }
        }

        items = items.map { $0.replacingOccurrences(of: "  ", with: " ") }
        if items.count > maxItems { items = Array(items.prefix(maxItems)) }
        return items
    }
}
