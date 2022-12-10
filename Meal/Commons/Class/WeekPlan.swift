//
//  weekPlan.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import Foundation

// L'organisation d'une semaine
class WeekPlan: ObservableObject {
    @Published var week: [DayPlan]
    
    init() {
        week = [
            DayPlan(day: .monday, date: Date(), midday: [], evening: []),
            DayPlan(day: .tuesday, date: Date(), midday: [], evening: []),
            DayPlan(day: .wednesday, date: Date(), midday: [], evening: []),
            DayPlan(day: .thursday, date: Date(), midday: [], evening: []),
            DayPlan(day: .friday, date: Date(), midday: [], evening: []),
            DayPlan(day: .saturday, date: Date(), midday: [], evening: []),
            DayPlan(day: .sunday, date: Date(), midday: [], evening: [])
        ]
    }
    
    func dayName() -> String {
        return "Monday"
    }
    
    func append(_ meal: Meal, day: WeekDays, time: TimeOfTheDay) {
        if time == .midday {
            week[day.rawValue].midday.append(meal)
        } else if time == .evening {
            week[day.rawValue].evening.append(meal)
        }
    }
}

enum WeekDays: Int {
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
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
}

enum TimeOfTheDay: Int {
    case midday = 0
    case evening = 1
}
