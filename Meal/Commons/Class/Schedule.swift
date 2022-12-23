//
//  Schedule.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import Foundation

class Schedule: Identifiable, Hashable, Codable {
    var id = UUID()
    var meal: Meal
    var days: [WeekDays]
    var time: [TimeOfTheDay]
    
    init(meal: Meal, days: [WeekDays], time: [TimeOfTheDay]) {
        self.meal = meal
        self.days = days
        self.time = time
    }
    
    static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
}

struct Schedules: Codable {
    var schedules: [Schedule]
}

struct EventIdentifiers: Codable {
    var eventIdentifiers: [String]
}
