//
//  MealList.swift
//  Meal
//
//  Created by Loic D on 10/12/2022.
//

import Foundation

struct MealList {
    var meatMeals: [Meal]
    var veganMeals: [Meal]
    var otherMeals: [Meal]
    var outsideMeals: [Meal]
    
    mutating func append(_ meal: Meal) {
        switch meal.type {
        case .meat:
            meatMeals.append(meal)
        case .vegan:
            veganMeals.append(meal)
        case .other:
            otherMeals.append(meal)
        case .outside:
            outsideMeals.append(meal)
        }
    }
    
    mutating func updateValue(_ meal: Meal) {
        // Remove the old meal
        meatMeals.removeAll(where: {$0.id == meal.id})
        veganMeals.removeAll(where: {$0.id == meal.id})
        otherMeals.removeAll(where: {$0.id == meal.id})
        outsideMeals.removeAll(where: {$0.id == meal.id})
        
        // Add the new one
        self.append(meal.new())
    }
    
    mutating func removeWithId(_ id: Int) {
        meatMeals.removeAll(where: {$0.id == id})
        veganMeals.removeAll(where: {$0.id == id})
        otherMeals.removeAll(where: {$0.id == id})
        outsideMeals.removeAll(where: {$0.id == id})
    }
    
    mutating func sort() {
        meatMeals = meatMeals.sorted { $0.name < $1.name }
        veganMeals = veganMeals.sorted { $0.name < $1.name }
        otherMeals = otherMeals.sorted { $0.name < $1.name }
        outsideMeals = outsideMeals.sorted { $0.name < $1.name }
    }
    
    func count() -> (Int, Int, Int, Int) {
        return (meatMeals.count, veganMeals.count, otherMeals.count, outsideMeals.count)
    }
    
    func getRandomElement(type: MealType) -> Meal? {
        switch type {
        case .meat:
            return meatMeals.randomElement()
        case .vegan:
            return veganMeals.randomElement()
        case .other:
            return otherMeals.randomElement()
        case .outside:
            return outsideMeals.randomElement()
        }
    }
    
    func getAll() -> [Meal] {
        return meatMeals + veganMeals + outsideMeals + otherMeals
    }
}

struct AlreadyPickedIds: Codable {
    var pickedMeatIds: [Int]
    var pickedVeganIds: [Int]
    var pickedOtherIds: [Int]
    var pickedOutsideIds: [Int]
    
    mutating func append(_ id: Int, type: MealType) {
        if type == .meat {
            pickedMeatIds.removeAll(where: {$0 == id})
            pickedMeatIds.append(id)
        } else if type == .vegan {
            pickedVeganIds.removeAll(where: {$0 == id})
            pickedVeganIds.append(id)
        } else if type == .vegan {
            pickedOtherIds.removeAll(where: {$0 == id})
            pickedOtherIds.append(id)
        } else {
            pickedOutsideIds.removeAll(where: {$0 == id})
            pickedOutsideIds.append(id)
        }
    }
}
