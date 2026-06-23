//
//  ContentView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 4/5/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showProfile = false
    
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
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(UIConstants.accent, UIConstants.card)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(authViewModel.userProfile?.name ?? "Profile")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text("Cellumina Explorer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showProfile) {
                ProfileView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    ContentView()
}
