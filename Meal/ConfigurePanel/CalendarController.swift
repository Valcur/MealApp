//
//  CalendarController.swift
//  Meal
//
//  Created by Loic D on 20/12/2022.
//

import Foundation
import EventKit
import Contacts

// G PERDU MA SAVE QUAND J'AI ACTIVE LE CLOUD

class CalendarController {
    private let data = MealsDataController()
    let eventStore: EKEventStore = EKEventStore()
    var calendars: Set<EKCalendar>?
    var accessAllowed = false
    var allSavedEventIdentifiers: [String] = [] // Tous les event enregistré par l'app
    var calendarUsage: CalendarUsage
    
    init() {
        // Need access to contact or some users will crash
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { (granted, error) in
            
        }
        
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
    
    func addWeeksToCalendar(thisWeek: WeekPlan, nextWeek: WeekPlan) {
        removeAllEventsFromCalendar()
        allSavedEventIdentifiers = []
        guard calendarUsage.useCalendar else { return }
        for day in thisWeek.week {
            addDayToCalendar(day: day)
        }
        for day in nextWeek.week {
            addDayToCalendar(day: day)
        }
        data.saveEventIdentifiers(eventIdentifiers: allSavedEventIdentifiers)
    }
    
    private func removeAllEventsFromCalendar() {
        guard accessAllowed else {
            print("failed to remove all events with error : access not granted")
            return
        }
        
        if true {
            removeAllEventsMatchingPredicate()
        } else {
            for eventIdentifier in allSavedEventIdentifiers {
                let event = eventStore.event(withIdentifier: eventIdentifier)
                print("trying to remove ->\(eventIdentifier)<-")
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
    }
    
    func removeAllEventsMatchingPredicate() {
        let startDate = NSDate().addingTimeInterval(60*60*24*(-7))
        let endDate = NSDate().addingTimeInterval(60*60*24*14)

        if calendars == nil || calendars!.first == nil {
            print("Error : no calendar to remove event")
            return
        }
        
        let predicate2 = eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: [calendars!.first!])

        print("startDate:\(startDate) endDate:\(endDate)")
        let eV = eventStore.events(matching: predicate2) as [EKEvent]

        for i in eV {
            do{
                (try eventStore.remove(i, span: EKSpan.thisEvent, commit: true))
            }
            catch let error {
                print("Error removing events: ", error)
            }
        }
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
        if meal.sides != nil && meal.sides!.count > 0 {
            event.title = "\(meal.name) \(Side.sidesNameDescription(meal.sides!).lowercased())"
        } else {
            event.title = meal.name
        }
        event.title = (event.title.first?.uppercased() ?? "") + event.title.dropFirst()
        event.startDate = start
        event.endDate = end
        if let notes = meal.notes {
            event.notes = notes
        }
        event.calendar = calendars?.first
        
        do {
            try eventStore.save(event, span: .thisEvent)
            self.allSavedEventIdentifiers.append(event.eventIdentifier)
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
        //print("Added \(meal.name) event")
    }
}
