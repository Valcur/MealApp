//
//  CalendarController.swift
//  Meal
//
//  Created by Loic D on 20/12/2022.
//

import Foundation
import EventKit

class CalendarController {
          
    // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
    
    private let data = MealsDataController()
    let eventStore: EKEventStore = EKEventStore()
    var calendars: Set<EKCalendar>?
    var accessAllowed = false
    var allSavedEventIdentifiers: [String] = [] // Tous les event enregistré par l'app
    var calendarUsage: CalendarUsage
    
    init() {
        calendarUsage = data.loadCalendarUsage()
        eventStore.requestAccess(to: .event) { (granted, error) in
            self.accessAllowed = (granted) && (error == nil)
        }
        
        calendars = []
        if calendarUsage.calendarIdentifier != CalendarUsage.defaultCalendarIdentifier {
            if let calendar = eventStore.calendar(withIdentifier: calendarUsage.calendarIdentifier) {
                calendars?.insert(calendar)
            }
        } else {
            if let calendar = eventStore.defaultCalendarForNewEvents {
                calendars?.insert(calendar)
            }
        }
        
        allSavedEventIdentifiers = data.loadEventIdentifiers().eventIdentifiers
    }
    
    func addWeekToCalendar(weekPlan: WeekPlan) {
        removeAllEventsFromCalendar()
        allSavedEventIdentifiers = []
        guard calendarUsage.useCalendar else { return }
        for day in weekPlan.week {
            addDayToCalendar(day: day)
        }
        data.saveEventIdentifiers(eventIdentifiers: allSavedEventIdentifiers)
    }
    
    private func removeAllEventsFromCalendar() {
        guard accessAllowed else {
            print("failed to remove all events with error : access not granted")
            return
        }
        
        for eventIdentifier in allSavedEventIdentifiers {
            let event = eventStore.event(withIdentifier: eventIdentifier)
            if let event = event {
                do {
                    try eventStore.remove(event, span: EKSpan.thisEvent, commit: true)
                } catch {
                    print("failed to remove event with error : \(error)")
                }
            }
        }
        
        print("Removed \(allSavedEventIdentifiers.count) events")
    }

    private func addDayToCalendar(day: DayPlan) {
        guard accessAllowed else {
            print("failed to save event with error : access not granted")
            return
        }
        
        for i in 0..<day.midday.count {
            let startAndEnd = getMealStartAndEndDate(date: day.date, time: .midday, rank: i, total: day.midday.count)
            saveMeal(day.midday[i], start: startAndEnd.0, end: startAndEnd.1)
        }
        
        for i in 0..<day.evening.count {
            let startAndEnd = getMealStartAndEndDate(date: day.date, time: .evening, rank: i, total: day.evening.count)
            saveMeal(day.evening[i], start: startAndEnd.0, end: startAndEnd.1)
        }
    }
    
    private func getMealStartAndEndDate(date: Date, time: TimeOfTheDay, rank: Int, total: Int) -> (Date, Date) {
        let cal = Calendar.current
        
        let middayTime = cal.date(bySettingHour: calendarUsage.middayHour.hour, minute: calendarUsage.middayHour.minutes, second: 0, of: date) ?? date
        let eveningTime = cal.date(bySettingHour: calendarUsage.eveningHour.hour, minute: calendarUsage.eveningHour.minutes, second: 0, of: date) ?? date
        
        let startDate = time == .midday ? middayTime : eveningTime
        //let duration = (30 / total) * 60
        //startDate =  startDate + (Double(rank * duration))
        //let endDate = startDate + Double(duration)
        let duration = 30 * 60
        let endDate = startDate + Double(duration)
        
        return (startDate, endDate)
    }
    
    private func saveMeal(_ meal: Meal, start: Date, end: Date) {
        guard calendars!.count > 0 else { return }
        let event:EKEvent = EKEvent(eventStore: eventStore)

        event.title = meal.name
        event.startDate = start
        event.endDate = end
        //event.notes = "This is a note"
        event.calendar = calendars?.first
        
        do {
            try eventStore.save(event, span: .thisEvent)
            self.allSavedEventIdentifiers.append(event.eventIdentifier)
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
        print("Added \(meal.name) event")
    }
}
