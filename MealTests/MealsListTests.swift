//
//  MealsListTests.swift
//  MealTests
//
//  Created by Loic D on 19/01/2023.
//

import XCTest
@testable import Meal

extension MealTests {
    func test_mealListPanelViewModel() throws {
        reset()
        var meal: Meal = Meal(id: 0, name: "", type: .meat)
        try! test_createNewMeal_success(meal: meal)
        
        meal = mealListVM!.meals.meatMeals.last!
        meal.name = "V"
        meal.type = .vegan
        try! test_updateMealInfo_success(meal: meal)
        
        try! test_deleteMeal_success(meal: meal)
    }

    func test_createNewMeal_success(meal: Meal) throws {
        mealListVM!.createNewMealWith(name: meal.name, type: meal.type)
        let lastAddedMeatMeal = mealListVM!.meals.meatMeals.last
        XCTAssertEqual(meal.type, lastAddedMeatMeal!.type)
        XCTAssertEqual(meal.name, lastAddedMeatMeal!.name)
    }
    
    func test_updateMealInfo_success(meal: Meal) throws {
        mealListVM!.updateMealInfo(meal: meal)
        let lastAddedVeganMeal = mealListVM!.meals.veganMeals.last
        XCTAssertEqual(meal.id, lastAddedVeganMeal!.id)
        XCTAssertEqual(meal.type, lastAddedVeganMeal!.type)
        XCTAssertEqual(meal.name, lastAddedVeganMeal!.name)
        XCTAssertEqual(mealListVM!.meals.meatMeals.count, 0)
    }
    
    func test_deleteMeal_success(meal: Meal) throws {
        mealListVM!.deleteMeal(meal: meal)
        XCTAssertEqual(mealListVM!.meals.veganMeals.count, 0)
    }
}
