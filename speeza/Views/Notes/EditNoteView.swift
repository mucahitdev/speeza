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
            .navigationTitle("Edit Note")
            .navigationBarItems(
                leading: Button("Cancel") {
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
            .alert("Add New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                
                Button("Cancel", role: .cancel) {
                    newGroupName = ""
                }
                
                Button("Add") {
                    if !newGroupName.isEmpty {
                        let newGroup = NoteGroup(name: newGroupName)
                        modelContext.insert(newGroup)
                        viewModel.selectedGroupID = newGroup.id
                        newGroupName = ""
                    }
                }
            } message: {
                Text("Enter a name for the new group")
            }
        }
    }
    
    // MARK: - UI Components
    
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
                                    isTextEditorFocused = false
                                }
                            }
                        }
                    }
            }
            .frame(minHeight: 40)
            
            TextField("Title", text: $viewModel.title)
        }
    }
    
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
    
    private var voicePicker: some View {
        Group {
            if let voices = viewModel.languageToVoicesMap[viewModel.selectedLanguage],
               !voices.isEmpty {
                Picker("Voice", selection: $viewModel.selectedVoice) {
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
    
    private var groupPicker: some View {
        Picker("Group", selection: $viewModel.selectedGroupID) {
            Text("Uncategorized").tag(nil as UUID?)
            
            ForEach(groups) { group in
                Text(group.name).tag(group.id as UUID?)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Spacer()
            playButton
            updateButton
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    private var playButton: some View {
        SZButton(
            title: viewModel.isPlaying ? "Stop" : "Play",
            icon: viewModel.isPlaying ? "stop.fill" : "play.fill",
            action: { viewModel.speak() }
        )
    }
    
    private var updateButton: some View {
        SZButton(
            title: "Update",
            icon: "square.and.arrow.up",
            action: {
                viewModel.updateNote(note, modelContext: modelContext)
                dismiss()
            }
        )
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
