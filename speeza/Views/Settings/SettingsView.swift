//
//  SettingsView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LanguagePreference.createdAt) private var languagePreferences: [LanguagePreference]
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Voice Settings")) {
                
                    NavigationLink(destination: VoiceSettingsView()) {
                        VStack {
                            HStack {
                                Text("Voice & Language Settings")
                            }
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Mücahit Kökdemir")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadAvailableLanguages()
                viewModel.loadLanguagePreferences(preferences: languagePreferences)
            }
            .onChange(of: languagePreferences) { _, newPreferences in
                viewModel.loadLanguagePreferences(preferences: newPreferences)
            }
        }
    }
} 
