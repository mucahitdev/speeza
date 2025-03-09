//
//  LanguagePreference.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData

@Model
final class LanguagePreference {
    var id: UUID
    var languageCode: String
    var isEnabled: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        languageCode: String,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.languageCode = languageCode
        self.isEnabled = isEnabled
        self.createdAt = Date()
    }
} 