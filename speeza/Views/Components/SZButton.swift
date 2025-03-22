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
    var isDisabled = false
    var backgroundColor: Color = Color("szPrimaryColor")
    var width: CGFloat = 120
    var height: CGFloat = 40
    let action: () -> Void

    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.bold)
            }
            .frame(width: width, height: height)
            .background(isDisabled ? Color.gray : backgroundColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
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
            width: 150,
            action: {}
        )
    }
    .padding()
} 
