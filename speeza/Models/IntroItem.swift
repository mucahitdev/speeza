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
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zindex: CGFloat = 0
}

let inroPageItems: [IntroItem] = [
    .init(
        image: "text.bubble.fill",
        title: "INTRO_TITLE_1",
        description: "INTRO_DESCRIPTION_1",
        scale: 1
    ),
    .init(
        image: "speaker.wave.2.circle.fill",
        title: "INTRO_TITLE_2",
        description: "INTRO_DESCRIPTION_2",
        scale: 0.6,
        anchor: .topLeading,
        offset: -70,
        rotation: 30
    ),
    .init(
        image: "globe",
        title: "INTRO_TITLE_3",
        description: "INTRO_DESCRIPTION_3",
        scale: 0.5,
        anchor: .bottomLeading,
        offset: -60,
        rotation: -35
    ),
    .init(
        image: "list.bullet.circle.fill",
        title: "INTRO_TITLE_4",
        description: "INTRO_DESCRIPTION_4",
        scale: 0.4,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 160
    ),
    .init(
        image: "lock.circle.fill",
//        title: "Local Storage\nSecurity",
//        description: "Your notes are securely stored\nlocally on your device.",
        title: "INTRO_TITLE_5",
        description: "INTRO_DESCRIPTION_5",
        scale: 0.35,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 250
    ),
]
