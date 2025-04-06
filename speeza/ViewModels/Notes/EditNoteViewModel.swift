import Foundation
import SwiftData
import AVFoundation

class EditNoteViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var title: String = ""
    @Published var selectedLanguage: String = "en-US"
    @Published var selectedVoice: String = "Default"
    @Published var rate: Double = 0.5
    @Published var selectedGroupID: UUID?
    @Published var isPlaying: Bool = false
    
    // Original values to track changes
    private var originalText: String = ""
    private var originalTitle: String = ""
    private var originalLanguage: String = "en-US"
    private var originalVoice: String = "Default"
    private var originalRate: Double = 0.5
    private var originalGroupID: UUID?
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var availableVoices: [AVSpeechSynthesisVoice] = []
    @Published var languageToVoicesMap: [String: [AVSpeechSynthesisVoice]] = [:]
    @Published var availableLanguages: [String] = []
    @Published var groups: [NoteGroup] = []
    
    init() {
        setupSpeechSynthesizer()
    }
    
    func loadNote(_ note: TextNote) {
        text = note.text
        title = note.title
        selectedLanguage = note.language
        selectedVoice = note.voice
        rate = note.rate
        selectedGroupID = note.groupID
        
        // Save original values
        originalText = note.text
        originalTitle = note.title
        originalLanguage = note.language
        originalVoice = note.voice
        originalRate = note.rate
        originalGroupID = note.groupID
    }
    
    // Check if any changes were made
    var hasChanges: Bool {
        return text != originalText ||
               title != originalTitle ||
               selectedLanguage != originalLanguage ||
               selectedVoice != originalVoice ||
               rate != originalRate ||
               selectedGroupID != originalGroupID
    }
    
    // Reset changes to original values
    func resetChanges() {
        text = originalText
        title = originalTitle
        selectedLanguage = originalLanguage
        selectedVoice = originalVoice
        rate = originalRate
        selectedGroupID = originalGroupID
    }
    
    private func setupSpeechSynthesizer() {
        speechSynthesizer.delegate = nil
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Dilleri ayarla
        var uniqueLanguages = Set<String>()
        for voice in availableVoices {
            uniqueLanguages.insert(voice.language)
        }
        availableLanguages = Array(uniqueLanguages).sorted()
        
        // Ses haritasını oluştur
        createLanguageToVoicesMap(voices: availableVoices)
        
        // Varsayılan dil için sesleri ayarla
        updateVoicesForSelectedLanguage()
    }
    
    func createLanguageToVoicesMap(voices: [AVSpeechSynthesisVoice]) {
        var tempMap: [String: [AVSpeechSynthesisVoice]] = [:]
        
        for voice in voices {
            let language = voice.language
            if tempMap[language] == nil {
                tempMap[language] = []
            }
            tempMap[language]?.append(voice)
        }
        
        for (language, voices) in tempMap {
            languageToVoicesMap[language] = voices.sorted(by: { $0.name < $1.name })
        }
    }
    
    func updateVoicesForSelectedLanguage() {
        if let voices = languageToVoicesMap[selectedLanguage], !voices.isEmpty {
            selectedVoice = voices.first?.name ?? "Default"
        } else {
            selectedVoice = "Default"
        }
    }
    
    func getEnabledLanguages() -> [String] {
        return availableLanguages
    }
    
    func loadGroups(groups: [NoteGroup]) {
        self.groups = groups.sorted(by: { $0.name < $1.name })
    }
    
    func updateNote(_ note: TextNote, modelContext: ModelContext) {
        note.text = text
        note.title = title
        note.language = selectedLanguage
        note.voice = selectedVoice
        note.rate = rate
        note.groupID = selectedGroupID
        note.updatedAt = Date()
        
        try? modelContext.save()
    }
    
    func speak() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        if selectedVoice != "Default", let voice = availableVoices.first(where: { $0.name == selectedVoice }) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        }
        
        utterance.rate = Float(rate)
        
        currentUtterance = utterance
        speechSynthesizer.speak(utterance)
        isPlaying = true
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
        }
    }
} 
