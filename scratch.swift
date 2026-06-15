import SwiftUI

enum AppTab: Hashable {
    case home
    case note(UUID)
    case newNote
}

@available(iOS 18.0, macOS 15.0, *)
struct TestView: View {
    @State private var selection: AppTab = .home
    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: .home) { Text("Home") }
            TabSection("Notes") {
                Tab("Note 1", systemImage: "note", value: AppTab.note(UUID())) { Text("1") }
                Tab("New Note", systemImage: "plus", value: .newNote) { Color.clear }
            }
        }
        .onChange(of: selection) { old, new in
            if new == .newNote { selection = old }
        }
    }
}
