//
//  GroupDetailView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct GroupDetailView: View {
    var group: NoteGroup
    
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [TextNote]
    @Binding var selectedTab: TabScreens
    @Binding var selectedNoteId: UUID?
    
    var filteredNotes: [TextNote] {
        return notes.filter { $0.groupID == group.id }
    }
    
    var body: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteItemView(note: note, onDelete: deleteNote, selectedTab: $selectedTab, selectedNoteId: $selectedNoteId)
            }
        }
        .navigationTitle(group.name)
    }
    
    private func deleteNote(_ note: TextNote) {
        modelContext.delete(note)
        try? modelContext.save()
    }
} 
