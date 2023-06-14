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
    let cloudKitController: CloudKitController
    @State var showIntro: Bool
    
    init() {
        cloudKitController = CloudKitController()
        mealListVM = MealsListPanelViewModel()
        configurePanelVM = ConfigurePanelViewModel(cloudKitController: cloudKitController)
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM, configureVM: configurePanelVM, cloudKitController: cloudKitController)
        configurePanelVM.planningPanelVM = planningVM
        
        // Show intro for as long as there is no meal saved by the user
        let mealsCount = mealListVM.meals.count()
        showIntro = mealsCount.0 == 0 && mealsCount.1 == 0 && mealsCount.2 == 0
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PlanningPannel()
                    .ignoresSafeArea(.keyboard)
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
            }.background(ZStack {
                if !showIntro {
                    WhatsNewView()
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                UIApplication.shared.applicationIconBadgeNumber = 0
                if cloudKitController.isIniComplete() {
                    print("Going foreground from background")
                    planningVM.updateData()
                }
            }
        }
    }
}
