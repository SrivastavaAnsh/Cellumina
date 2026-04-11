//
//  ContentView.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 4/5/26.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("MyTabViewCustomization")
    private var customization: TabViewCustomization
    
    var body: some View {
        TabView {
            Tab("Explorer", systemImage: "eye") {
                CellExplorerView()
            }
            .customizationID("Tab.explorer")
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)        // tab is not customizable in sidebar & tabbar
            
            Tab("Amoeba", systemImage: "aqi.medium") {
                AmoebaLabView()
            }
            .customizationID("Tab.amoeba")
//            .defaultVisibility(.hidden, for: .tabBar)          // hide tab from tabbar
            
            
            Tab("Network", systemImage: "point.3.connected.trianglepath.dotted") {
                CellNetworkView()
            }
            .customizationID("Tab.network")
            
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
        .tabViewSidebarBottomBar {
            Text("🏆 WWDC26 SSC Winner")
        }
    }
}

#Preview {
    ContentView()
}
