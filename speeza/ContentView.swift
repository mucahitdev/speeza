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
    case addNote, quickAccess, settings
}
    

struct ContentView: View {
    @State private var selectedTab: TabScreens = .quickAccess
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AddNoteView()
                .tabItem {
                    Label("Add Note", systemImage: "text.bubble")
                }
                .tag(TabScreens.addNote)
            
            QuickAccessView()
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
