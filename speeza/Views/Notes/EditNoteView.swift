//
//  EditNoteView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 22.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct EditNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var groups: [NoteGroup]
    
    var note: TextNote
    
    @StateObject private var viewModel = EditNoteViewModel()
    @State private var newGroupName: String = ""
    @State private var showingAddGroup: Bool = false
    
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
            .navigationTitle("EDIT_NOTE")
            .navigationBarItems(
                leading: Button("CANCEL") {
                    dismiss()
                }
            )
            .onAppear {
                viewModel.loadNote(note)
                viewModel.loadGroups(groups: groups)
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
                        let newGroup = NoteGroup(name: newGroupName)
                        modelContext.insert(newGroup)
                        viewModel.selectedGroupID = newGroup.id
                        newGroupName = ""
                    }
                }
            } message: {
                Text("ENTER_GROUP_NAME")
            }
        }
    }
    
    // MARK: - UI Components
    
    private var noteDetailsSection: some View {
        Section(header: Text("NOTE_DETAILS")) {
            ZStack(alignment: .topLeading) {
                if viewModel.text.isEmpty {
                    Text("ENTER_NOTE")
                        .foregroundColor(.gray)
                        .frame(minHeight: 40)
                        .padding(.leading, 8)
                }
                
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 40)
                    .focused($isTextEditorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            if isTextEditorFocused {
                                Spacer()
                                Button("DONE") {
                                    isTextEditorFocused = false
                                }
                            }
                        }
                    }
            }
            .frame(minHeight: 40)
            
            TextField("TITLE", text: $viewModel.title)
        }
    }
    
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
    
    private var voicePicker: some View {
        Group {
            if let voices = viewModel.languageToVoicesMap[viewModel.selectedLanguage],
               !voices.isEmpty {
                Picker("VOICE", selection: $viewModel.selectedVoice) {
                    ForEach(voices, id: \.name) { voice in
                        Text(voice.name)
                            .tag(voice.name)
                    }
                }
            }
        }
    }
    
    private var groupSection: some View {
        Section(header: groupSectionHeader) {
            groupPicker
        }
    }
    
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
    
    private var groupPicker: some View {
        Picker("GROUP", selection: $viewModel.selectedGroupID) {
            Text("UNCATEGORIZED").tag(nil as UUID?)
            
            ForEach(groups) { group in
                Text(group.name).tag(group.id as UUID?)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Spacer()
            playButton
            resetButton
            updateButton
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    private var playButton: some View {
        SZButton(
            title: viewModel.isPlaying ? "STOP" : "PLAY",
            icon: viewModel.isPlaying ? "stop.fill" : "play.fill",
            action: { viewModel.speak() }
        )
        .disabled(viewModel.text.isBlank)
        .opacity(viewModel.text.isBlank ? 0.5 : 1)
    }
    
    private var resetButton: some View {
        Button(action: { viewModel.resetChanges() }) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 20))
                .foregroundColor(viewModel.hasChanges ? Color("szPrimaryColor") : .gray)
        }
        .disabled(!viewModel.hasChanges)
    }
    
    private var updateButton: some View {
        SZButton(
            title: "UPDATE",
            icon: "square.and.arrow.up",
            action: {
                viewModel.updateNote(note, modelContext: modelContext)
                dismiss()
            }
        )
        .disabled(!viewModel.hasChanges || viewModel.text.isBlank)
        .opacity(!viewModel.hasChanges || viewModel.text.isBlank ? 0.5 : 1)
    }
    
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TextNote.self, configurations: config)
    
    let note = TextNote(text: "Sample note", title: "Sample title")
    container.mainContext.insert(note)
    
    return EditNoteView(note: note)
        .modelContainer(container)
}
