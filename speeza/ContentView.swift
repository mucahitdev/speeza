//
//  ContentView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("Text to Speech", systemImage: "text.bubble")
                }
                .tag(0)
            
            QuickAccessView()
                .tabItem {
                    Label("Quick Access", systemImage: "bolt")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TextNote.self, inMemory: false)
}
