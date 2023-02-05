//
//  MealTests.swift
//  MealTests
//
//  Created by Loic D on 06/12/2022.
//

import XCTest
@testable import Meal

final class MealTests: XCTestCase {
    
    var planningVM: PlanningPanelViewModel?
    var mealListVM: MealsListPanelViewModel?
    var configurePanelVM: ConfigurePanelViewModel?

    override func setUpWithError() throws {
        mealListVM = MealsListPanelViewModel()
        configurePanelVM = ConfigurePanelViewModel()
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM!, configureVM: configurePanelVM!)
        configurePanelVM!.planningPanelVM = planningVM
    }
    
    func reset() {
        // Make it empty in case of testing on a device who has already saved meals or weekplan
        mealListVM?.meals = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        mealListVM?.availableMeals = MealList(meatMeals: [], veganMeals: [], outsideMeals: [])
        planningVM?.weekPlan = WeekPlan(.thisWeek)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test() throws {
        try! test_mealListPanelViewModel()
        try! test_planningPanelViewModel()
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
