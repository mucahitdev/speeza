//
//  MainView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [TextNote]
    @Query private var groups: [NoteGroup]
    @Query(sort: \LanguagePreference.createdAt) private var languagePreferences: [LanguagePreference]
    
    @StateObject private var viewModel = MainViewModel()
    @State private var newGroupName: String = ""
    @State private var showingAddGroup: Bool = false
    @State private var showingRenameGroup: Bool = false
    @State private var groupToRename: NoteGroup? = nil
    @State private var renameGroupName: String = ""
    
    // Klavye odağını takip etmek için FocusState ekleyelim
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    noteDetailsSection
                    voiceSettingsSection
                    groupSection
                    actionButtonsSection
                }
            }
            .navigationTitle("Text to Speech")
            .toolbar {
                // Burada başka toolbar öğeleri olabilir, ancak klavye toolbar'ını kaldırıyoruz
            }
            .onAppear {
                viewModel.loadVoiceOptions(preferences: languagePreferences)
                viewModel.loadGroups(groups: groups)
            }
            .onChange(of: languagePreferences) { _, newPreferences in
                viewModel.loadVoiceOptions(preferences: newPreferences)
            }
            .onChange(of: groups) { _, newGroups in
                viewModel.loadGroups(groups: newGroups)
            }
            .alert("Add New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                
                Button("Cancel", role: .cancel) {
                    newGroupName = ""
                }
                
                Button("Add") {
                    if !newGroupName.isEmpty {
                        viewModel.createGroup(name: newGroupName, modelContext: modelContext)
                        newGroupName = ""
                    }
                }
            } message: {
                Text("Enter a name for the new group")
            }
            .alert("Rename Group", isPresented: $showingRenameGroup) {
                TextField("Group Name", text: $renameGroupName)
                
                Button("Cancel", role: .cancel) {
                    renameGroupName = ""
                    groupToRename = nil
                }
                
                Button("Rename") {
                    if let group = groupToRename, !renameGroupName.isEmpty {
                        viewModel.renameGroup(group: group, newName: renameGroupName)
                        try? modelContext.save()
                        renameGroupName = ""
                        groupToRename = nil
                    }
                }
            } message: {
                Text("Enter a new name for the group")
            }
        }
    }
    
    // MARK: - UI Components
    
    // Not detayları bölümü
    private var noteDetailsSection: some View {
        Section(header: Text("Note Details")) {
            TextField("Title", text: $viewModel.title)
            
            TextEditor(text: $viewModel.text)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .focused($isTextEditorFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isTextEditorFocused {
                            Spacer() // Sağa yaslamak için spacer ekleyelim
                            
                            Button("Done") {
                                isTextEditorFocused = false // Klavyeyi kapat
                            }
                        }
                    }
                }
        }
    }
    
    // Ses ayarları bölümü
    private var voiceSettingsSection: some View {
        Section(header: Text("Voice Settings")) {
            // Dil seçimi
            languagePicker
            
            // Ses seçimi
            voicePicker
            
            // Hız ayarı
            VStack {
                Text("Speech Rate: \(viewModel.rate, specifier: "%.2f")")
                Slider(value: $viewModel.rate, in: 0.1...1.0, step: 0.05)
            }
        }
    }
    
    // Dil seçimi picker'ı
    private var languagePicker: some View {
        Picker("Language", selection: $viewModel.selectedLanguage) {
            ForEach(viewModel.getEnabledLanguages(), id: \.self) { language in
                Text(getLanguageName(for: language))
                    .tag(language)
            }
        }
        .onChange(of: viewModel.selectedLanguage) { _, _ in
            viewModel.updateVoicesForSelectedLanguage()
        }
    }
    
    // Ses seçimi picker'ı
    private var voicePicker: some View {
        Group {
            if let voices = viewModel.languageToVoicesMap[viewModel.selectedLanguage], !voices.isEmpty {
                Picker("Voice", selection: $viewModel.selectedVoice) {
                    ForEach(voices, id: \.name) { voice in
                        Text(voice.name)
                            .tag(voice.name)
                    }
                }
            }
        }
    }
    
    // Grup bölümü
    private var groupSection: some View {
        Section(header: groupSectionHeader) {
            groupPicker
        }
    }
    
    // Grup bölümü başlığı
    private var groupSectionHeader: some View {
        HStack {
            Text("Group")
            Spacer()
            Button(action: {
                showingAddGroup = true
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
        }
    }
    
    // Grup seçimi picker'ı
    private var groupPicker: some View {
        Picker("Group", selection: $viewModel.selectedGroupID) {
            Text("Uncategorized").tag(nil as UUID?)
            
            ForEach(groups) { group in
                groupPickerRow(for: group)
            }
        }
    }
    
    // Grup seçimi satırı
    private func groupPickerRow(for group: NoteGroup) -> some View {
        Text(group.name).tag(group.id as UUID?)
            .contextMenu {
                Button(action: {
                    showRenameGroup(group: group)
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    viewModel.deleteGroup(group: group, modelContext: modelContext)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
    
    // Aksiyon butonları bölümü
    private var actionButtonsSection: some View {
        Section {
            HStack {
                Spacer()
                playButton
                Spacer()
                saveButton
                Spacer()
            }
        }
    }
    
    // Oynat/Durdur butonu
    private var playButton: some View {
        Button(action: {
            viewModel.speak()
        }) {
            Label(viewModel.isPlaying ? "Stop" : "Play", systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill")
        }
        .buttonStyle(.borderedProminent)
    }
    
    // Kaydet butonu
    private var saveButton: some View {
        Button(action: {
            viewModel.saveNote(modelContext: modelContext)
            viewModel.text = ""
            viewModel.title = ""
        }) {
            Label("Save", systemImage: "square.and.arrow.down")
        }
        .buttonStyle(.borderedProminent)
    }
    
    // Grup adını değiştirme işlemini başlat
    func showRenameGroup(group: NoteGroup) {
        groupToRename = group
        renameGroupName = group.name
        showingRenameGroup = true
    }
    
    // Dil kodundan dil adını elde etmek için yardımcı fonksiyon
    func getLanguageName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        if let languageName = locale.localizedString(forLanguageCode: languageCode) {
            return "\(languageName) (\(languageCode))"
        }
        return languageCode
    }
} 