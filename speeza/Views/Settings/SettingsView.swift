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
                Section(header: Text("VOICE_SETTINGS")) {
                    NavigationLink(destination: VoiceSettingsView()) {
                        VStack {
                            HStack {
                                Text("VOICE_LANGUAGE_SETTINGS")
                            }
                        }
                    }
                }
                
                Section(header: Text("APP_INFO")) {
                    HStack {
                        Text("VERSION")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("BUILD")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("SUPPORT")) {
                    Button {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6743993564?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("RATE_APP", systemImage: "star.fill")
                            .foregroundColor(Color("szPrimaryColor"))
                    }
                    
                    Button {
                        showingMailComposer = true
                    } label: {
                        Label("CONTACT_US", systemImage: "envelope.fill")
                            .foregroundColor(Color("szPrimaryColor"))
                    }
                }
                
                HStack(alignment: .center) {
                    Button {
                        isIntroCompleted = false
                    } label: {
                        Label(
                            "Reset Intro",
                            systemImage: "arrow.counterclockwise"
                        )
                    }
                }
                .hSpacing(.center)
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
