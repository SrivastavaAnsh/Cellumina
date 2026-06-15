//
//  ContentView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 4/5/26.
//

import SwiftUI

enum AppTab: Hashable {
    case explorer
    case amoeba
    case network
    case note(UUID)
    case newNote
}

struct ContentView: View {
    
    @AppStorage("MyTabViewCustomization")
    private var customization: TabViewCustomization
    
    @StateObject private var notesStore = NotesStore()
    @State private var selection: AppTab = .explorer
    @State private var showNewNoteDialog = false
    @State private var newNoteTitle = ""
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Explorer", systemImage: "eye", value: .explorer) {
                CellExplorerView()
            }
//            .customizationID("Tab.explorer")
//            .customizationBehavior(.disabled, for: .sidebar, .tabBar)      // tab is not customizable in sidebar & tabbar
            
            Tab("Amoeba", systemImage: "aqi.medium", value: .amoeba) {
                AmoebaLabView()
            }
//            .customizationID("Tab.amoeba")
//            .defaultVisibility(.hidden, for: .tabBar)                         // to hide tab from tabbar
            
            
            Tab("Network", systemImage: "point.3.connected.trianglepath.dotted", value: .network) {
                CellNetworkView()
            }
//            .customizationID("Tab.network")
            
            TabSection("Notes") {
                ForEach(notesStore.notes) { note in
                    Tab(note.title, systemImage: "pencil.and.outline", value: AppTab.note(note.id)) {
                        NoteEditorView(noteId: note.id)
                            .environmentObject(notesStore)
                    }
//                    .customizationID(note.customizationID)
                }
                
                Tab("New Note", systemImage: "plus", value: .newNote) {
                    Color.clear
                }
            }
//            .customizationID("Tab.collections")
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
        .tabViewSidebarBottomBar {
            Text("🏆 WWDC26 SSC Winner")
                .padding(.bottom)
        }
        .onChange(of: selection) { oldSelection, newSelection in
            if newSelection == .newNote {
                showNewNoteDialog = true
                selection = oldSelection
            }
        }
        .alert("New Note", isPresented: $showNewNoteDialog) {
            TextField("Note Title", text: $newNoteTitle)
            Button("Create") {
                if !newNoteTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    let newId = notesStore.addNote(title: newNoteTitle.trimmingCharacters(in: .whitespaces))
                    selection = .note(newId)
                    newNoteTitle = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newNoteTitle = ""
            }
        }
    }
}

#Preview {
    ContentView()
}
