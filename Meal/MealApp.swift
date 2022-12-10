//
//  MealApp.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import SwiftUI

@main
struct MealApp: App {
    let planningVM: PlanningPanelViewModel
    let mealListVM: MealsListPanelViewModel
    
    init() {
        mealListVM = MealsListPanelViewModel()
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PlanningPannel()
                    .environmentObject(planningVM)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("My weak")
                    }
                
                MealsListPanel()
                    .environmentObject(mealListVM)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("My meals")
                    }
            }
            
        }
    }
}
