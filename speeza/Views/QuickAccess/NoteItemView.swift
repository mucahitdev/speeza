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
    @Binding var selectedTab: TabScreens
    @Binding var selectedNoteId: UUID?
    
    var body: some View {
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
                Text("Language: \(note.language)")
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
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                selectedTab = .main
                selectedNoteId = note.id
            } label: {
                Label("Edit", systemImage: "pencil")
                    .background(Color("szPrimaryColor"))
            }
        }
            
            
    }
}
