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
    @State var showIntro: Bool
    
    init() {
        mealListVM = MealsListPanelViewModel()
        configurePanelVM = ConfigurePanelViewModel()
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM, configureVM: configurePanelVM)
        configurePanelVM.planningPanelVM = planningVM
        
        // Show intro for as long as there is no meal saved by the user
        let mealsCount = mealListVM.meals.count()
        showIntro = mealsCount.0 == 0 && mealsCount.1 == 0 && mealsCount.2 == 0
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
            }.sheet(isPresented: $showIntro) {
                IntroSheet()
            }
        }
    }
}
