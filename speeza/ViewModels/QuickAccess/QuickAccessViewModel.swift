//
//  QuickAccessViewModel.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData
import AVFoundation

class QuickAccessViewModel: ObservableObject {
    @Published var recentNotes: [TextNote] = []
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var availableVoices: [AVSpeechSynthesisVoice] = []
    
    init() {
        // Tüm mevcut sesleri yükle
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
    }
    
    func loadRecentNotes(notes: [TextNote]) {
        // Sort notes by updatedAt and take the most recent ones
        recentNotes = Array(notes.sorted(by: { $0.updatedAt > $1.updatedAt }).prefix(5))
    }
    
    func speakNote(note: TextNote) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: note.text)
        
        // Kaydedilen ses adına göre AVSpeechSynthesisVoice nesnesini bul
        if note.voice != "Default" {
            if let voice = availableVoices.first(where: { $0.name == note.voice }) {
                utterance.voice = voice
            } else {
                // Eğer belirtilen ses bulunamazsa, dil kodunu kullan
                utterance.voice = AVSpeechSynthesisVoice(language: note.language)
            }
        } else {
            // Varsayılan ses - sadece dil kodu kullan
            utterance.voice = AVSpeechSynthesisVoice(language: note.language)
        }
        
        utterance.rate = Float(note.rate)
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
} 