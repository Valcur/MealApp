//
//  MealsDataController.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import Foundation

class MealsDataController {
    
    private let userDefaults = UserDefaults.standard
    var mealCount: Int
    
    private let MEAL_COUNT_KEY = "MEAL_COUNT"
    private let MEAL_KEY = "MEAL"
    
    init() {
        mealCount = userDefaults.integer(forKey: MEAL_COUNT_KEY)
    }
    
    // Retourne un tableau de "Meal" contenant tout les plats enregistrés par l'utilisateur
    func loadAllMeals() -> MealList {
        var mealList = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        
        guard mealCount > 0 else {
            return mealList
        }
        
        for i in 1...mealCount {
            let meal = userDefaults.object(forKey: "\(MEAL_KEY)_\(i)") as? Meal ?? nil
            if let meal = meal {
                mealList.append(meal)
            }
        }
        
        return mealList
    }
    
    // Enregistre un nouveau plat créé par l'utilisateur
    func createNewMeal(meal: Meal) {
        mealCount += 1
        userDefaults.set(mealCount, forKey: MEAL_COUNT_KEY)
        saveDataMeal(meal)
    }
    
    // Enregistre les changements effectués sur un plat
    func updateMeal(meal: Meal) {
        userDefaults.set(meal, forKey: "\(MEAL_KEY)_\(meal.id)")
    }
    
    // Supprime un plat
    func deleteMeal(meal: Meal) {
        userDefaults.removeObject(forKey: "\(MEAL_KEY)_\(meal.id)")
    }
    

}

extension MealsDataController {
    private func saveDataMeal(_ meal: Meal) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(meal) {
            userDefaults.set(data, forKey: "\(MEAL_KEY)_\(meal.id)")
        }
    }
    
    private func getDataMealWithId(_ id: Int) -> Meal? {
        if let data = userDefaults.object(forKey: "\(MEAL_KEY)_\(id)") as? Data {
            let decoder = JSONDecoder()
            if let meal = try? decoder.decode(Meal.self, from: data) {
                return meal
            }
        }
        return nil
    }
}
