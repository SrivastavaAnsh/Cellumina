//
//  CelluminaApp.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 4/5/26.
//

import SwiftUI

@main
struct CelluminaApp: App {
    @State private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environment(authViewModel)
            } else {
                AuthView()
                    .environment(authViewModel)
            }
        }
    }
}
