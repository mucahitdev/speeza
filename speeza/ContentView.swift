//
//  ContentView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

enum TabScreens: Int {
    case main, quickAccess, settings
}

struct ContentView: View {
    @State private var selectedTab:TabScreens = .main
    @State private var selectedNoteId: UUID? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView(selectedNoteId: $selectedNoteId)
                .tabItem {
                    Label("Text to Speech", systemImage: "text.bubble")
                }
                .tag(TabScreens.main)
            
            QuickAccessView(selectedTab: $selectedTab, selectedNoteId: $selectedNoteId)
                .tabItem {
                    Label("Quick Access", systemImage: "bolt")
                }
                .tag(TabScreens.quickAccess)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabScreens.settings)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TextNote.self, inMemory: false)
}
