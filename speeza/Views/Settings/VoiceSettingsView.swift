//
//  VoiceSettingsView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct VoiceSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LanguagePreference.createdAt) private var languagePreferences: [LanguagePreference]
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Voice Settings")) {
                Text("Available Languages: \(viewModel.availableLanguages.count)")
                
                // Dil seçimi
                Picker("Language", selection: $viewModel.selectedLanguage) {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        Text(getLanguageName(for: language))
                            .tag(language)
                    }
                }
                .onChange(of: viewModel.selectedLanguage) { _, _ in
                    viewModel.updateVoicesForSelectedLanguage()
                }
                
                // Ses seçimi
                if let voices = viewModel.languageToVoicesMap[viewModel.selectedLanguage], !voices.isEmpty {
                    Text("Available Voices: \(voices.count)")
                    
                    Picker("Voice", selection: $viewModel.selectedVoice) {
                        ForEach(voices, id: \.name) { voice in
                            Text(voice.name)
                                .tag(voice.name)
                        }
                    }
                }
                
                // Test butonu
                Button("Test Selected Voice") {
                    testSelectedVoice()
                }
                .disabled(viewModel.selectedVoice.isEmpty)
                
                Button("Refresh Available Languages") {
                    viewModel.loadAvailableLanguages()
                }
            }
            
            Section(header: Text("Language Preferences")) {
                Text("Select languages to show in Text to Speech")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                List {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        HStack {
                            Text(getLanguageName(for: language))
                            
                            Spacer()
                            
                            let isEnabled = Binding(
                                get: {
                                    languagePreferences.first(where: { $0.languageCode == language })?.isEnabled ?? true
                                },
                                set: { newValue in
                                    if let index = languagePreferences.firstIndex(where: { $0.languageCode == language }) {
                                        // Mevcut tercihi güncelle
                                        languagePreferences[index].isEnabled = newValue
                                        try? modelContext.save()
                                    } else {
                                        // Yeni tercih oluştur
                                        let newPreference = LanguagePreference(languageCode: language, isEnabled: newValue)
                                        modelContext.insert(newPreference)
                                        try? modelContext.save()
                                    }
                                }
                            )
                            
                            Toggle("", isOn: isEnabled)
                        }
                    }
                }
            }
        }
        .navigationTitle("Voice Settings")
        .onAppear {
            viewModel.loadAvailableLanguages()
            viewModel.loadLanguagePreferences(preferences: languagePreferences)
        }
        .onChange(of: languagePreferences) { _, newPreferences in
            viewModel.loadLanguagePreferences(preferences: newPreferences)
        }
    }
    
    // Dil kodundan dil adını elde etmek için yardımcı fonksiyon
    func getLanguageName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        if let languageName = locale.localizedString(forLanguageCode: languageCode) {
            return "\(languageName) (\(languageCode))"
        }
        return languageCode
    }
    
    // Seçilen sesi test etmek için fonksiyon
    func testSelectedVoice() {
        if !viewModel.selectedVoice.isEmpty {
            let utterance = AVSpeechUtterance(string: "This is a test for the selected voice.")
            
            // Seçilen ses adına göre AVSpeechSynthesisVoice nesnesini bul
            if let selectedVoice = viewModel.availableVoices.first(where: { $0.name == viewModel.selectedVoice }) {
                utterance.voice = selectedVoice
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
        }
    }
}

// preview

