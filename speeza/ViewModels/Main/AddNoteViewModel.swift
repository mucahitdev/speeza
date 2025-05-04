//
//  AddNoteViewModel.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData
import AVFoundation
import SwiftUI

class AddNoteViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var title: String = ""
    @AppStorage("lastSelectedLanguage") var selectedLanguage: String = "en-US" {
        didSet {
            updateVoicesForSelectedLanguage()
        }
    }
    @Published var selectedVoice: String = "Default"
    @Published var rate: Double = 0.5
    @Published var selectedGroupID: UUID? = nil
    
    // Mevcut sesler için değişkenler
    @Published var availableLanguages: [String] = []
    @Published var languageToVoicesMap: [String: [AVSpeechSynthesisVoice]] = [:]
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    
    // Kullanıcı tercihleri
    @Published var enabledLanguages: [String] = []
    
    // Gruplar için değişken
    @Published var groups: [NoteGroup] = []
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    var isPlaying: Bool {
        return speechSynthesizer.isSpeaking
    }
    
    init() {
        // Başlangıçta sadece sesleri yükle, dil tercihleri daha sonra yüklenecek
        loadVoiceOptions()
    }
    
    // MARK: - Voice Options
    
    func loadVoiceOptions(preferences: [LanguagePreference]? = nil) {
        // Tüm mevcut sesleri al
        let voices = AVSpeechSynthesisVoice.speechVoices()
        availableVoices = voices
        
        // Tüm dilleri çıkar ve sırala
        let allLanguages = Array(Set(voices.map { $0.language })).sorted()
        
        // Dil-ses haritasını oluştur (tüm diller için)
        createLanguageToVoicesMap(voices: voices)
        
        // Eğer dil tercihleri verilmişse
        if let preferences = preferences, !preferences.isEmpty {
            // Sadece devre dışı bırakılan dilleri belirle
            let disabledLanguages = preferences
                .filter { !$0.isEnabled }
                .map { $0.languageCode }
            
            // Devre dışı bırakılan dilleri hariç tut, diğer tüm dilleri göster
            availableLanguages = allLanguages.filter { language in
                !disabledLanguages.contains(language)
            }
            
            // Etkin diller, gösterilen dillerdir
            enabledLanguages = availableLanguages
            
            // Eğer seçilen dil etkin değilse, ilk etkin dili seç
            if !enabledLanguages.contains(selectedLanguage), let firstEnabled = enabledLanguages.first {
                selectedLanguage = firstEnabled
            }
        } else {
            // Tercihler verilmemişse, tüm dilleri kullan
            availableLanguages = allLanguages
            enabledLanguages = allLanguages
        }
        
        // Seçilen dil için sesleri güncelle
        updateVoicesForSelectedLanguage()
        
        // Değişiklikleri bildir
        objectWillChange.send()
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
    
    // Etkin dilleri getir
    func getEnabledLanguages() -> [String] {
        return availableLanguages
    }
    
    // MARK: - Group Management
    
    func loadGroups(groups: [NoteGroup]) {
        self.groups = groups.sorted(by: { $0.name < $1.name })
    }
    
    func createGroup(name: String, modelContext: ModelContext) {
        let newGroup = NoteGroup(name: name)
        modelContext.insert(newGroup)
        
        // Yeni grup oluşturulduktan sonra seçili grup olarak ayarla
        selectedGroupID = newGroup.id
    }
    
    func deleteGroup(group: NoteGroup, modelContext: ModelContext) {
        // Eğer silinecek grup şu anda seçili ise, seçimi nil'e çevir
        if selectedGroupID == group.id {
            selectedGroupID = nil
        }
        
        modelContext.delete(group)
    }
    
    // Grup adını değiştirme fonksiyonu
    func renameGroup(group: NoteGroup, newName: String) {
        group.name = newName
        objectWillChange.send()
    }
    
    // MARK: - Note Management
    
    func saveNote(modelContext: ModelContext) {
        let newNote = TextNote(
            text: text,
            title: title,
            language: selectedLanguage,
            voice: selectedVoice,
            accent: "", // Artık kullanılmıyor
            rate: rate,
            groupID: selectedGroupID
        )
        
        modelContext.insert(newNote)
    }
    
    // MARK: - Speech Functions
    
    func speak() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Seçilen ses adına göre AVSpeechSynthesisVoice nesnesini bul
        if selectedVoice != "Default", let voice = availableVoices.first(where: { $0.name == selectedVoice }) {
            utterance.voice = voice
        } else {
            // Varsayılan ses - sadece dil kodu kullan
            utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        }
        
        utterance.rate = Float(rate)
        
        currentUtterance = utterance
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func pauseSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    func continueSpeaking() {
        if !speechSynthesizer.isSpeaking {
            speechSynthesizer.continueSpeaking()
        }
    }
} 
