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
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false

    var body: some View {
        ZStack{
            if isIntroCompleted {
                TabView(selection: $selectedTab) {
                    AddNoteView()
                        .tabItem {
                            Label("ADD_NOTE", systemImage: "text.bubble")
                        }
                        .tag(TabScreens.addNote)
                    
                    QuickAccessView()
                        .tabItem {
                            Label("QUICK_ACCESS", systemImage: "bolt")
                        }
                        .tag(TabScreens.quickAccess)
                    
                    SettingsView()
                        .tabItem {
                            Label("SETTINGS", systemImage: "gear")
                        }
                        .tag(TabScreens.settings)
                }
            } else {
                IntroPageView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.snappy(duration: 0.25,extraBounce: 0), value: isIntroCompleted)
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TextNote.self, inMemory: false)
}
