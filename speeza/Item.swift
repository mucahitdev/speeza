//
//  Item.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
