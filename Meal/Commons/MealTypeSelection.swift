//
//  MealTypeSelection.swift
//  Meal
//
//  Created by Loic D on 25/07/2023.
//

import SwiftUI

struct MealTypeSelection: View {
    @Binding var selectedMealType: MealType
    var body: some View {
        if UIDevice.isIPhone {
            VStack {
                HStack {
                    MealTypeSelector(mealType: .meat, selectedMealType: $selectedMealType)
                    MealTypeSelector(mealType: .vegan, selectedMealType: $selectedMealType)
                }
                HStack {
                    MealTypeSelector(mealType: .other, selectedMealType: $selectedMealType)
                    MealTypeSelector(mealType: .outside, selectedMealType: $selectedMealType)
                }
            }
        } else {
            HStack {
                MealTypeSelector(mealType: .meat, selectedMealType: $selectedMealType)
                MealTypeSelector(mealType: .vegan, selectedMealType: $selectedMealType)
                MealTypeSelector(mealType: .other, selectedMealType: $selectedMealType)
                MealTypeSelector(mealType: .outside, selectedMealType: $selectedMealType)
            }
        }
    }
}

struct MealTypeSelector: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    let mealType: MealType
    @Binding var selectedMealType: MealType
    var isSelected: Bool {
        mealType == selectedMealType
    }
    
    var body: some View {
        Button(action: {
            selectedMealType = mealType
        }, label: {
            ZStack {
                mealType.getColor(userPrefs: userPrefs)
                Text(mealType.getName(userPrefs: userPrefs))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color("WhiteBackgroundColor") : Color("TextColor"))
            }.frame(height: 40).roundedCornerRectangle(padding: 0, cornerRadius: 10).opacity(isSelected ? 1 : 0.5)
        })
    }
}
