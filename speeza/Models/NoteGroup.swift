//
//  NoteGroup.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData

@Model
final class NoteGroup {
    var id: UUID
    var name: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
    }
} 