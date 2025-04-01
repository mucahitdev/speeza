//
//  IntroPageView.swift
//  Consist
//
//  Created by Mücahit Kökdemir NTT on 23.02.2025.
//

import SwiftUI

struct IntroPageView: View {
    @State private var selectedItem:IntroItem = inroPageItems.first!
    @State private var introItems: [IntroItem] = inroPageItems
    @State private var activeIndex: Int = 0
    
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false
    
    var buttonText: String {
        return selectedItem.id == introItems.last!.id ? "Continue" : "Next"
    }
    
    let themeColor: Color = Color("szPrimaryColor")
        
    var body: some View {
        VStack {
            Button {
                updateItem(isForward: false)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(themeColor.gradient)
                    .contentShape(.rect)
            }
            .padding(.leading, 16)
            .hSpacing(.leading)
            .opacity(selectedItem.id == introItems.first!.id ? 0 : 1)
            
            ZStack {
                ForEach(introItems) { item in
                    AnimatedIconView(item)
                }
            }
            .frame(height: 250)
            .frame(maxHeight: .infinity)
            
            VStack(spacing: 6) {
                /// Progress Indicator View
                HStack(spacing: 4) {
                    ForEach(inroPageItems) { item in
                        Capsule()
                            .fill(item.id == selectedItem.id ? themeColor : .gray)
                            .frame(
                                width: item.id == selectedItem.id ? 20 : 5,
                                height: 5
                            )
                    }
                }
                
                Text(selectedItem.title)
                    .font(.title.bold())
                    .contentTransition(.numericText())
                
                Text(selectedItem.description)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
                
                Button {
                   if selectedItem.id == introItems.last!.id {
                       isIntroCompleted = true
                    }
                    updateItem(isForward: true)
                } label: {
                    Text(buttonText)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .padding(.vertical,12)
                        .background(themeColor.gradient,in: Capsule())
                    
                }
                .padding(.top, 24)
            }
            .multilineTextAlignment(.center)
            .frame(height: 300)
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func AnimatedIconView(_ item: IntroItem) -> some View {
        let isSelected = selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 10)))
            .blendMode(.overlay)
            .frame(width: 120, height: 120)
            .background(themeColor.gradient, in: .rect(cornerRadius: 32))
            .background {
                RoundedRectangle(cornerRadius: 35)
                    .fill(.background)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: 1, y: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: -1, y: -1)
                    .padding(-3)
                    .opacity(selectedItem.id == item.id ? 1 : 0)
                    
            }
            .rotationEffect(.init(degrees: -item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.init(degrees: item.rotation))
            .zIndex(isSelected ? 1 : 0)
            
            
    }
    
    func updateItem(isForward: Bool) {
        guard isForward ?  activeIndex != introItems.count - 1: activeIndex != 0 else { return }
        
        var fromIndex: Int
        
        if isForward {
            activeIndex += 1
            fromIndex = activeIndex - 1
        } else {
            activeIndex -= 1
            fromIndex = activeIndex + 1
        }
        
        for index in introItems.indices {
            introItems[index].zindex = 0
        }
        
        withAnimation(.bouncy(duration: 1)) {
            introItems[fromIndex].scale = introItems[activeIndex].scale
            introItems[fromIndex].rotation = introItems[activeIndex].rotation
            introItems[fromIndex].anchor = introItems[activeIndex].anchor
            introItems[fromIndex].offset = introItems[activeIndex].offset
            
            introItems[activeIndex].scale = 1
            introItems[activeIndex].rotation = .zero
            introItems[activeIndex].anchor = .center
            introItems[activeIndex].offset = .zero
            
            selectedItem = introItems[activeIndex]
        }
            
    }
}

#Preview {
    IntroPageView()
}
