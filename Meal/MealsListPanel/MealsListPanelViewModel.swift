//
//  MealsListPanelViewModel.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import Foundation

class MealsListPanelViewModel: ObservableObject {
    private let data = MealsDataController()
    @Published var meals: MealList
    
    init() {
        meals = data.loadAllMeals()
        
        /*
        meals.append(Meal(id: 102, name: "Tortilla Chips", type: .meat))
        meals.append(Meal(id: 103, name: "Avocado", type: .meat))
        meals.append(Meal(id: 104, name: "Red Cabbage", type: .meat))
        meals.append(Meal(id: 105, name: "Red something", type: .meat))
        meals.append(Meal(id: 106, name: "Red something else", type: .meat))
        meals.append(Meal(id: 107, name: "Red thing with red rice and pasta and butter and lots of other things", type: .meat))
        
        meals.append(Meal(id: 110, name: "Soup", type: .vegan))
         */
    }
}

// Buttons
extension MealsListPanelViewModel {
    func createNewMealWith(name: String, type: MealType) {
        let newMealTmp = Meal(id: data.mealCount + 1, name: name, type: type)
        data.createNewMeal(meal: newMealTmp)
        meals.append(newMealTmp)
    }
    
    func updateMealInfo(meal: Meal) {
        dump(meal)
        meals.updateValue(meal)
        data.updateMeal(meal: meal)
    }
}
