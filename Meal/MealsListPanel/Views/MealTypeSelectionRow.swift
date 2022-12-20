//
//  MealTypeSelectionRow.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
// Stickers by stickers
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
                        EmojiBackground(mealType: mealType, isSelected: isSelected)
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
        
        let mealType: MealType
        let isSelected: Bool
        
        var image: Image {
            switch mealType {
            case .meat:
                return Image("Meat")
            case .vegan:
                return Image("Vegan")
            case .outside:
                return Image("Outside")
            }
        }
        
        var body: some View {
            ZStack(alignment: .trailing) {
                mealType.getColor()
                    .opacity(isSelected ? 1 : 0)
                
                image
                    .resizable()
                    .frame(width: isSelected ? 200 : 100, height: isSelected ? 200 : 100)
                    .offset(x: isSelected ? 50 : -15, y: isSelected ? 30 : 0)
            }.frame(height: 120)
        }
    }
}

