//
//  MealsDataController+Calendar.swift
//  Meal
//
//  Created by Loic D on 21/12/2022.
//

import Foundation

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
}
