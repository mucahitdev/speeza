//
//  QuickAccessView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct QuickAccessView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [TextNote]
    @Query private var groups: [NoteGroup]
    
    @StateObject private var viewModel = QuickAccessViewModel()
    @StateObject private var groupViewModel = GroupManagementViewModel()
    @State private var showingRenameGroup: Bool = false
    @State private var groupToRename: NoteGroup? = nil
    @State private var renameGroupName: String = ""
    @State private var showingDeleteConfirmation: Bool = false
    @State private var groupToDelete: NoteGroup? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "NO_SAVED_NOTES",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("SAVED_NOTES_QUICK_ACCESS")
                    )
                } else {
                    List {
                        Section(header: Text("RECENT_NOTES")) {
                            ForEach(viewModel.recentNotes) { note in
                                NoteItemView(note: note, onDelete: deleteNote)
                            }
                        }
                        
                        Section(header: Text("GROUPS")) {
                            NavigationLink(destination: UncategorizedNotesView()) {
                                HStack {
                                    Image(systemName: "tray")
                                        .foregroundColor(.gray)
                                    Text("UNCATEGORIZED")
                                }
                            }
                            
                            ForEach(groups) { group in
                                NavigationLink(destination: GroupDetailView(group: group)) {
                                    HStack {
                                        Image(systemName: "folder")
                                            .foregroundColor(.blue)
                                        Text(group.name)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        // Grubun boş olup olmadığını kontrol et
                                        if groupViewModel.isGroupEmpty(group: group, notes: notes) {
                                            // Grup boşsa direkt sil
                                            groupViewModel.deleteGroup(group, notes: notes, deleteNotes: false, modelContext: modelContext)
                                        } else {
                                            // Grup içinde not varsa onay iste
                                            groupToDelete = group
                                            showingDeleteConfirmation = true
                                        }
                                    } label: {
                                        Label("DELETE", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        showRenameGroup(group: group)
                                    } label: {
                                        Label("RENAME", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("QUICK_ACCESS")
            .onAppear {
                viewModel.loadRecentNotes(notes: notes)
                groupViewModel.loadGroups(groups: groups)
            }
            .alert("RENAME_GROUP", isPresented: $showingRenameGroup) {
                TextField("GROUP_NAME", text: $renameGroupName)
                
                Button("CANCEL", role: .cancel) {
                    renameGroupName = ""
                    groupToRename = nil
                }
                
                Button("RENAME") {
                    if let group = groupToRename, !renameGroupName.isEmpty {
                        groupViewModel.renameGroup(group: group, newName: renameGroupName, modelContext: modelContext)
                        renameGroupName = ""
                        groupToRename = nil
                    }
                }
            }
            .confirmationDialog(
                "DELETE_GROUP",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("DELETE_GROUP_ONLY", role: .destructive) {
                    if let group = groupToDelete {
                        groupViewModel.deleteGroup(group, notes: notes, deleteNotes: false, modelContext: modelContext)
                        groupToDelete = nil
                    }
                }
                
                Button("DELETE_GROUP_AND_NOTES", role: .destructive) {
                    if let group = groupToDelete {
                        groupViewModel.deleteGroup(group, notes: notes, deleteNotes: true, modelContext: modelContext)
                        groupToDelete = nil
                    }
                }
                
                Button("CANCEL", role: .cancel) {
                    groupToDelete = nil
                }
            } message: {
                if let group = groupToDelete {
                    let noteCount = groupViewModel.getNoteCount(for: group, notes: notes)
                    Text(String(format: NSLocalizedString("GROUP_CONTAINS_NOTES", comment: ""), group.name, noteCount))
            
                        
                } else {
                    Text("Select an option")
                }
            }
        }
    }
    
    private func showRenameGroup(group: NoteGroup) {
        groupToRename = group
        renameGroupName = group.name
        showingRenameGroup = true
    }
    
    private func deleteNote(_ note: TextNote) {
        modelContext.delete(note)
        try? modelContext.save()
        
        viewModel.loadRecentNotes(notes: notes)
    }
} 
