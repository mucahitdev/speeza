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
        NavigationStack {
            VStack {
                Form {
                    noteDetailsSection
                    voiceSettingsSection
                    groupSection
                }
                actionButtonsSection
            }
            .navigationTitle("ADD_NOTE")
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
            .alert("ADD_NEW_GROUP", isPresented: $showingAddGroup) {
                TextField("GROUP_NAME", text: $newGroupName)
                
                Button("CANCEL", role: .cancel) {
                    newGroupName = ""
                }
                
                Button("ADD") {
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
                Text("ENTER_GROUP_NAME")
            }
        }
    }
    
    // MARK: - UI Components
    
    // Note Details Section
    private var noteDetailsSection: some View {
        Section(header: Text("NOTE_DETAILS")) {
            ZStack(alignment: .topLeading) {
                if viewModel.text.isEmpty {
                    Text("ENTER_NOTE")
                        .frame(minHeight: 40)
                        .padding(.leading, 8)
                        .foregroundColor(.gray)
                }
                        
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 40)
                    .focused($isTextEditorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            if isTextEditorFocused {
                                Spacer()
                                
                                Button("DONE") {
                                    isTextEditorFocused = false // Hide keyboard
                                }
                            }
                        }
                    }
            }
            .frame(minHeight: 40)
       
            TextField("TITLE", text: $viewModel.title)
        }
    }
    
    // Voice Settings Section
    private var voiceSettingsSection: some View {
        Section(
            header: Text("VOICE_SETTINGS"),
            footer: Group {
                if viewModel.rate < 0.4 || viewModel.rate > 0.6 {
                    Text("RECOMMENDED_SPEECH_RATE")
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
        Picker("LANGUAGE", selection: $viewModel.selectedLanguage) {
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
                Picker("VOICE", selection: $viewModel.selectedVoice) {
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
            Text("GROUP")
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
        Picker("GROUP", selection: $viewModel.selectedGroupID) {
            Text("UNCATEGORIZED").tag(nil as UUID?)
            
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
            title: viewModel.isPlaying ? "STOP" : "PLAY",
            icon: viewModel.isPlaying ? "stop.fill" : "play.fill",
            action: { viewModel.speak() }
        )
        .disabled(viewModel.text.isBlank)
        .opacity(viewModel.text.isBlank ? 0.5 : 1)
    }
    
    // Save Button
    private var saveButton: some View {
        SZButton(
            title: "SAVE",
            icon: "square.and.arrow.down",
            action: {
                viewModel.saveNote(modelContext: modelContext)
                viewModel.text = ""
                viewModel.title = ""
            }
        )
        .disabled(viewModel.text.isBlank)
        .opacity(viewModel.text.isBlank ? 0.5 : 1)
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

#Preview {
    AddNoteView()
        .modelContainer(for: TextNote.self)
        .modelContainer(for: NoteGroup.self)
        .modelContainer(for: LanguagePreference.self)
}
