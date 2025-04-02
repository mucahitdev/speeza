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
            Section(header: Text("VOICE_SETTINGS")) {
                Text("AVAILABLE_LANGUAGES".localized(with: viewModel.availableLanguages.count))
                
                // Dil seçimi
                Picker("LANGUAGE", selection: $viewModel.selectedLanguage) {
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
                    Text("AVAILABLE_VOICES".localized(with: voices.count))
                    
                    Picker("VOICE", selection: $viewModel.selectedVoice) {
                        ForEach(voices, id: \.name) { voice in
                            Text(voice.name)
                                .tag(voice.name)
                        }
                    }
                }
            }
            
            Section(header: Text("LANGUAGE_PREFS")) {
                Text("SELECT_LANGUAGES_SHOW")
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
        .navigationTitle("VOICE_SETTINGS")
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
}

// preview

