//
//  AddNoteView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [TextNote]
    @Query private var groups: [NoteGroup]
    @Query(sort: \LanguagePreference.createdAt) private var languagePreferences: [LanguagePreference]
    
    @StateObject private var viewModel = AddNoteViewModel()
    @State private var newGroupName: String = ""
    @State private var showingAddGroup: Bool = false
    @State private var showingRenameGroup: Bool = false
    @State private var groupToRename: NoteGroup? = nil
    @State private var renameGroupName: String = ""
    
    // Track keyboard focus
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    noteDetailsSection
                    voiceSettingsSection
                    groupSection
                }
                actionButtonsSection
            }
            .navigationTitle("Add Note")
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
                        viewModel
                            .createGroup(
                                name: newGroupName,
                                modelContext: modelContext
                            )
                        newGroupName = ""
                    }
                }
            } message: {
                Text("Enter a name for the new group")
            }
        }
    }
    
    // MARK: - UI Components
    
    // Note Details Section
    private var noteDetailsSection: some View {
        Section(header: Text("Note Details")) {
            ZStack(alignment: .topLeading) {
                if viewModel.text.isEmpty {
                    Text("Enter your note here")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                        
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 40)
                    .focused($isTextEditorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            if isTextEditorFocused {
                                Spacer()
                                
                                Button("Done") {
                                    isTextEditorFocused = false // Hide keyboard
                                }
                            }
                        }
                    }
            }
            .frame(minHeight: 40)
       
            TextField("Title", text: $viewModel.title)
        }
    }
    
    // Voice Settings Section
    private var voiceSettingsSection: some View {
        Section(
            header: Text("Voice Settings"),
            footer: Group {
                if viewModel.rate < 0.4 || viewModel.rate > 0.6 {
                    Text("For a more natural speech experience, we recommend keeping the rate between 4 and 6")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        ) {
            languagePicker
            
            voicePicker
            
            SZSlider(
                value: $viewModel.rate,
                range: 0.1...1,
                step: 0.1,
                title: "Speech Rate: \(Int(viewModel.rate * 10))"
            )
            .padding(.vertical, 8)
        }
    }
    
    // Language Picker
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
    
    // Voice Picker
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
    
    // Group Section
    private var groupSection: some View {
        Section(header: groupSectionHeader) {
            groupPicker
        }
    }
    
    // Group Section Header
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
    
    // Group Picker
    private var groupPicker: some View {
        Picker("Group", selection: $viewModel.selectedGroupID) {
            Text("Uncategorized").tag(nil as UUID?)
            
            ForEach(groups) { group in
                Text(group.name).tag(group.id as UUID?)
            }
        }
    }
    
    // Action Buttons Section
    private var actionButtonsSection: some View {
        HStack {
            Spacer()
            playButton
            Spacer()
            saveButton
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // Play&Stop Button
    private var playButton: some View {
        SZButton(
            title: viewModel.isPlaying ? "Stop" : "Play",
            icon: viewModel.isPlaying ? "stop.fill" : "play.fill",
            action: { viewModel.speak() }
        )
    }
    
    // Save Button
    private var saveButton: some View {
        SZButton(
            title: "Save",
            icon: "square.and.arrow.down",
            action: {
                viewModel.saveNote(modelContext: modelContext)
                viewModel.text = ""
                viewModel.title = ""
            }
        )
    }
    
    // Start renaming group
    func showRenameGroup(group: NoteGroup) {
        groupToRename = group
        renameGroupName = group.name
        showingRenameGroup = true
    }
    
    // Get language name from language code
    func getLanguageName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        if let languageName = locale.localizedString(
            forLanguageCode: languageCode
        ) {
            return "\(languageName) (\(languageCode))"
        }
        return languageCode
    }
} 
