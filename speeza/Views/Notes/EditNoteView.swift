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
    @State private var newGroupName = ""
    @State private var showingAddGroup = false

    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                noteDetailsSection
                voiceSettingsSection
                groupSection
            }
            .navigationTitle("EDIT_NOTE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("UPDATE") {
                        viewModel.updateNote(note, modelContext: modelContext)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.hasChanges || viewModel.text.isBlank)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    if isTextEditorFocused {
                        Spacer()
                        Button("DONE") {
                            isTextEditorFocused = false
                        }
                    }
                }
            }
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

    // MARK: - Sections

    private var noteDetailsSection: some View {
        Section("NOTE_DETAILS") {
            ZStack(alignment: .topLeading) {
                if viewModel.text.isEmpty {
                    Text("ENTER_NOTE")
                        .foregroundStyle(.tertiary)
                        .frame(minHeight: 40)
                        .padding(.leading, 8)
                }

                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 40)
                    .focused($isTextEditorFocused)
            }
            .frame(minHeight: 40)

            TextField("TITLE", text: $viewModel.title)
        }
    }

    private var voiceSettingsSection: some View {
        Section {
            languagePicker
            voicePicker

            SZSlider(
                value: $viewModel.rate,
                range: 0.1...1,
                step: 0.1,
                title: "Speech Rate: \(Int(viewModel.rate * 10))"
            )
            .padding(.vertical, 8)

            HStack {
                Button {
                    viewModel.speak()
                } label: {
                    Label(
                        viewModel.isPlaying ? "STOP" : "PLAY",
                        systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill"
                    )
                }
                .disabled(viewModel.text.isBlank)

                Spacer()

                if viewModel.hasChanges {
                    Button {
                        viewModel.resetChanges()
                    } label: {
                        Label("RESET", systemImage: "arrow.uturn.backward")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("VOICE_SETTINGS")
        } footer: {
            if viewModel.rate < 0.4 || viewModel.rate > 0.6 {
                Text("RECOMMENDED_SPEECH_RATE")
            }
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
            Button {
                showingAddGroup = true
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.primary)
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

    func getLanguageName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        if let languageName = locale.localizedString(forLanguageCode: languageCode) {
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
