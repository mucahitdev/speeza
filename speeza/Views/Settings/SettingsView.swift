//
//  SettingsView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation
import MessageUI

struct SettingsView: View {
    @State private var showingMailComposer = false
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("VOICE_SETTINGS") {
                    NavigationLink(destination: VoiceSettingsView()) {
                        Label("VOICE_LANGUAGE_SETTINGS", systemImage: "waveform")
                    }
                }

                Section("APP_INFO") {
                    HStack {
                        Text("VERSION")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("BUILD")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("SUPPORT") {
                    Button {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6743993564?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("RATE_APP", systemImage: "star")
                    }
                    .tint(.primary)

                    Button {
                        showingMailComposer = true
                    } label: {
                        Label("CONTACT_US", systemImage: "envelope")
                    }
                    .tint(.primary)
                }

                Section {
                    Button {
                        isIntroCompleted = false
                    } label: {
                        Label("Reset Intro", systemImage: "arrow.counterclockwise")
                    }
                    .tint(.secondary)
                    .hSpacing(.center)
                }
            }
            .navigationTitle("SETTINGS")
            .sheet(isPresented: $showingMailComposer) {
                MailComposeView(emailAddress: "infokoksoft@gmail.com")
            }
        }
    }
}

#Preview {
    SettingsView()
}
