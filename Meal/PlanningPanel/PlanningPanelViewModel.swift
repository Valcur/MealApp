//
//  PlanningPanelViewModel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import Foundation
import SwiftUI

class PlanningPanelViewModel: ObservableObject {
    @Published var weekPlan: WeekPlan
    private let data = MealsDataController()
    var mealsVM: MealsListPanelViewModel
    var configureVM: ConfigurePanelViewModel
    
    var selectedWeek: WichWeekIsIt = .thisWeek
    var thisWeek: WeekPlan
    var nextWeek: WeekPlan
    
    init(mealsVM: MealsListPanelViewModel, configureVM: ConfigurePanelViewModel) {
        self.mealsVM = mealsVM
        self.configureVM = configureVM
        
        thisWeek = data.loadWeek(forWeek: .thisWeek)
        nextWeek = data.loadWeek(forWeek: .nextWeek)
        
        weekPlan = thisWeek
        
        let WANT_TO_RESET = false
        if WANT_TO_RESET {
            weekPlan = WeekPlan(.thisWeek)
            weekPlan.append(Meal(id: 1, name: "Fish & Chips", type: .meat), day: .monday, time: .midday)
            weekPlan.append(Meal(id: 2, name: "Avocado Toast", type: .vegan), day: .monday, time: .evening)
            weekPlan.append(Meal(id: 3, name: "Kebab", type: .outside), day: .wednesday, time: .midday)
            weekPlan.append(Meal(id: 4, name: "Soup", type: .vegan), day: .friday, time: .evening)
            weekPlan.append(Meal(id: 5, name: "Salmon", type: .meat), day: .friday, time: .evening)
            weekPlan.append(Meal(id: 6, name: "Sushi", type: .meat), day: .saturday, time: .midday)
            weekPlan.append(Meal(id: 7, name: "Soup", type: .vegan), day: .monday, time: .midday)
            
            saveWeek()
        }
        
        updateWeekDatesIfNeeded()
    }
    
    func updateWeekDatesIfNeeded() {
        let cal = Calendar(identifier: .gregorian)
        // Le début de semaine des 2 semaines actuellment sauvegardées
        let savedThisWeekMonday = cal.startOfDay(for: thisWeek.week[0].date)
        let savedNextWeekMonday = cal.startOfDay(for: nextWeek.week[0].date)
        // Le début de la semaine actuelle
        let thisWeekMonday = cal.startOfDay(for: Date().previous(.monday))
        
        // Si nextweek est devenu thisweek, on remplace et on créé un nouveau nextweek
        if thisWeekMonday == savedNextWeekMonday {
            print("Nouvelle semaine !")
            thisWeek = nextWeek
            nextWeek = WeekPlan(.nextWeek)
            configureVM.applyAllSchedulesTo(nextWeek)
            
            switchToNextWeek()
            saveWeek()
            switchToThisWeek()
            saveWeek()
        }
        // Si la semaine actuelle correpsond a aucune des 2 semaines, on récréé 2 nouvelles semaines
        else if thisWeekMonday != savedThisWeekMonday {
            print("L'app n'a pas été ouverte depuis plus de 2 semaines")
            thisWeek = WeekPlan(.thisWeek)
            nextWeek = WeekPlan(.nextWeek)
            configureVM.applyAllSchedulesTo(thisWeek)
            configureVM.applyAllSchedulesTo(nextWeek)
            
            switchToNextWeek()
            saveWeek()
            switchToThisWeek()
            saveWeek()
        }
    }
    
    func saveWeek() {
        data.saveWeek(weekPlan: weekPlan, forWeek: selectedWeek)
        configureVM.calendarController.addWeekToCalendar(weekPlan: weekPlan)
    }
}

extension PlanningPanelViewModel {
    func addRandomMeal(day: WeekDays, time: TimeOfTheDay) {
        let randomMeal = mealsVM.getRandomMeal(type: MealType.randomNonOutside())
        guard let randomMeal = randomMeal else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            weekPlan.append(randomMeal, day: day, time: time)
            weekPlan.objectWillChange.send()
            for i in 0..<weekPlan.week.count {
                weekPlan.week[i].objectWillChange.send()
            }
            self.objectWillChange.send()
        }
        
        saveWeek()
    }
    
    func addMeal(_ meal: Meal, day: WeekDays, time: TimeOfTheDay) {
        withAnimation(.easeInOut(duration: 0.3)) {
            weekPlan.append(meal, day: day, time: time)
            weekPlan.week[day.rawValue].objectWillChange.send()
            self.objectWillChange.send()
        }
        mealsVM.mealHasBeenPicked(meal)
        
        saveWeek()
    }
    
    func deleteMeal(_ meal: Meal, dayPlan: DayPlan, time: TimeOfTheDay) {
        if time == .midday {
            dayPlan.midday.removeAll(where: {$0.id == meal.id})
        } else {
            dayPlan.evening.removeAll(where: {$0.id == meal.id})
        }
        dayPlan.objectWillChange.send()
        
        saveWeek()
    }
}

extension PlanningPanelViewModel {
    func autoFill(meatPercentage: Double, desiredOutside: Int) {
        print("Desired : \(meatPercentage)% and \(desiredOutside) outside")
        var numberOfMeat = 0
        var numberOfVegan = 0
        var numberOfOutside = 0
        
        // On compte ce qui est déjà renté par l'utilisteur pour cette semaine
        let mealsAlreadySetThisWeek = weekPlan.getAllMealsInPlan()
        
        for meal in mealsAlreadySetThisWeek {
            if meal.type == .meat {
                numberOfMeat += 1
            } else if meal.type == .vegan {
                numberOfVegan += 1
            } else if meal.type == .outside {
                numberOfOutside += 1
            }
        }
        
        print("Already set : \(numberOfMeat) meat, \(numberOfVegan) vegan, \(numberOfOutside) outside")
        
        // On remplis au hasard avec le nombre restant de outside
        
        while numberOfOutside < desiredOutside {
            let meal = mealsVM.getRandomMeal(type: .outside)
            // Ajouter le plat à un jour aléatoire vide qui n'a pas de outside
            if meal != nil {
                addOutsideMealToRandomDay(meal: meal!)
            }
            numberOfOutside += 1
        }
        
        // On remplis tout les autres jours afin de maintenir le ratio meat/vegan
        
        // On compte le nombre de repas vide a remplir
        var numberOfEmptyLunch = 0
        for day in weekPlan.week {
            if day.midday.count == 0 {
                numberOfEmptyLunch += 1
            }
            if day.evening.count == 0 {
                numberOfEmptyLunch += 1
            }
        }
        
        // On calcule combien de meat on doit ajouter pour atteindre le ratio demandé
        let targetedNumberOfMeatLunch = Int((Double(numberOfEmptyLunch + numberOfMeat + numberOfVegan)) * (meatPercentage / 100))
        print("With \(meatPercentage)%, we want \(targetedNumberOfMeatLunch) lunch with meat")
        
        let meatLunchToAdd: Int = targetedNumberOfMeatLunch - numberOfMeat
        let veganLunchToAdd = numberOfEmptyLunch - meatLunchToAdd
        print("We still have to add \(meatLunchToAdd) meat and \(veganLunchToAdd) vegan")
        
        // On ajoute le bon nombre de meat à un repas aléatoire
        if meatLunchToAdd > 0 {
            for _ in 0..<meatLunchToAdd {
                let meal = mealsVM.getRandomMeal(type: .meat)
                if meal != nil {
                    addMealToRandomDay(meal: meal!.new())
                }
            }
        }
        
        // On ajoute le bon nombre de vegan à un repas aléatoire
        if veganLunchToAdd > 0 {
            for _ in 0..<veganLunchToAdd {
                let meal = mealsVM.getRandomMeal(type: .vegan)
                if meal != nil {
                    addMealToRandomDay(meal: meal!.new())
                }
            }
        }
        
        // Notify changes
        withAnimation(.easeInOut(duration: 0.3)) {
            weekPlan.objectWillChange.send()
            for i in 0..<weekPlan.week.count {
                weekPlan.week[i].objectWillChange.send()
            }
            self.objectWillChange.send()
        }
        
        saveWeek()
    }
    
    private func addOutsideMealToRandomDay(meal: Meal) {
        var emptyDays: [WeekDays] = []  // Jours avec au moin midi ou soir de libre
        for day in weekPlan.week {
            if day.midday.count == 0 || day.evening.count == 0 {
                emptyDays.append(day.day)
            }
        }
        
        guard emptyDays.count > 0 else { return }
        
        var successfullyAdded = false
        var tryCount = 0
        while(!successfullyAdded && tryCount < 200) {
            // On prend un jour au hasard
            let weekDay = emptyDays.randomElement()
            let day = weekPlan.week[weekDay!.rawValue]
        
            var possibleChoices: [TimeOfTheDay] = []
            
            // On s'assure de ne pas ajouter de outside si il y en déjà un dans la même journée
            if day.midday.count == 0 && !day.evening.contains(where: {$0.type == .outside}){
                possibleChoices.append(.midday)
            }
            if day.evening.count == 0 && !day.midday.contains(where: {$0.type == .outside}){
                possibleChoices.append(.evening)
            }
            
            if possibleChoices.count > 0 {
                let randomTime = possibleChoices.randomElement()
                if randomTime == .midday {
                    day.midday.append(meal)
                }
                if randomTime == .evening {
                    day.evening.append(meal)
                }
                successfullyAdded = true
            }
            
            tryCount += 1
        }
    }
    
    private func addMealToRandomDay(meal: Meal) {
        var emptyDays: [WeekDays] = []  // Jours avec au moin midi ou soir de libre
        for day in weekPlan.week {
            if day.midday.count == 0 || day.evening.count == 0 {
                emptyDays.append(day.day)
            }
        }
        
        guard emptyDays.count > 0 else { return }
        
        var successfullyAdded = false
        var tryCount = 0
        while(!successfullyAdded && tryCount < 200) {
            // On prend un jour au hasard
            let weekDay = emptyDays.randomElement()
            let day = weekPlan.week[weekDay!.rawValue]
        
            var possibleChoices: [TimeOfTheDay] = []
            
            if day.midday.count == 0 {
                possibleChoices.append(.midday)
            }
            if day.evening.count == 0 {
                possibleChoices.append(.evening)
            }
            
            if possibleChoices.count > 0 {
                let randomTime = possibleChoices.randomElement()
                if randomTime == .midday {
                    day.midday.append(meal)
                }
                if randomTime == .evening {
                    day.evening.append(meal)
                }
                successfullyAdded = true
            }
            
            tryCount += 1
        }
    }
}

extension PlanningPanelViewModel {
    func switchToThisWeek() {
        if selectedWeek != .thisWeek {
            weekPlan = thisWeek
            selectedWeek = .thisWeek
        }
    }
    
    func switchToNextWeek() {
        if selectedWeek != .nextWeek {
            weekPlan = nextWeek
            selectedWeek = .nextWeek
        }
    }
}
