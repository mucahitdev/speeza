//
//  GroupManagementViewModel.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import Foundation
import SwiftData

class GroupManagementViewModel: ObservableObject {
    @Published var groups: [NoteGroup] = []
    
    // Grupları yükle
    func loadGroups(groups: [NoteGroup]) {
        self.groups = groups.sorted(by: { $0.name < $1.name })
    }
    
    // Grup silme fonksiyonu
    func deleteGroup(_ group: NoteGroup, notes: [TextNote], deleteNotes: Bool, modelContext: ModelContext) {
        // Gruba ait notları bul
        let groupNotes = notes.filter { $0.groupID == group.id }
        
        if deleteNotes {
            // Notları da sil
            for note in groupNotes {
                modelContext.delete(note)
            }
        } else {
            // Notları kategorisiz yap
            for note in groupNotes {
                note.groupID = nil
            }
        }
        
        // Grubu sil
        modelContext.delete(group)
        
        // Değişiklikleri kaydet
        try? modelContext.save()
    }
    
    // Grup adını değiştirme fonksiyonu
    func renameGroup(group: NoteGroup, newName: String, modelContext: ModelContext) {
        group.name = newName
        try? modelContext.save()
    }
    
    // Gruba ait not sayısını hesapla
    func getNoteCount(for group: NoteGroup, notes: [TextNote]) -> Int {
        return notes.filter { $0.groupID == group.id }.count
    }
    
    // Grubun boş olup olmadığını kontrol et
    func isGroupEmpty(group: NoteGroup, notes: [TextNote]) -> Bool {
        return getNoteCount(for: group, notes: notes) == 0
    }
} 