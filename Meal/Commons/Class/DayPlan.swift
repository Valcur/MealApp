//
//  DayPlan.swift
//  Meal
//
//  Created by Loic D on 10/12/2022.
//

import Foundation

// L'organisation d'une journée
class DayPlan: Equatable, Identifiable, ObservableObject, Codable {
    var id = UUID()
    let day: WeekDays
    let date: Date
    var midday: [Meal]
    var evening: [Meal]
    
    init(day: WeekDays, date: Date, midday: [Meal], evening: [Meal]) {
        self.day = day
        self.date = date
        self.midday = midday
        self.evening = evening
    }
    
    static func ==(lhs: DayPlan, rhs: DayPlan) -> Bool {
        return lhs.id == rhs.id && lhs.midday.count == rhs.midday.count && lhs.evening.count == rhs.evening.count
    }
}
