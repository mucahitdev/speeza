//
//  SettingsViewModel.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData
import AVFoundation

class SettingsViewModel: ObservableObject {
    @Published var availableLanguages: [String] = []
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    
    // Dil tercihleri için değişkenler
    @Published var languagePreferences: [LanguagePreference] = []
    @Published var languageToVoicesMap: [String: [AVSpeechSynthesisVoice]] = [:]
    
    // Kullanıcı seçimleri için değişkenler
    @Published var selectedLanguage: String = ""
    @Published var selectedVoice: String = ""
    
    func loadAvailableLanguages() {
        // Tüm mevcut sesleri al
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Dilleri çıkar ve sırala
        let languages = voices.map { $0.language }
        availableLanguages = Array(Set(languages)).sorted()
        
        // Dil-ses haritasını oluştur
        createLanguageToVoicesMap(voices: voices)
        
        // Tüm sesleri sakla
        availableVoices = voices
        
        // Varsayılan seçimler
        if let firstLanguage = availableLanguages.first {
            selectedLanguage = firstLanguage
            updateVoicesForSelectedLanguage()
        }
    }
    
    func createLanguageToVoicesMap(voices: [AVSpeechSynthesisVoice]) {
        // Her dil için sesleri grupla
        var tempMap: [String: [AVSpeechSynthesisVoice]] = [:]
        
        for voice in voices {
            let language = voice.language
            
            if tempMap[language] == nil {
                tempMap[language] = []
            }
            
            tempMap[language]?.append(voice)
        }
        
        // Sesleri sırala
        for (language, voices) in tempMap {
            languageToVoicesMap[language] = voices.sorted(by: { $0.name < $1.name })
        }
    }
    
    func updateVoicesForSelectedLanguage() {
        // Seçilen dil için mevcut sesleri güncelle
        if let voices = languageToVoicesMap[selectedLanguage], !voices.isEmpty {
            selectedVoice = voices.first?.name ?? "Default"
        } else {
            selectedVoice = "Default"
        }
    }
    
    // Dil tercihlerini yükle
    func loadLanguagePreferences(preferences: [LanguagePreference]) {
        // Önce mevcut tercihleri temizle
        self.languagePreferences.removeAll()
        
        // Sonra yeni tercihleri ekle
        self.languagePreferences = preferences
        
        // Eğer mevcut diller için tercih yoksa, varsayılan olarak etkinleştir
        for language in availableLanguages {
            if !languagePreferences.contains(where: { $0.languageCode == language }) {
                let newPreference = LanguagePreference(languageCode: language, isEnabled: true)
                languagePreferences.append(newPreference)
            }
        }
        
        // Değişiklikleri bildir
        objectWillChange.send()
    }
    
    // Dil tercihini güncelle
    func updateLanguagePreference(languageCode: String, isEnabled: Bool, modelContext: ModelContext) {
        if let preference = languagePreferences.first(where: { $0.languageCode == languageCode }) {
            // Mevcut tercihi güncelle
            preference.isEnabled = isEnabled
        } else {
            // Yeni tercih oluştur
            let newPreference = LanguagePreference(languageCode: languageCode, isEnabled: isEnabled)
            languagePreferences.append(newPreference)
            modelContext.insert(newPreference)
        }
    }
    
    // Etkin dilleri getir
    func getEnabledLanguages() -> [String] {
        return languagePreferences
            .filter { $0.isEnabled }
            .map { $0.languageCode }
    }
} 