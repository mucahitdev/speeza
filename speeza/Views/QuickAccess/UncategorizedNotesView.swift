//
//  UncategorizedNotesView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct UncategorizedNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [TextNote]
    
    var filteredNotes: [TextNote] {
        return notes.filter { $0.groupID == nil }
    }
    
    var body: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteItemView(note: note, onDelete: deleteNote)
            }
        }
        .navigationTitle("Uncategorized Notes")
    }
    
    private func deleteNote(_ note: TextNote) {
        modelContext.delete(note)
        try? modelContext.save()
    }
} 