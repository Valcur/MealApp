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
    let eventStore : EKEventStore = EKEventStore()
    var accessAllowed = false
    var allSavedEventIdentifiers: [String] = [] // Tous les event enregistré par l'app
    
    init() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            self.accessAllowed = (granted) && (error == nil)
        }
        allSavedEventIdentifiers = data.loadEventIdentifiers().eventIdentifiers
    }
    
    func addWeekToCalendar(weekPlan: WeekPlan) {
        removeAllEventsFromCalendar()
        allSavedEventIdentifiers = []
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
        let cal = Calendar(identifier: .gregorian)
        let midnight = cal.startOfDay(for: date)
        
        var startDate = time == .midday ? midnight + 13 * 60 * 60 : midnight + 20 * 60 * 60
        let duration = (30 / total) * 60
        startDate =  startDate + (Double(rank * duration))
        let endDate = startDate + Double(duration)
        
        return (startDate, endDate)
    }
    
    private func saveMeal(_ meal: Meal, start: Date, end: Date) {
        let event:EKEvent = EKEvent(eventStore: eventStore)

        event.title = meal.name
        event.startDate = start
        event.endDate = end
        //event.notes = "This is a note"
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            self.allSavedEventIdentifiers.append(event.eventIdentifier)
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
        print("Added \(meal.name) event")
    }
}
