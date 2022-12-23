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
    var outsideMeals: [Meal]
    
    mutating func append(_ meal: Meal) {
        switch meal.type {
        case .meat:
            meatMeals.append(meal)
        case .vegan:
            veganMeals.append(meal)
        case .outside:
            outsideMeals.append(meal)
        }
    }
    
    mutating func updateValue(_ meal: Meal) {
        // Remove the old meal
        meatMeals.removeAll(where: {$0.id == meal.id})
        veganMeals.removeAll(where: {$0.id == meal.id})
        outsideMeals.removeAll(where: {$0.id == meal.id})
        
        // Add the new one
        self.append(meal.new())
    }
    
    func getRandomElement(type: MealType) -> Meal? {
        switch type {
        case .meat:
            return meatMeals.randomElement()
        case .vegan:
            return veganMeals.randomElement()
        case .outside:
            return outsideMeals.randomElement()
        }
    }
}
