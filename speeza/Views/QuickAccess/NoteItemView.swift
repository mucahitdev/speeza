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
        VStack(alignment: .leading, spacing: 6) {
            if !note.title.isEmpty {
                Text(note.title)
                    .font(.headline)
            }

            Text(note.text)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundStyle(.secondary)

            HStack {
                Text("NOTE_LANGUAGE".localized(with: note.language))
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                Button {
                    viewModel.speakNote(note: note)
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
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
            .tint(.gray)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNoteView(note: note)
                .presentationBackground(.regularMaterial)
        }
    }
}
