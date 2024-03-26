//
//  weekPlan.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import Foundation
import SwiftUI

// L'organisation d'une semaine
class WeekPlan: ObservableObject {
    @Published var week: [DayPlan]
    
    init(_ wichWeek: WichWeekIsIt) {
        var firstDayOfTheWeek = Date().previous(.monday)
        
        if wichWeek == .nextWeek {
            firstDayOfTheWeek = Date().next(.monday)
        }
        
        week = [
            DayPlan(day: .monday, date: firstDayOfTheWeek, midday: [], evening: []),
            DayPlan(day: .tuesday, date: firstDayOfTheWeek.next(.tuesday), midday: [], evening: []),
            DayPlan(day: .wednesday, date: firstDayOfTheWeek.next(.wednesday), midday: [], evening: []),
            DayPlan(day: .thursday, date: firstDayOfTheWeek.next(.thursday), midday: [], evening: []),
            DayPlan(day: .friday, date: firstDayOfTheWeek.next(.friday), midday: [], evening: []),
            DayPlan(day: .saturday, date: firstDayOfTheWeek.next(.saturday), midday: [], evening: []),
            DayPlan(day: .sunday, date: firstDayOfTheWeek.next(.sunday), midday: [], evening: [])
        ]
    }
    
    func append(_ meal: Meal, day: WeekDays, time: TimeOfTheDay) {
        if time == .midday && week[day.rawValue].midday.count < 3 {
            week[day.rawValue].midday.append(meal.new())
            week[day.rawValue].objectWillChange.send()
        } else if time == .evening && week[day.rawValue].evening.count < 3 {
            week[day.rawValue].evening.append(meal.new())
            week[day.rawValue].objectWillChange.send()
        }
        self.objectWillChange.send()
    }
    
    func remove(_ meal: Meal, day: WeekDays, time: TimeOfTheDay) {
        if time == .midday {
            let index = week[day.rawValue].midday.firstIndex(where: {$0.id == meal.id && $0.name == meal.name})
            guard let index = index else { return }
            week[day.rawValue].midday.remove(at: index)
            week[day.rawValue].objectWillChange.send()
        } else if time == .evening {
            let index = week[day.rawValue].evening.firstIndex(where: {$0.id == meal.id && $0.name == meal.name})
            guard let index = index else { return }
            week[day.rawValue].evening.remove(at: index)
            week[day.rawValue].objectWillChange.send()
        }
    }
    
    func getAllMealsInPlan() -> [Meal] {
        var mealsThisWeek: [Meal] = []
        
        for day in self.week {
            for meal in day.midday {
                mealsThisWeek.append(meal)
            }
            for meal in day.evening {
                mealsThisWeek.append(meal)
            }
        }
        
        return mealsThisWeek
    }
}

enum WeekDays: Int, Codable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    func name() -> String {
        switch self {
        case .monday:
            return NSLocalizedString("Monday", comment: "Monday")
        case .tuesday:
            return NSLocalizedString("Tuesday", comment: "Tuesday")
        case .wednesday:
            return NSLocalizedString("Wednesday", comment: "Wednesday")
        case .thursday:
            return NSLocalizedString("Thursday", comment: "Thursday")
        case .friday:
            return NSLocalizedString("Friday", comment: "Friday")
        case .saturday:
            return NSLocalizedString("Saturday", comment: "Saturday")
        case .sunday:
            return NSLocalizedString("Sunday", comment: "Sunday")
        }
    }
}

enum TimeOfTheDay: Int, Codable {
    case midday = 0
    case evening = 1
    
    func name() -> String {
        switch self {
        case .midday:
            return NSLocalizedString("Midday", comment: "Midday")
        case .evening:
            return NSLocalizedString("Evening", comment: "Evening")
        }
    }
    
    func image() -> Image {
        switch self {
        case .midday:
            return Image(systemName: "sun.max.fill").resizable()
        case .evening:
            return Image(systemName: "moon.fill").resizable()
        }
    }
}

enum WichWeekIsIt {
    case thisWeek
    case nextWeek
    
    func name() -> String {
        switch self {
        case .thisWeek:
            return NSLocalizedString("this_week", comment: "This week")
        case .nextWeek:
            return NSLocalizedString("next_week", comment: "Next week")
        }
    }
}
