//
//  NoteModel.swift
//  Cellumina
//

import Foundation

struct NoteModel: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var drawingData: Data
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, drawingData: Data = Data(), createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.drawingData = drawingData
        self.createdAt = createdAt
    }
}
