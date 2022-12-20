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
    let configurePanelVM: ConfigurePanelViewModel
    
    init() {
        mealListVM = MealsListPanelViewModel()
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM)
        configurePanelVM = ConfigurePanelViewModel(planningPanelVM: planningVM)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PlanningPannel()
                    .environmentObject(planningVM)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("tab_week", comment: "My week"))
                    }
                
                MealsListPanel()
                    .environmentObject(mealListVM)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text(NSLocalizedString("tab_meals", comment: "My meals"))
                    }
                
                ConfigurePanel()
                    .environmentObject(configurePanelVM)
                    .environmentObject(mealListVM)
                    .tabItem {
                        Image(systemName: "gear")
                        Text(NSLocalizedString("tab_options", comment: "Options"))
                    }
            }
            
        }
    }
}
