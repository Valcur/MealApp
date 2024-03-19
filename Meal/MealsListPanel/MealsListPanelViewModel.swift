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
    @Published var availableMeals: MealList
    var sides: [Side]
    var isListEmpty: Bool {
        let mealsCount = meals.count()
        return mealsCount.0 == 0 && mealsCount.1 == 0 && mealsCount.2 == 0 && mealsCount.3 == 0
    }
    
    init() {
        meals = data.loadAllMeals()
        recentlyPickedMealsId = AlreadyPickedIds(pickedMeatIds: [], pickedVeganIds: [], pickedOtherIds: [], pickedOutsideIds: [])
        availableMeals = MealList(meatMeals: [], veganMeals: [], otherMeals: [], outsideMeals: [])
        sides = data.loadAllUserSides()
        
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
        for id in recentlyPickedMealsId.pickedOtherIds {
            availableMeals.otherMeals.removeAll(where: {$0.id == id})
        }
        for id in recentlyPickedMealsId.pickedOutsideIds {
            availableMeals.outsideMeals.removeAll(where: {$0.id == id})
        }
    }
    
    public func mealHasBeenPicked(_ meal: Meal) {
        guard meal.id >= 0 else { return } // Don't do anything if leftover or custom meal
        availableMeals.removeWithId(meal.id)
        recentlyPickedMealsId.append(meal.id, type: meal.type)
        print("\(meal.name) has been picked")
        let availableMealCount = availableMeals.count()
        
        let mealCount = meals.count()
        // Si available trop petit, on reset tout
        if availableMealCount.0 <= mealCount.0 / 4 {
            print("Available meat meals too small, reseting")
            availableMeals.meatMeals = meals.meatMeals
            recentlyPickedMealsId.pickedMeatIds = []
        }
        if availableMealCount.1 <= mealCount.1 / 4 {
            print("Available vegan meals too small, reseting")
            availableMeals.veganMeals = meals.veganMeals
            recentlyPickedMealsId.pickedVeganIds = []
        }
        if availableMealCount.2 <= mealCount.2 / 4 {
            print("Available other meals too small, reseting")
            availableMeals.otherMeals = meals.otherMeals
            recentlyPickedMealsId.pickedOtherIds = []
        }
        if availableMealCount.3 <= mealCount.3 / 4 {
            print("Available outside meals too small, reseting")
            availableMeals.outsideMeals = meals.outsideMeals
            recentlyPickedMealsId.pickedOutsideIds = []
        }
        
        // SAVE RECENTLY PICKED
        data.saveAlreadyPickedIds(recentlyPickedMealsId)
    }
    
    func resetMeatMeals() {
        availableMeals.meatMeals = meals.meatMeals
        recentlyPickedMealsId.pickedMeatIds = []
        data.saveAlreadyPickedIds(recentlyPickedMealsId)
    }
    
    func resetVeganMeals() {
        availableMeals.veganMeals = meals.veganMeals
        recentlyPickedMealsId.pickedVeganIds = []
        data.saveAlreadyPickedIds(recentlyPickedMealsId)
    }
    
    func resetOtherMeals() {
        availableMeals.otherMeals = meals.otherMeals
        recentlyPickedMealsId.pickedOtherIds = []
        data.saveAlreadyPickedIds(recentlyPickedMealsId)
    }
    
    func resetOutsideMeals() {
        availableMeals.outsideMeals = meals.outsideMeals
        recentlyPickedMealsId.pickedOutsideIds = []
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
    
    func getRandomMealsMeatOrVegan(count: Int = 1) -> [Meal] {
        var meals = [Meal]()
        var availableMealsMeatOrVegan = availableMeals.meatMeals + availableMeals.veganMeals
        for _ in 1...count {
            if let meal = availableMealsMeatOrVegan.removeRandom() {
                meals.append(meal.new())
            }
        }
        //let meal = availableMealsMeatOrVegan.randomElement()
        //guard let meal = meal else { return nil }
        //mealHasBeenPicked(meal)
        return meals
    }
}

// Buttons
extension MealsListPanelViewModel {
    func createNewMealWith(name: String, type: MealType, notes: String?, sides: [Side] = []) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newMealTmp = Meal(id: data.mealCount + 1, name: name, type: type, sides: sides, notes: notes)
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

// Sides
extension MealsListPanelViewModel {
    func saveSides(_ newSides: [Side]) {
        var oldSides = self.sides
        self.sides = newSides.sorted(by: {$0.name < $1.name})
        /*
        for i in 0..<self.sides.count {
            if !self.sides[i].isDefaultSide {
                if let oldSide = oldSides.first(where: { $0.id == self.sides[i].id }) {
                    if oldSide.name != self.sides[i].name {
                        self.sides[i].id = UUID().uuidString
                        print("Changing id for old")
                    }
                } else {
                    print("new side")
                }
            }
        }*/
        data.saveUserSides(self.sides)
    }
}
