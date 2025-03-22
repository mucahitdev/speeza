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
                        "No Saved Notes",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Your saved notes will appear here for quick access.")
                    )
                } else {
                    List {
                        Section(header: Text("Recent Notes")) {
                            ForEach(viewModel.recentNotes) { note in
                                NoteItemView(note: note, onDelete: deleteNote)
                            }
                        }
                        
                        Section(header: Text("Groups")) {
                            NavigationLink(destination: UncategorizedNotesView()) {
                                HStack {
                                    Image(systemName: "tray")
                                        .foregroundColor(.gray)
                                    Text("Uncategorized")
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
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        showRenameGroup(group: group)
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quick Access")
            .onAppear {
                viewModel.loadRecentNotes(notes: notes)
                groupViewModel.loadGroups(groups: groups)
            }
            .alert("Rename Group", isPresented: $showingRenameGroup) {
                TextField("Group Name", text: $renameGroupName)
                
                Button("Cancel", role: .cancel) {
                    renameGroupName = ""
                    groupToRename = nil
                }
                
                Button("Rename") {
                    if let group = groupToRename, !renameGroupName.isEmpty {
                        groupViewModel.renameGroup(group: group, newName: renameGroupName, modelContext: modelContext)
                        renameGroupName = ""
                        groupToRename = nil
                    }
                }
            } message: {
                Text("Enter a new name for the group")
            }
            .confirmationDialog(
                "Delete Group",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Group Only", role: .destructive) {
                    if let group = groupToDelete {
                        groupViewModel.deleteGroup(group, notes: notes, deleteNotes: false, modelContext: modelContext)
                        groupToDelete = nil
                    }
                }
                
                Button("Delete Group and Notes", role: .destructive) {
                    if let group = groupToDelete {
                        groupViewModel.deleteGroup(group, notes: notes, deleteNotes: true, modelContext: modelContext)
                        groupToDelete = nil
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    groupToDelete = nil
                }
            } message: {
                if let group = groupToDelete {
                    let noteCount = groupViewModel.getNoteCount(for: group, notes: notes)
                    Text("Group '\(group.name)' contains \(noteCount) note\(noteCount == 1 ? "" : "s"). What would you like to do?")
                } else {
                    Text("Select an option")
                }
            }
        }
    }
    
    // Grup adını değiştirme işlemini başlat
    private func showRenameGroup(group: NoteGroup) {
        groupToRename = group
        renameGroupName = group.name
        showingRenameGroup = true
    }
    
    // Not silme fonksiyonu
    private func deleteNote(_ note: TextNote) {
        modelContext.delete(note)
        try? modelContext.save()
        
        // Recent notes listesini güncelle
        viewModel.loadRecentNotes(notes: notes)
    }
} 