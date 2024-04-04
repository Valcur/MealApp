//
//  MealPicker.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import SwiftUI

struct MealPicker: View {
    @Binding var selectedMeal: Meal
    let mealsList: MealList
    @State var mealType: MealType = .meat
    @State var selection = 0
    var mealsAvailable: [Meal] {
        switch mealType {
        case .meat:
            return mealsList.meatMeals
        case .vegan:
            return mealsList.veganMeals
        case .other:
            return mealsList.otherMeals
        case .outside:
            return mealsList.outsideMeals
        }
    }
    
    var body: some View {
        VStack {
            MealTypeSelection(selectedMealType: $mealType)
            
            Picker("Meals to choose from", selection: $selection) {
                ForEach(0..<mealsAvailable.count, id: \.self) { mealId in
                    Text(mealsAvailable[mealId].name)
                }
            }.textFieldBackground(vPadding: 5)
            .onChange(of: mealsAvailable) { _ in
                selection = mealsAvailable.firstIndex(where: {$0.id == selectedMeal.id}) ?? 0
                if selection >= 0 && selection < mealsAvailable.count {
                    selectedMeal = mealsAvailable[selection]
                }
            }.onAppear() {
                selection = mealsAvailable.firstIndex(where: {$0.id == selectedMeal.id}) ?? 0
                if selection >= 0 && selection < mealsAvailable.count {
                    selectedMeal = mealsAvailable[selection]
                }
            }.onChange(of: selection) { _ in
                if selection >= 0 && selection < mealsAvailable.count {
                    selectedMeal = mealsAvailable[selection]
                }
            }
        }
    }
}
