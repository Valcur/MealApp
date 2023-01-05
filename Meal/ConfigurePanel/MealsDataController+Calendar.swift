//
//  MealsDataController+Calendar.swift
//  Meal
//
//  Created by Loic D on 21/12/2022.
//

import Foundation
import EventKit

extension MealsDataController {
    func saveEventIdentifiers(eventIdentifiers: [String]) {
        let events = EventIdentifiers(eventIdentifiers: eventIdentifiers)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(events) {
            userDefaults.set(data, forKey: "\(EVENT_KEY)")
        }
    }
    
    func loadEventIdentifiers() -> EventIdentifiers {
        if let data = userDefaults.object(forKey: "\(EVENT_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let events = try? decoder.decode(EventIdentifiers.self, from: data) {
                return events
            }
        }
        return EventIdentifiers(eventIdentifiers: [])
    }
    
    func saveCalendarUsage(calendarUsage: CalendarUsage) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(calendarUsage) {
            userDefaults.set(data, forKey: "\(CALENDAR_USAGE_KEY)")
        }
    }
    
    func loadCalendarUsage() -> CalendarUsage {
        if let data = userDefaults.object(forKey: "\(CALENDAR_USAGE_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let calendar = try? decoder.decode(CalendarUsage.self, from: data) {
                return calendar
            }
        }
        return CalendarUsage(useCalendar: false, calendarIdentifier: CalendarUsage.defaultCalendarIdentifier, middayHour: Hour(hour: 13, minutes: 0), eveningHour: Hour(hour: 19, minutes: 45))
    }
}

struct CalendarUsage: Codable {
    var useCalendar: Bool
    var calendarIdentifier: String
    var middayHour: Hour
    var eveningHour: Hour
    
    static let defaultCalendarIdentifier = "setToDefaultCalendarForNewEvents"
}

struct Hour: Codable {
    var hour: Int
    var minutes: Int
}
