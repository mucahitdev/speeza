//
//  NoteItemView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct NoteItemView: View {
    var note: TextNote
    var onDelete: (TextNote) -> Void
    
    @StateObject private var viewModel = QuickAccessViewModel()
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if !note.title.isEmpty {
                    Text(note.title)
                        .font(.headline)
                }
                
                Text(note.text)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("NOTE_LANGUAGE".localized(with: note.language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.speakNote(note: note)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 4)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    onDelete(note)
                } label: {
                    Label("DELETE", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("EDIT", systemImage: "pencil")
                }
                .tint(.blue)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNoteView(note: note)
        }
    }
}
