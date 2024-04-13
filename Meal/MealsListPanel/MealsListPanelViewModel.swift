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
    var recentlyPickedMeals: AlreadyPicked
    @Published var availableMeals: MealList
    var sides: [Side]
    var isListEmpty: Bool {
        let mealsCount = meals.count()
        return mealsCount.0 == 0 && mealsCount.1 == 0 && mealsCount.2 == 0 && mealsCount.3 == 0
    }
    var tooOldMealPickedTreshold: Int
    
    init() {
        meals = data.loadAllMeals()
        recentlyPickedMeals = AlreadyPicked(pickedMeatIds: [], pickedVeganIds: [], pickedOtherIds: [], pickedOutsideIds: [])
        availableMeals = MealList(meatMeals: [], veganMeals: [], otherMeals: [], outsideMeals: [])
        sides = data.loadAllUserSides()
        tooOldMealPickedTreshold = (UserDefaults.standard.value(forKey: "TooOldTreshold") ?? 4) as! Int
        
        iniPickedAndAvailableMealsList()
        meals.sort()
    }
    
    private func iniPickedAndAvailableMealsList() {
        // Available prend tout les meals
        availableMeals = meals
        
        // On initialise Picked à partir de ce qui a été sauvegardé
        recentlyPickedMeals = data.loadAlreadyPickedIds()
        
        // On retire de Available tout les meals de Picked
        for m in recentlyPickedMeals.pickedMeatIds {
            availableMeals.meatMeals.removeAll(where: {$0.id == m.id})
        }
        for m in recentlyPickedMeals.pickedVeganIds {
            availableMeals.veganMeals.removeAll(where: {$0.id == m.id})
        }
        for m in recentlyPickedMeals.pickedOtherIds {
            availableMeals.otherMeals.removeAll(where: {$0.id == m.id})
        }
        for m in recentlyPickedMeals.pickedOutsideIds {
            availableMeals.outsideMeals.removeAll(where: {$0.id == m.id})
        }
    }
    
    public func mealHasBeenPicked(_ meal: Meal, date: Date) {
        guard meal.id >= 0 else { return } // Don't do anything if leftover or custom meal
        availableMeals.removeWithId(meal.id)
        recentlyPickedMeals.append(meal.id, type: meal.type, date: date)
        print("\(meal.name) has been picked")
        let availableMealCount = availableMeals.count()
        
        let mealCount = meals.count()
        // Si available trop petit, on rajoute les plus anciens pour atteindre 1/2 des plats
        if availableMealCount.0 <= mealCount.0 / 4 {
            print("Available meat meals too small, reseting")
            availableMeals.meatMeals = meals.meatMeals
            let n = recentlyPickedMeals.pickedMeatIds.count - (mealCount.0 / 2 )
            recentlyPickedMeals.pickedMeatIds.removeFirst(n)
            for m in recentlyPickedMeals.pickedMeatIds {
                availableMeals.meatMeals.removeAll(where: { $0.id == m.id })
            }
        }
        if availableMealCount.1 <= mealCount.1 / 4 {
            print("Available vegan meals too small, reseting")
            availableMeals.veganMeals = meals.veganMeals
            let n = recentlyPickedMeals.pickedVeganIds.count - (mealCount.1 / 2 )
            recentlyPickedMeals.pickedVeganIds.removeFirst(n)
            for m in recentlyPickedMeals.pickedVeganIds {
                availableMeals.veganMeals.removeAll(where: { $0.id == m.id })
            }
        }
        if availableMealCount.2 <= mealCount.2 / 4 {
            print("Available other meals too small, reseting")
            availableMeals.otherMeals = meals.otherMeals
            let n = recentlyPickedMeals.pickedOtherIds.count - (mealCount.2 / 2 )
            recentlyPickedMeals.pickedOtherIds.removeFirst(n)
            for m in recentlyPickedMeals.pickedOtherIds {
                availableMeals.otherMeals.removeAll(where: { $0.id == m.id })
            }
        }
        if availableMealCount.3 <= mealCount.3 / 4 {
            print("Available outside meals too small, reseting")
            availableMeals.outsideMeals = meals.outsideMeals
            let n = recentlyPickedMeals.pickedOutsideIds.count - (mealCount.3 / 2 )
            recentlyPickedMeals.pickedOutsideIds.removeFirst(n)
            for m in recentlyPickedMeals.pickedOutsideIds {
                availableMeals.outsideMeals.removeAll(where: { $0.id == m.id })
            }
        }
        
        // SAVE RECENTLY PICKED
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
    
    func resetMeatMeals() {
        availableMeals.meatMeals = meals.meatMeals
        recentlyPickedMeals.pickedMeatIds = []
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
    
    func resetVeganMeals() {
        availableMeals.veganMeals = meals.veganMeals
        recentlyPickedMeals.pickedVeganIds = []
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
    
    func resetOtherMeals() {
        availableMeals.otherMeals = meals.otherMeals
        recentlyPickedMeals.pickedOtherIds = []
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
    
    func resetOutsideMeals() {
        availableMeals.outsideMeals = meals.outsideMeals
        recentlyPickedMeals.pickedOutsideIds = []
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
    
    func addBackTooOldPickedMeals() {
        if tooOldMealPickedTreshold <= 0 {
            return
        }
        let calendar = Calendar.current
        let limitDate = calendar.date(byAdding: .day, value: -tooOldMealPickedTreshold, to: Date())
        var n = 0
        while n < recentlyPickedMeals.pickedMeatIds.count {
            let meal = recentlyPickedMeals.pickedMeatIds[n]
            if let date = limitDate, meal.lastPickedDate < date {
                recentlyPickedMeals.pickedMeatIds.remove(at: n)
                if let m = meals.meatMeals.first(where: { $0.id == meal.id }) {
                    availableMeals.meatMeals.append(m.new())
                }
                n -= 1
            }
            n += 1
        }
        
        while n < recentlyPickedMeals.pickedVeganIds.count {
            let meal = recentlyPickedMeals.pickedVeganIds[n]
            if let date = limitDate, meal.lastPickedDate < date {
                recentlyPickedMeals.pickedVeganIds.remove(at: n)
                if let m = meals.veganMeals.first(where: { $0.id == meal.id }) {
                    availableMeals.veganMeals.append(m.new())
                }
                n -= 1
            }
            n += 1
        }
        
        while n < recentlyPickedMeals.pickedOutsideIds.count {
            let meal = recentlyPickedMeals.pickedOutsideIds[n]
            if let date = limitDate, meal.lastPickedDate < date {
                recentlyPickedMeals.pickedOutsideIds.remove(at: n)
                if let m = meals.outsideMeals.first(where: { $0.id == meal.id }) {
                    availableMeals.outsideMeals.append(m.new())
                }
                n -= 1
            }
            n += 1
        }
        
        while n < recentlyPickedMeals.pickedOtherIds.count {
            let meal = recentlyPickedMeals.pickedOtherIds[n]
            if let date = limitDate, meal.lastPickedDate < date {
                recentlyPickedMeals.pickedOtherIds.remove(at: n)
                if let m = meals.otherMeals.first(where: { $0.id == meal.id }) {
                    availableMeals.otherMeals.append(m.new())
                }
                n -= 1
            }
            n += 1
        }
        
        data.saveAlreadyPickedIds(recentlyPickedMeals)
    }
}

extension MealsListPanelViewModel {
    func getRandomMeal(type: MealType) -> Meal? {
        let meal = availableMeals.getRandomElement(type: type)
        guard let meal = meal else { return nil }
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
        return meals
    }
}

// Buttons
extension MealsListPanelViewModel {
    func createNewMealWith(name: String, type: MealType, notes: String?, recipe: Recipe?, sides: [Side] = []) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newMealTmp = Meal(id: data.mealCount + 1, name: name, type: type, sides: sides, notes: notes, recipe: recipe)
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
        self.sides = newSides.sorted(by: {$0.name < $1.name})
        data.saveUserSides(self.sides)
        for side in newSides {
            if side.customImage != nil {
                print("Bingo")
            }
        }
    }
}
