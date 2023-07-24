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
    let userPrefs: VisualUserPrefs
    @State var showIntro: Bool
    
    init() {
        cloudKitController = CloudKitController()
        mealListVM = MealsListPanelViewModel()
        configurePanelVM = ConfigurePanelViewModel(cloudKitController: cloudKitController)
        planningVM = PlanningPanelViewModel(mealsVM: mealListVM, configureVM: configurePanelVM, cloudKitController: cloudKitController)
        configurePanelVM.planningPanelVM = planningVM
        userPrefs = VisualUserPrefs()
        
        // Show intro for as long as there is no meal saved by the user
        let mealsCount = mealListVM.meals.count()
        showIntro = mealsCount.0 == 0 && mealsCount.1 == 0 && mealsCount.2 == 0
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                /*
                RecipesSearchPanel()
                    .environmentObject(RecipesSearchPanelViewModel())
                    .environmentObject(mealListVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "book")
                        Text("Recettes")
                }*/
                
                PlanningPannel(cloudKitController: cloudKitController)
                    .ignoresSafeArea(.keyboard)
                    .environmentObject(planningVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("tab_week", comment: "My week"))
                    }
                
                MealsListPanel()
                    .environmentObject(mealListVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text(NSLocalizedString("tab_meals", comment: "My meals"))
                    }
                
                ConfigurePanel()
                    .environmentObject(configurePanelVM)
                    .environmentObject(mealListVM)
                    .environmentObject(userPrefs)
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
                if cloudKitController.isIniComplete() || !cloudKitController.isSavingToCloud() {
                    print("Going foreground from background")
                    planningVM.updateData()
                }
            }
            .onAppear() {
                // Not working from init
                IAPManager.shared.startWith(arrayOfIds: [IAPManager.getSubscriptionId()], sharedSecret: IAPManager.getSharedSecret())
                configurePanelVM.testPremium()
            }
        }
    }
}
