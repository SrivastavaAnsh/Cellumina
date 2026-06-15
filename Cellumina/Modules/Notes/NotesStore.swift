//
//  NotesStore.swift
//  Cellumina
//

import Foundation
import Combine

@MainActor
final class NotesStore: ObservableObject {
    @Published var notes: [NoteModel] = [] {
        didSet {
            saveNotes()
        }
    }
    
    private let userDefaultsKey = "com.cellumina.notesStore"
    
    init() {
        loadNotes()
    }
    
    func addNote(title: String) -> UUID {
        let newNote = NoteModel(title: title)
        notes.insert(newNote, at: 0) // Add to the top
        return newNote.id
    }
    
    func updateNoteDrawing(id: UUID, data: Data) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].drawingData = data
    }
    
    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            notes = try JSONDecoder().decode([NoteModel].self, from: data)
        } catch {
            print("Failed to decode notes: \(error)")
        }
    }
    
    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode notes: \(error)")
        }
    }
}
