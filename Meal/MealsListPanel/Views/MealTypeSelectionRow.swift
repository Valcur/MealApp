//
//  MealTypeSelectionRow.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import SwiftUI

extension MealsListPanel {
    struct MealTypeSelectionRow: View {
        @Binding var selectedMealType: MealType
        
        var body: some View {
            HStack {
                MealTypeSelector(mealType: .meat, selectedMealType: $selectedMealType)
                Spacer()
                    .frame(width: 50)
                MealTypeSelector(mealType: .vegan, selectedMealType: $selectedMealType)
                Spacer()
                    .frame(width: 50)
                MealTypeSelector(mealType: .outside, selectedMealType: $selectedMealType)
            }
        }
    }
    
    struct MealTypeSelector: View {
        let mealType: MealType
        @Binding var selectedMealType: MealType
        var isSelected: Bool {
            mealType == selectedMealType
        }
        
        var body: some View {
            HStack {
                Button(action: {
                    withAnimation(.linear(duration: 0.3)) {
                        selectedMealType = mealType
                    }
                }, label: {
                    ZStack(alignment: .bottomLeading) {
                        mealType.getColor()
                            .opacity(isSelected ? 1 : 0)
                        Image("MealTypeBackground")
                            .resizable()
                            .opacity(isSelected ? 1 : 0)
                        EmojiBackground()
                        Text(mealType.getName())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : mealType.getColor())
                            .padding(15)
                    }
                }).frame(height: 120).roundedCornerRectangle(padding: 0).cornerRadius(20)
            }
        }
    }
    
    struct EmojiBackground: View {
        private var emojis: [Image]
        private var positions: [CGPoint]
        private var sizes: [CGFloat]
        
        init() {
            emojis = [
                Image("Outside_1"),
                Image("Outside_2"),
                Image("Outside_3")
            ]
            positions = [
                CGPoint(x: 110, y: -40),
                CGPoint(x: 300, y: -30),
                CGPoint(x: 220, y: 60)
            ]
            sizes = [
                60,
                40,
                90
            ]
        }
        
        var body: some View {
            ForEach(0..<emojis.count, id: \.self) { i in
                emojis[i]
                    .resizable()
                    .position(x: positions[i].x, y: positions[i].y)
                    .frame(width: sizes[i], height: sizes[i])
            }
        }
    }
}

