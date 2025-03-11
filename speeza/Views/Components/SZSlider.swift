//
//  SZSlider.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 11.03.2025.
//

import SwiftUI

struct SZSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var title: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: $value,
                in: range,
                step: step
            )
            .tint(Color("szPrimaryColor"))
            .onChange(of: value) { _, _ in
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}

#Preview {
    VStack {
        SZSlider(
            value: .constant(0.5),
            range: 0.1...1.0,
            step: 0.05,
            title: "Speech Rate: 0.50"
        )
        .padding()
        
        SZSlider(
            value: .constant(0.7),
            range: 0...1,
            step: 0.1
        )
        .padding()
    }
} 
