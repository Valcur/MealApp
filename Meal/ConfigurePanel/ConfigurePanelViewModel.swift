//
//  ConfigurePanelViewModel.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import Foundation

class ConfigurePanelViewModel: ObservableObject {
    let calendarController = CalendarController()
    weak var planningPanelVM: PlanningPanelViewModel?
    @Published var schedules: [Schedule] = []
    
    init(planningPanelVM: PlanningPanelViewModel) {
        self.planningPanelVM = planningPanelVM
        self.schedules.append(Schedule(meal: Meal.LeftOVer, days: [.friday, .saturday], time: [.evening]))
    }
}

extension ConfigurePanelViewModel {
    func newSchedule(meal: Meal, selectedDays: [Bool], selectedHours: [Bool]) {
        let days = getDaysFromSelectedDays(selectedDays)
        let time = getTimeFromSelectedHours(selectedHours)
        
        schedules.append(Schedule(meal: meal, days: days, time: time))
        print("You now have \(schedules.count) schedules")
    }
    
    func editSchedule(meal: Meal, selectedDays: [Bool], selectedHours: [Bool], schedule: Schedule) {
        schedule.meal = meal
        schedule.days = getDaysFromSelectedDays(selectedDays)
        schedule.time = getTimeFromSelectedHours(selectedHours)
        
        let index = schedules.firstIndex(where: {$0.id == schedule.id})
        if index != nil {
            schedules[index!] = schedule
        }
    }
    
    private func getDaysFromSelectedDays(_ selectedDays: [Bool]) -> [WeekDays] {
        var days: [WeekDays] = []
        let allDays: [WeekDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        for day in allDays {
            if selectedDays[day.rawValue] == true {
                days.append(day)
            }
        }
        
        return days
    }
    
    private func getTimeFromSelectedHours(_ selectedHours: [Bool]) -> [TimeOfTheDay] {
        var time: [TimeOfTheDay] = []
        if selectedHours[0] {
            time.append(.midday)
        }
        if selectedHours[1] {
            time.append(.evening)
        }
        
        return time
    }
}
