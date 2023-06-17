//
//  MealsDataController+WeekPlaning.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import Foundation

extension MealsDataController {
    func saveWeek(weekPlan: WeekPlan, forWeek: WichWeekIsIt) {
        let weekKey = forWeek == .thisWeek ? THIS_WEEK_KEY : NEXT_WEEK_KEY
        
        for day in weekPlan.week {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(day) {
                userDefaults.set(data, forKey: "\(weekKey)_\(DAYPLAN_KEY)_\(day.day.rawValue)")
            }
        }
        
        savePlanningModificationDate(forWeek: forWeek)
    }
    
    func loadWeek(forWeek: WichWeekIsIt) -> WeekPlan {
        let weekKey = forWeek == .thisWeek ? THIS_WEEK_KEY : NEXT_WEEK_KEY
        let weekDays: [WeekDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        var dayPlans: [DayPlan] = []
        for weekDay in weekDays {
            let dayPlan = loadDayPlan(weekDay: weekDay, weekKey: weekKey)
            if dayPlan != nil {
                dayPlans.append(dayPlan!)
            } else {
                print("ERROR trying to load \(weekDay.name()), returning default week")
                return WeekPlan(forWeek)
            }
        }
        
        let wp = WeekPlan(forWeek)
        wp.week = dayPlans
        return wp
    }
    
    private func loadDayPlan(weekDay: WeekDays, weekKey: String) -> DayPlan? {
        if let data = userDefaults.object(forKey: "\(weekKey)_\(DAYPLAN_KEY)_\(weekDay.rawValue)") as? Data {
            let decoder = JSONDecoder()
            if let dayPlan = try? decoder.decode(DayPlan.self, from: data) {
                return dayPlan
            }
        }
        
        return nil
    }
    
    private func savePlanningModificationDate(forWeek: WichWeekIsIt) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z'"
        var currentDate = dateFormatter.string(from: Date())
        
        if forWeek == .thisWeek {
            userDefaults.set(currentDate, forKey: THIS_WEEK_LAST_MODIFY_KEY)
        } else {
            userDefaults.set(currentDate, forKey: NEXT_WEEK_LAST_MODIFY_KEY)
        }
    }
    
    func getPlanningModificationDate(forWeek: WichWeekIsIt) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z'"
        
        var dateString = ""
        if forWeek == .thisWeek {
            dateString = userDefaults.string(forKey: THIS_WEEK_LAST_MODIFY_KEY) ?? ""
        } else {
            dateString = userDefaults.string(forKey: NEXT_WEEK_LAST_MODIFY_KEY) ?? ""
        }
        
        if dateString == "" {
            return nil
        }
        
        return dateFormatter.date(from: dateString) ?? nil
    }
}
