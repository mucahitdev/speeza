//
//  SZButton.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 11.03.2025.
//

import SwiftUI

struct SZButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var width: CGFloat = 120
    var height: CGFloat = 40
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.bold)
            }
            .frame(width: width, height: height)
            .background(Color("szPrimaryColor"))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    HStack {
        SZButton(
            title: "Play",
            icon: "play.fill",
            action: {}
        )
        
        SZButton(
            title: "Save",
            icon: "square.and.arrow.down",
            action: {},
            width: 150
        )
    }
    .padding()
} 
