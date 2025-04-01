//
//  IntroItem.swift
//  Consist
//
//  Created by Mücahit Kökdemir NTT on 23.02.2025.
//

import SwiftUI

struct IntroItem: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
    var description: String
    
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zindex: CGFloat = 0
}

let inroPageItems: [IntroItem] = [
    .init(
        image: "text.bubble.fill",
        title: "Save Your Notes\nEasily",
        description: "Write and save your thoughts\nquickly and efficiently.",
        scale: 1
    ),
    .init(
        image: "speaker.wave.2.circle.fill",
        title: "Listen to Your Notes\nin Any Language",
        description: "Convert your text notes to speech\nin multiple languages.",
        scale: 0.6,
        anchor: .topLeading,
        offset: -70,
        rotation: 30
    ),
    .init(
        image: "globe",
        title: "Multilingual\nSupport",
        description: "Write in one language and\nlisten in another.",
        scale: 0.5,
        anchor: .bottomLeading,
        offset: -60,
        rotation: -35
    ),
    .init(
        image: "list.bullet.circle.fill",
        title: "Organize Your\nNotes",
        description: "Keep your notes organized\nand easily accessible.",
        scale: 0.4,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 160
    ),
    .init(
        image: "lock.circle.fill",
        title: "Local Storage\nSecurity",
        description: "Your notes are securely stored\nlocally on your device.",
        scale: 0.35,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 250
    ),
]
