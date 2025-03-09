//
//  TextNote.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData

@Model
final class TextNote {
    var id: UUID
    var text: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var language: String
    var voice: String
    var accent: String
    var rate: Double
    var groupID: UUID?
    
    init(
        id: UUID = UUID(),
        text: String,
        title: String,
        language: String = "en-US",
        voice: String = "Default",
        accent: String = "Default",
        rate: Double = 0.5,
        groupID: UUID? = nil
    ) {
        self.id = id
        self.text = text
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.language = language
        self.voice = voice
        self.accent = accent
        self.rate = rate
        self.groupID = groupID
    }
} 