//
//  DayPlan.swift
//  Meal
//
//  Created by Loic D on 10/12/2022.
//

import Foundation
import SwiftUI

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
    
    func append(_ meal: Meal, time: TimeOfTheDay) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if time == .midday && self.midday.count < 3 {
                self.midday.append(meal.new())
                self.objectWillChange.send()
            }
            if time == .evening && self.evening.count < 3 {
                self.evening.append(meal.new())
                self.objectWillChange.send()
            }
        }
    }
    
    func remove(_ meal: Meal, time: TimeOfTheDay) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if time == .midday {
                let index = self.midday.firstIndex(where: {$0.id == meal.id && $0.name == meal.name})
                guard let index = index else { return }
                self.midday.remove(at: index)
            } else if time == .evening {
                let index = self.evening.firstIndex(where: {$0.id == meal.id && $0.name == meal.name})
                guard let index = index else { return }
                self.evening.remove(at: index)
            }
            self.objectWillChange.send()
        }
    }
    
    static func ==(lhs: DayPlan, rhs: DayPlan) -> Bool {
        return lhs.id == rhs.id && lhs.midday.count == rhs.midday.count && lhs.evening.count == rhs.evening.count
    }
}
