//
//  MealsDataController+Schedule.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import Foundation

extension MealsDataController {
    func saveNewSchedule(schedule: Schedule) {

    }
    
    func saveSchedules(schedules: Schedules) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(schedules) {
            userDefaults.set(data, forKey: "\(SCHEDULE_KEY)")
        }
    }
    
    func loadSchedules() -> Schedules {
        if let data = userDefaults.object(forKey: "\(SCHEDULE_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let schedules = try? decoder.decode(Schedules.self, from: data) {
                return schedules
            }
        }
        return Schedules(schedules: [])
    }
}
