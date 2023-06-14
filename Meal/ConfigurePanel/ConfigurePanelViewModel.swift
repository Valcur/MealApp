//
//  ConfigurePanelViewModel.swift
//  Meal
//
//  Created by Loic D on 19/12/2022.
//

import Foundation

class ConfigurePanelViewModel: ObservableObject {
    var calendarController: CalendarController
    weak var planningPanelVM: PlanningPanelViewModel?
    private let data = MealsDataController()
    let cloudKitController: CloudKitController
    @Published var schedules: [Schedule]
    
    init(cloudKitController: CloudKitController) {
        self.schedules = data.loadSchedules().schedules
        self.cloudKitController = cloudKitController
        self.calendarController = CalendarController(cloudKitController: cloudKitController)
    }
}

extension ConfigurePanelViewModel {
    func newSchedule(meal: Meal, selectedDays: [Bool], selectedHours: [Bool]) {
        let days = getDaysFromSelectedDays(selectedDays)
        let time = getTimeFromSelectedHours(selectedHours)
        
        schedules.append(Schedule(meal: meal, days: days, time: time))

        for day in days {
            for t in time {
                planningPanelVM?.thisWeek.append(meal, day: day, time: t)
                planningPanelVM?.nextWeek.append(meal, day: day, time: t)
            }
        }
        
        data.saveSchedules(schedules: Schedules(schedules: schedules))
    }
    
    func editSchedule(meal: Meal, selectedDays: [Bool], selectedHours: [Bool], schedule: Schedule) {
        unapplySchedule(schedule: schedule)
        
        schedule.meal = meal
        schedule.days = getDaysFromSelectedDays(selectedDays)
        schedule.time = getTimeFromSelectedHours(selectedHours)
        
        let index = schedules.firstIndex(where: {$0.id == schedule.id})
        if index != nil {
            schedules[index!] = schedule
        }
        
        for day in schedule.days {
            for t in schedule.time {
                planningPanelVM?.thisWeek.append(meal, day: day, time: t)
                planningPanelVM?.nextWeek.append(meal, day: day, time: t)
            }
        }
        
        data.saveSchedules(schedules: Schedules(schedules: schedules))
    }
    
    func removeSchedule(schedule: Schedule) {
        unapplySchedule(schedule: schedule)
        schedules.removeAll(where: {$0.id == schedule.id})
        data.saveSchedules(schedules: Schedules(schedules: schedules))
    }
    
    func applyAllSchedulesTo(_ weekPlan: WeekPlan) {
        for schedule in schedules {
            applyScheduleTo(weekPlan, schedule: schedule)
        }
    }
    
    private func unapplySchedule(schedule: Schedule) {
        for day in schedule.days {
            for t in schedule.time {
                planningPanelVM?.thisWeek.remove(schedule.meal, day: day, time: t)
                planningPanelVM?.nextWeek.remove(schedule.meal, day: day, time: t)
            }
        }
    }
    
    private func applyScheduleTo(_ weekPlan: WeekPlan, schedule: Schedule) {
        for day in schedule.days {
            for t in schedule.time {
                weekPlan.append(schedule.meal, day: day, time: t)
            }
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

extension ConfigurePanelViewModel {
    func saveCalendarUsage(useCalendar: Bool, calendarIdentifier: String, middayDate: Date, eveningDate: Date) {
        let calendar = Calendar.current
        let calendarUsage = CalendarUsage(useCalendar: useCalendar,
                                          calendarIdentifier: calendarIdentifier,
                                          middayHour: Hour(hour: calendar.component(.hour, from: middayDate),
                                                           minutes: calendar.component(.minute, from: middayDate)),
                                          eveningHour: Hour(hour: calendar.component(.hour, from: eveningDate),
                                                            minutes: calendar.component(.minute, from: eveningDate))
                                         )
        calendarController.calendarUsage = calendarUsage
        calendarController.addWeeksToCalendar(thisWeek: planningPanelVM!.thisWeek, nextWeek: planningPanelVM!.nextWeek)
        data.saveCalendarUsage(calendarUsage: calendarUsage)
    }
    
    func loadCalendarUsage() -> CalendarUsage {
        return data.loadCalendarUsage()
    }
}
