//
//  SettingsView.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 3.03.2025.
//

import SwiftUI
import SwiftData
import AVFoundation

struct SettingsView: View {
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
                
                //                Section(header: Text("About")) {
                //                   
                //                }
                
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
        
        }
    }
} 

#Preview {
    SettingsView()
}
