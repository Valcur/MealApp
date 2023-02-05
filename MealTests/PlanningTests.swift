//
//  PlanningTests.swift
//  MealTests
//
//  Created by Loic D on 19/01/2023.
//

import XCTest
@testable import Meal

extension MealTests {
    func test_planningPanelViewModel() throws {
        reset()
        let meal = Meal(id: 0, name: "", type: .meat)
        
        try! test_addRandomMeal_success(meal: meal)
        try! test_deleteMealPlanning_success(meal: meal)
        try! test_addMeal_success(meal: meal)
        try! test_clipboard_success(meal: meal)

        try! test_autofill_success()
    }
    
    func test_addRandomMeal_success(meal: Meal) throws {
        mealListVM?.availableMeals.meatMeals.append(meal)
        
        planningVM?.addRandomMeal(day: .monday, time: .midday)
        
        let lastMeal = planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.last
        XCTAssertEqual(lastMeal?.id, meal.id)
        XCTAssertEqual(lastMeal?.name, meal.name)
    }
    
    func test_addMeal_success(meal: Meal) throws {
        XCTAssertEqual(planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.count, 0)
        planningVM?.addMeal(meal, day: .monday, time: .midday)
        
        let lastMeal = planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.last
        XCTAssertEqual(lastMeal?.id, meal.id)
        XCTAssertEqual(lastMeal?.name, meal.name)
        XCTAssertEqual(planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.count, 1)
    }

    func test_deleteMealPlanning_success(meal: Meal) throws {
        planningVM?.deleteMeal(meal, dayPlan: (planningVM?.weekPlan.week[WeekDays.monday.rawValue])!, time: .midday)
        XCTAssertEqual(planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.count, 0)
    }
    
    func test_clipboard_success(meal: Meal) throws {
        planningVM?.copyClipboardMeal(meal, day: (planningVM?.weekPlan.week[WeekDays.monday.rawValue])!, time: .midday)
        planningVM?.addClipboardMeal(day: .monday, time: .evening)
        XCTAssertEqual(planningVM?.weekPlan.week[WeekDays.monday.rawValue].midday.count, 0)
        XCTAssertEqual(planningVM?.weekPlan.week[WeekDays.monday.rawValue].evening.count, 1)
        
        let lastMeal = planningVM?.weekPlan.week[WeekDays.monday.rawValue].evening.last
        XCTAssertEqual(lastMeal?.id, meal.id)
        XCTAssertEqual(lastMeal?.name, meal.name)
        planningVM?.deleteMeal(meal, dayPlan: (planningVM?.weekPlan.week[WeekDays.monday.rawValue])!, time: .evening)
    }
    
    func test_autofill_success() throws {
        // Create some meal for autofill to work properly
        let meatMeal = Meal(id: 0, name: "", type: .meat)
        let veganMeal = Meal(id: 1, name: "", type: .vegan)
        let outsideMeal = Meal(id: 2, name: "", type: .outside)
        mealListVM?.meals.append(meatMeal)
        mealListVM?.availableMeals.append(meatMeal)
        mealListVM?.meals.append(veganMeal)
        mealListVM?.availableMeals.append(veganMeal)
        mealListVM?.meals.append(outsideMeal)
        mealListVM?.availableMeals.append(outsideMeal)
        
        planningVM?.autoFill(meatPercentage: 40, desiredOutside: 4)
        var numberOfMeatMeals = 0
        var numberOfVeganMeals = 0
        var numberOfOutsideMeals = 0
        
        for day in planningVM!.weekPlan.week {
            for meal in [day.midday.first!, day.evening.first!] {
                numberOfMeatMeals += meal.type == .meat ? 1 : 0
                numberOfVeganMeals += meal.type == .vegan ? 1 : 0
                numberOfOutsideMeals += meal.type == .outside ? 1 : 0
            }
        }
        
        // 14 meals in a week, we should have : 4 outside meals, 4 meat and 6 vegan
        XCTAssertEqual(numberOfMeatMeals, 4)
        XCTAssertEqual(numberOfVeganMeals, 6)
        XCTAssertEqual(numberOfOutsideMeals, 4)
        
        // Remove
        mealListVM?.meals = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        mealListVM?.availableMeals = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        planningVM?.weekPlan = WeekPlan(.thisWeek)
    }
}
