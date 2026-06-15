//
//  NoteEditorView.swift
//  Cellumina
//

import SwiftUI
import PencilKit

struct NoteEditorView: View {
    @EnvironmentObject var store: NotesStore
    let noteId: UUID
    
    @State private var canvasView = PKCanvasView()
    @State private var hasLoadedDrawing = false
    @State private var showDeleteConfirmation = false
    @State private var showComingSoonAlert = false
    
    private var currentNote: NoteModel? {
        store.notes.first(where: { $0.id == noteId })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let note = currentNote {
                    PencilKitCanvas(canvasView: $canvasView, onSaved: {
                        store.updateNoteDrawing(id: note.id, data: canvasView.drawing.dataRepresentation())
                    })
                    .onAppear {
                        if !hasLoadedDrawing {
                            if !note.drawingData.isEmpty, let drawing = try? PKDrawing(data: note.drawingData) {
                                canvasView.drawing = drawing
                            }
                            hasLoadedDrawing = true
                        }
                        DispatchQueue.main.async {
                            canvasView.becomeFirstResponder()
                        }
                    }
                    .onChange(of: noteId) { _, newId in
                        // When noteId changes, we need to load the new drawing
                        if let newNote = store.notes.first(where: { $0.id == newId }) {
                            if !newNote.drawingData.isEmpty, let drawing = try? PKDrawing(data: newNote.drawingData) {
                                canvasView.drawing = drawing
                            } else {
                                canvasView.drawing = PKDrawing()
                            }
                        }
                    }
                } else {
                    Text("Note not found")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(currentNote?.title ?? "Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if currentNote != nil {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showComingSoonAlert = true
                        } label: {
                            Image(systemName: "tablecells")
                        }
                        
                        Button {
                            showComingSoonAlert = true
                        } label: {
                            Image(systemName: "paperclip")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Delete Note", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    store.deleteNote(id: noteId)
                }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
            .alert("Coming Soon", isPresented: $showComingSoonAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This feature is not yet available.")
            }
        }
    }
}
