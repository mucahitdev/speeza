//
//  ContentView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData

enum TabScreens: Int {
    case home, settings
}

struct ContentView: View {
    @State private var selectedTab: TabScreens = .home
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false

    var body: some View {
        ZStack {
            if isIntroCompleted {
                TabView(selection: $selectedTab) {
                    Tab("HOME", systemImage: "house", value: .home) {
                        QuickAccessView()
                    }

                    Tab("SETTINGS", systemImage: "gear", value: .settings) {
                        SettingsView()
                    }
                }
                .tint(.primary)
                .tabViewStyle(.tabBarOnly)
            } else {
                IntroPageView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.snappy(duration: 0.25, extraBounce: 0), value: isIntroCompleted)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TextNote.self, inMemory: false)
}
