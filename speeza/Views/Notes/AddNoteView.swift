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
    @Environment(\.dismiss) private var dismiss
    @Query private var notes: [TextNote]
    @Query private var groups: [NoteGroup]
    @Query(sort: \LanguagePreference.createdAt) private var languagePreferences: [LanguagePreference]

    @StateObject private var viewModel = AddNoteViewModel()
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
            .navigationTitle("ADD_NOTE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") {
                        viewModel.stopSpeaking()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("SAVE") {
                        viewModel.saveNote(modelContext: modelContext)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.text.isBlank)
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
                        viewModel.createGroup(name: newGroupName, modelContext: modelContext)
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
                        .frame(minHeight: 40)
                        .padding(.leading, 8)
                        .foregroundStyle(.tertiary)
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

            Button {
                viewModel.speak()
            } label: {
                Label(
                    viewModel.isPlaying ? "STOP" : "PLAY",
                    systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill"
                )
            }
            .disabled(viewModel.text.isBlank)
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
    AddNoteView()
        .modelContainer(for: TextNote.self)
        .modelContainer(for: NoteGroup.self)
        .modelContainer(for: LanguagePreference.self)
}
