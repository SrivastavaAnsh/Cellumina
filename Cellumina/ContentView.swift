//
//  ContentView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 4/5/26.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showProfile = false
    @State private var showCompleteProfile = false
    
    @State private var email: String?
    
    @AppStorage("MyTabViewCustomization")
    private var customization: TabViewCustomization
    
    var body: some View {
        TabView {
            Tab("Explorer", systemImage: "eye") {
                CellExplorerView()
            }
            .customizationID("Tab.explorer")
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)      // tab is not customizable in sidebar & tabbar
            
            Tab("Amoeba", systemImage: "aqi.medium") {
                AmoebaLabView()
            }
            .customizationID("Tab.amoeba")
//            .defaultVisibility(.hidden, for: .tabBar)                         // to hide tab from tabbar
            
            
            Tab("Network", systemImage: "point.3.connected.trianglepath.dotted") {
                CellNetworkView()
            }
            .customizationID("Tab.network")
            
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
        .tabViewSidebarBottomBar {
            Button {
                showProfile.toggle()
            } label: {
                HStack(spacing: 12) {
                    let name = authViewModel.userProfile?.name ?? "Profile"
                    let initials = name.components(separatedBy: .whitespacesAndNewlines)
                        .filter { !$0.isEmpty }
                        .compactMap { $0.first }
                        .prefix(2)
                        .map { String($0) }
                        .joined()
                        .uppercased()
                    
                    ZStack {
                        LinearGradient(
                            colors: [Color.blue.opacity(0.4), Color.indigo.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Text(initials.isEmpty ? "P" : initials)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text(email ?? "Cellumina Explorer")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
        .sheet(isPresented: $showCompleteProfile) {
            CompleteProfileView()
        }
        .onChange(of: authViewModel.userProfile) { oldValue, newValue in
            if let profile = newValue {
                let isIncomplete = (profile.name?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) ||
                                   (profile.phoneNumber?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) ||
                                   (profile.dateOfBirth?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                showCompleteProfile = isIncomplete
            }
        }
        .task {
            if let profile = authViewModel.userProfile {
                let isIncomplete = (profile.name?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) ||
                                   (profile.phoneNumber?.trimmingCharacters(in: .whitespaces).isEmpty ?? true) ||
                                   (profile.dateOfBirth?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                showCompleteProfile = isIncomplete
            }
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                self.email = session.user.email
            } catch {
                print("Could not fetch session email: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
