//
//  MealsDataController.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import Foundation

class MealsDataController {
    
    internal let userDefaults = UserDefaults.standard
    var mealCount: Int
    
    private let MEAL_COUNT_KEY = "MEAL_COUNT"
    private let MEAL_KEY = "MEAL"
    internal let DAYPLAN_KEY = "DAYPLAN"
    internal let THIS_WEEK_KEY = "THIS_WEEK"
    internal let NEXT_WEEK_KEY = "NEXT_WEEK"
    internal let SCHEDULE_KEY = "SCHEDULE"
    internal let EVENT_KEY = "EVENT_IDENTIFIERS"
    internal let ALREADY_PICKED_KEY = "ALREADY_PICKED"
    internal let CALENDAR_USAGE_KEY = "CALENDAR_USAGE"
    internal let THIS_WEEK_LAST_MODIFY_KEY = "THIS_WEEK_LAST_MODIFY"
    internal let NEXT_WEEK_LAST_MODIFY_KEY = "NEXT_WEEK_LAST_MODIFY"
    internal let CATEGORIES_CUSTOMIZATION_KEY = "CATEGORIES_CUSTOMIZATION"
    internal let USER_SIDES_KEY = "USER_SIDES"
    
    init() {
        mealCount = userDefaults.integer(forKey: MEAL_COUNT_KEY)
    }
    
    // Retourne un tableau de "Meal" contenant tout les plats enregistrés par l'utilisateur
    func loadAllMeals() -> MealList {
        var mealList = MealList(meatMeals: [], veganMeals: [], otherMeals: [], outsideMeals: [])
        
        guard mealCount > 0 else {
            return mealList
        }
        
        for i in 1...mealCount {
            let meal = getDataMealWithId(i)
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
        saveDataMeal(meal)
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

extension MealsDataController {
    func saveAlreadyPickedIds(_ alreadyPicked: AlreadyPickedIds) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(alreadyPicked) {
            userDefaults.set(data, forKey: "\(ALREADY_PICKED_KEY)")
        }
    }
    
    func loadAlreadyPickedIds() -> AlreadyPickedIds {
        if let data = userDefaults.object(forKey: "\(ALREADY_PICKED_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let picked = try? decoder.decode(AlreadyPickedIds.self, from: data) {
                return picked
            }
        }
        return AlreadyPickedIds(pickedMeatIds: [], pickedVeganIds: [], pickedOtherIds: [], pickedOutsideIds: [])
    }
}

extension MealsDataController {
    func saveUserSides(_ sides: [Side]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sides) {
            userDefaults.set(data, forKey: "\(USER_SIDES_KEY)")
        }
    }
    
    func loadAllUserSides() -> [Side] {
        if let data = userDefaults.object(forKey: "\(USER_SIDES_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let sides = try? decoder.decode([Side].self, from: data) {
                return sides
            }
        }
        return Side.defaultSides
    }
}
