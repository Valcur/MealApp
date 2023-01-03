//
//  MealsListPanelViewModel.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import Foundation
import SwiftUI

class MealsListPanelViewModel: ObservableObject {
    private let data = MealsDataController()
    @Published var meals: MealList
    var recentlyPickedMealsId: AlreadyPickedIds
    var availableMeals: MealList
    
    init() {
        meals = data.loadAllMeals()
        recentlyPickedMealsId = AlreadyPickedIds(pickedMeatIds: [], pickedVeganIds: [], pickedOutsideIds: [])
        availableMeals = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        
        /*
        meals.append(Meal(id: 102, name: "Tortilla Chips", type: .meat))
        meals.append(Meal(id: 103, name: "Avocado", type: .meat))
        meals.append(Meal(id: 104, name: "Red Cabbage", type: .meat))
        meals.append(Meal(id: 105, name: "Red something", type: .meat))
        meals.append(Meal(id: 106, name: "Red something else", type: .meat))
        meals.append(Meal(id: 107, name: "Red thing with red rice and pasta and butter and lots of other things", type: .meat))
        
        meals.append(Meal(id: 110, name: "Soup", type: .vegan))
         */
        
        iniPickedAndAvailableMealsList()
        meals.sort()
    }
    
    private func iniPickedAndAvailableMealsList() {
        // Available prend tout les meals
        availableMeals = meals
        
        // On initialise Picked à partir de ce qui a été sauvegardé
        recentlyPickedMealsId = data.loadAlreadyPickedIds()
        
        // On retire de Available tout les meals de Picked
        for id in recentlyPickedMealsId.pickedMeatIds {
            availableMeals.meatMeals.removeAll(where: {$0.id == id})
        }
        for id in recentlyPickedMealsId.pickedVeganIds {
            availableMeals.veganMeals.removeAll(where: {$0.id == id})
        }
        for id in recentlyPickedMealsId.pickedOutsideIds {
            availableMeals.outsideMeals.removeAll(where: {$0.id == id})
        }
    }
    
    public func mealHasBeenPicked(_ meal: Meal) {
        guard meal.id >= 0 else { return } // Don't do anything if leftover or custom meal
        availableMeals.removeWithId(meal.id)
        recentlyPickedMealsId.append(meal.id, type: meal.type)
        
        let availableMealCount = availableMeals.count()
        print("Available : \(availableMealCount.0)-\(availableMealCount.1)-\(availableMealCount.2), already picked : \(recentlyPickedMealsId.pickedMeatIds.count)-\(recentlyPickedMealsId.pickedVeganIds.count)-\(recentlyPickedMealsId.pickedOutsideIds.count)")
        
        let mealCount = meals.count()
        // Si available trop petit, on reset tout
        if availableMealCount.0 <= mealCount.0 / 5 {
            print("Available meat meals too small, reseting")
            availableMeals.meatMeals = meals.meatMeals
            recentlyPickedMealsId.pickedMeatIds = []
        }
        if availableMealCount.1 <= mealCount.1 / 5 {
            print("Available vegan meals too small, reseting")
            availableMeals.veganMeals = meals.veganMeals
            recentlyPickedMealsId.pickedVeganIds = []
        }
        if availableMealCount.2 <= mealCount.2 / 5 {
            print("Available outside meals too small, reseting")
            availableMeals.outsideMeals = meals.outsideMeals
            recentlyPickedMealsId.pickedOutsideIds = []
        }
        
        // SAVE RECENTLY PICKED
        data.saveAlreadyPickedIds(recentlyPickedMealsId)
    }
}

extension MealsListPanelViewModel {
    func getRandomMeal(type: MealType) -> Meal? {
        let meal = availableMeals.getRandomElement(type: type)
        guard let meal = meal else { return nil }
        mealHasBeenPicked(meal)
        return meal.new()
    }
    
    func getRandomMealMeatOrVegan() -> Meal? {
        let availableMealsMeatOrVegan = availableMeals.meatMeals + availableMeals.veganMeals
        let meal = availableMealsMeatOrVegan.randomElement()
        guard let meal = meal else { return nil }
        mealHasBeenPicked(meal)
        return meal.new()
    }
}

// Buttons
extension MealsListPanelViewModel {
    func createNewMealWith(name: String, type: MealType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newMealTmp = Meal(id: data.mealCount + 1, name: name, type: type)
            data.createNewMeal(meal: newMealTmp)
            meals.append(newMealTmp)
            meals.sort()
            availableMeals.append(newMealTmp)
        }
    }
    
    func updateMealInfo(meal: Meal) {
        withAnimation(.easeInOut(duration: 0.3)) {
            dump(meal)
            meals.updateValue(meal)
            meals.sort()
            availableMeals.updateValue(meal)
            data.updateMeal(meal: meal)
        }
    }
    
    func deleteMeal(meal: Meal) {
        withAnimation(.easeInOut(duration: 0.3)) {
            print("Removing \(meal.name)")
            meals.removeWithId(meal.id)
            availableMeals.removeWithId(meal.id)
            data.deleteMeal(meal: meal)
        }
    }
}
