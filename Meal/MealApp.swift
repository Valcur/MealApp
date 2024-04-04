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
        showIntro = mealListVM.isListEmpty
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
                }
                */
                PlanningPannel(cloudKitController: cloudKitController)
                    .ignoresSafeArea(.keyboard)
                    .environmentObject(planningVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("tab_week", comment: "My week"))
                    }.tabItemAccentColor(userPrefs.accentColor)
                
                MealsListPanel()
                    .environmentObject(mealListVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text(NSLocalizedString("tab_meals", comment: "My meals"))
                    }.tabItemAccentColor(userPrefs.accentColor)
                
                ConfigurePanel()
                    .environmentObject(configurePanelVM)
                    .environmentObject(mealListVM)
                    .environmentObject(userPrefs)
                    .tabItem {
                        Image(systemName: "gear")
                        Text(NSLocalizedString("tab_options", comment: "Options"))
                    }.tabItemAccentColor(userPrefs.accentColor)
            }.tabItemAccentColor(userPrefs.accentColor).sheet(isPresented: $showIntro) {
                IntroSheet().environmentObject(userPrefs)
            }.background(ZStack {
                if !showIntro {
                    WhatsNewView().environmentObject(userPrefs)
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                UIApplication.shared.applicationIconBadgeNumber = 0
                if cloudKitController.isIniComplete() || !cloudKitController.isSavingToCloud() {
                    print("Going foreground from background")
                    planningVM.updateData()
                    print("Updating too old picked meals")
                    mealListVM.addBackTooOldPickedMeals()
                }
            }
            .onAppear() {
                // Not working from init
                IAPManager.shared.startWith(arrayOfIds: [IAPManager.getSubscriptionId(), IAPManager.getLifetimeId()], sharedSecret: IAPManager.getSharedSecret())
                configurePanelVM.testPremium()
                
                
                if #available(iOS 15.0, *) {
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
            }
        }
    }
}
