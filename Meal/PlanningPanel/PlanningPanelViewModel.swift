//
//  PlanningPanelViewModel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import Foundation
import SwiftUI

class PlanningPanelViewModel: ObservableObject {
    @Published var weekPlan: WeekPlan = WeekPlan()
    var mealsVM: MealsListPanelViewModel
    
    init(mealsVM: MealsListPanelViewModel) {
        self.mealsVM = mealsVM
        
        weekPlan.append(Meal(id: 1, name: "Fish & Chips", type: .meat), day: .monday, time: .midday)
        weekPlan.append(Meal(id: 2, name: "Avocado Toast", type: .vegan), day: .monday, time: .evening)
        weekPlan.append(Meal(id: 3, name: "Kebab", type: .outside), day: .wednesday, time: .midday)
        weekPlan.append(Meal(id: 4, name: "Soup", type: .vegan), day: .friday, time: .evening)
        weekPlan.append(Meal(id: 5, name: "Salmon", type: .meat), day: .friday, time: .evening)
        weekPlan.append(Meal(id: 6, name: "Sushi", type: .meat), day: .saturday, time: .midday)
        weekPlan.append(Meal(id: 7, name: "Soup", type: .vegan), day: .monday, time: .midday)
    }
}

extension PlanningPanelViewModel {
    func addRandomMeal(day: WeekDays, time: TimeOfTheDay) {
        let randomMeal = mealsVM.meals.getRandomElement(type: .meat)
        guard let randomMeal = randomMeal else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            weekPlan.append(randomMeal.new(), day: day, time: time)
            weekPlan.objectWillChange.send()
            for i in 0..<weekPlan.week.count {
                weekPlan.week[i].objectWillChange.send()
            }
            self.objectWillChange.send()
        }
    }
    
    func addMeal(_ meal: Meal, day: WeekDays, time: TimeOfTheDay) {
        weekPlan.append(meal, day: day, time: time)
    }
}
