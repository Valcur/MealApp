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
    
    func addWeekToCalendar(weekPlan: WeekPlan) {
        for day in weekPlan.week {
            addDayToCalendar(day: day)
        }
    }

    private func addDayToCalendar(day: DayPlan) {
        
        guard day.midday.count > 0 else { return }
        
        let eventStore : EKEventStore = EKEventStore()
        
        // Only execute this once, a changer
        eventStore.requestAccess(to: .event) { (granted, error) in
          
          if (granted) && (error == nil) {
              print("granted \(granted)")
              print("error \(String(describing: error))")
              
              let event:EKEvent = EKEvent(eventStore: eventStore)
              
              event.title = day.midday[0].name
              event.startDate = day.date
              event.endDate = day.date + 1 * 60 * 60
              event.notes = "This is a note"
              event.calendar = eventStore.defaultCalendarForNewEvents
              do {
                  try eventStore.save(event, span: .thisEvent)
              } catch let error as NSError {
                  print("failed to save event with error : \(error)")
              }
              print("Saved Event")
          }
          else{
              print("failed to save event with error : \(String(describing: error)) or access not granted")
          }
        }
    }
}
