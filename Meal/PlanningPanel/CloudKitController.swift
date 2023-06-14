//
//  CloudKitController.swift
//  Meal
//
//  Created by Loic D on 11/06/2023.
//

import Foundation
import CloudKit

class CloudKitController: ObservableObject {
    private var database: CKDatabase
    private var container: CKContainer
    var sharedWeekPlanId: String = SharedWeekPlanIdError.notLoaded.rawValue
    //private let isPremium: Bool = true
    @Published var weeksIniCompleted = false
    @Published var eventsIniCompleted = false
    
    init() {
        self.container = CKContainer(identifier: "iCloud.BurningBeard.Meal.MealPlanning")
        self.database = self.container.publicCloudDatabase
        loadSharedWeekPlanId()
    }
    
    func getWeekPlanningFromCloud(recordType: String, completion: @escaping (WeekPlan?) -> ()) {
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            } else {
                guard let records = ckRecords else {
                    completion(nil)
                    return
                }

                guard let record = records.first else {
                    completion(nil)
                    return
                }

                guard let weekPlanString = record.value(forKey: "weekPlan") as? String else { return }
                let weekPlan = self.weekPlanStringToWeekPlan(weekPlanString, whichWeek: recordType == RecordType.thisWeekPlan.rawValue ? .thisWeek : .nextWeek)
                completion(weekPlan)
            }
        }
    }
    
    private func weekPlanStringToWeekPlan(_ text: String, whichWeek: WichWeekIsIt) -> WeekPlan {
        let lines = text.split(whereSeparator: \.isNewline)
        let weekPlan = WeekPlan(whichWeek)
        var currentWeekDay: WeekDays = .monday
        var currentTimeOfTheDay: TimeOfTheDay = .midday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z'"
        var currentDate: Date = Date()
        
        var i = 2
        while i < lines.count {
            if lines[i] == "monday" {
                currentWeekDay = .monday
            } else if lines[i] == "tuesday" {
                currentWeekDay = .tuesday
            } else if lines[i] == "wednesday" {
                currentWeekDay = .wednesday
            } else if lines[i] == "thursday" {
                currentWeekDay = .thursday
            } else if lines[i] == "friday" {
                currentWeekDay = .friday
            } else if lines[i] == "saturday" {
                currentWeekDay = .saturday
            } else if lines[i] == "sunday" {
                currentWeekDay = .sunday
            } else if lines[i] == "##DATE##" {
                let dateStr = String(lines[i + 1])
                currentDate = dateFormatter.date(from: dateStr) ?? Date()
                i += 1
                weekPlan.week[currentWeekDay.rawValue] = DayPlan(day: currentWeekDay, date: currentDate, midday: [], evening: [])
            } else if lines[i] == "##MIDDAY##" {
                currentTimeOfTheDay = .midday
            } else if lines[i] == "##EVENING##" {
                currentTimeOfTheDay = .evening
            } else if lines[i] == "##MEAL##" {
                let id = Int(lines[i + 1]) ?? 0
                let name = String(lines[i + 2])
                let type = Int(lines[i + 3])
                var sides: [Side] = []
                let sidesKeys = String(lines[i + 4]).components(separatedBy: "/")
                for sidesKey in sidesKeys {
                    if sidesKey.count > 1 {
                        sides.append(Side(key: sidesKey))
                    }
                }
                let notes = String(lines[i + 5])
                let meal = Meal(id: id,
                                name: name,
                                type: type == 1 ? .meat : (type == 2 ? .vegan : .outside),
                                sides: sides,
                                notes: notes == " " ? nil : notes
                )
                i += 5
                weekPlan.append(meal, day: currentWeekDay, time: currentTimeOfTheDay)
            }
            
            i += 1
        }
        
        return weekPlan
    }
    
    func saveWeeksPlanningToCloud(thisWeek: WeekPlan, nexWeek: WeekPlan) {
        saveWeekPlanningToCloud(recordType: RecordType.thisWeekPlan.rawValue, plan: thisWeek)
        saveWeekPlanningToCloud(recordType: RecordType.nextWeekPlan.rawValue, plan: nexWeek)
    }
    
    private func saveWeekPlanningToCloud(recordType: String, plan: WeekPlan) {
        var text = "\(recordType)\n\n"
        for dayPlan in plan.week {
            text += "\(dayPlan.day)\n"
            text += "##DATE##\n"
            text += "\(dayPlan.date)\n"
            
            text += "##MIDDAY##\n"
            for midday in dayPlan.midday {
                text += "##MEAL##\n"
                text += "\(midday.id)\n"
                text += "\(midday.name)\n"
                text += "\(midday.type == .meat ? 1 : (midday.type == .vegan ? 2 : 3))\n"
                if let sides = midday.sides {
                    for side in sides {
                        text += "\(side.imageName)/"
                    }
                }
                text += " \n"
                text += "\(midday.notes ?? " ")\n"
            }
            
            text += "##EVENING##\n"
            for evening in dayPlan.evening {
                text += "##MEAL##\n"
                text += "\(evening.id)\n"
                text += "\(evening.name)\n"
                text += "\(evening.type == .meat ? 1 : (evening.type == .vegan ? 2 : 3))\n"
                if let sides = evening.sides {
                    for side in sides {
                        text += "\(side.imageName)/"
                    }
                }
                text += " \n"
                text += "\(evening.notes ?? " ")\n"
            }
        }
        
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
            } else {
                guard let records = ckRecords else {
                    return
                }

                guard let record = records.first else {
                    return
                }
                
                record["weekPlan"] = text

                self.database.save(record) { _, error in
                    if let error = error {
                        print(error)
                    } else {
                        print("Week updated successfully")
                    }
                }
            }
        }
        /*
        let record = CKRecord(recordType: recordType)
        record.setValue(sharedWeekPlanId, forKey: "id")
        record.setValue(text, forKey: "weekPlan")
        
        self.database.save(record) { newRecord, error in
            if let error = error {
                print(error)
            } else {
                if let _ = newRecord {
                    print("Week saved")
                }
            }
        }*/
    }
    
    func getEventIdentifiersFromCloud(completion: @escaping (EventIdentifiers?) -> ()) {
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: RecordType.eventIdentifiers.rawValue, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            } else {
                guard let records = ckRecords else {
                    completion(nil)
                    return
                }

                guard let record = records.first else {
                    completion(nil)
                    return
                }

                guard let eventString = record.value(forKey: "eventIdentifiers") as? String else { return }
                let eventIdentifier = self.eventStringToEventIdentifers(eventString)
                completion(eventIdentifier)
            }
        }
    }
    
    private func eventStringToEventIdentifers(_ eventString: String) -> EventIdentifiers {
        let events = eventString.split(whereSeparator: \.isNewline)
        var eventIdentifiers = EventIdentifiers(eventIdentifiers: [])
        for ev in events {
            let event = String(ev)
            if event.count > 1 {
                eventIdentifiers.eventIdentifiers.append(event)
            }
        }
        return eventIdentifiers
    }
    
    func saveEventIdentifiersToCloud(eventIdentifiers: [String]) {
        var eventsString = ""
        for event in eventIdentifiers {
            eventsString += "\(event)\n"
        }
        
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: RecordType.eventIdentifiers.rawValue, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
            } else {
                guard let records = ckRecords else {
                    return
                }

                guard let record = records.first else {
                    return
                }
                
                record["eventIdentifiers"] = eventsString

                self.database.save(record) { _, error in
                    if let error = error {
                        print(error)
                    } else {
                        print("Events updated successfully")
                    }
                }
            }
        }
        /*
        let record = CKRecord(recordType: RecordType.eventIdentifiers.rawValue)
        record.setValue(sharedWeekPlanId, forKey: "id")
        record.setValue(eventsString, forKey: "eventIdentifiers")
        
        self.database.save(record) { newRecord, error in
            if let error = error {
                print(error)
            } else {
                if let _ = newRecord {
                    print("Events saved")
                }
            }
        }*/
    }
    
    func loadSharedWeekPlanId() {
        sharedWeekPlanId = UserDefaults.standard.string(forKey: "SHARED_WEEK_PLAN_ID") ?? SharedWeekPlanIdError.noId.rawValue
        sharedWeekPlanId = "aeaereararzerjzehruezhr"
    }
    
    func isIniComplete() -> Bool {
        return weeksIniCompleted && eventsIniCompleted
    }
}

enum RecordType: String {
    case thisWeekPlan = "ThisWeekPlanning"
    case nextWeekPlan = "NextWeekPlanning"
    case eventIdentifiers = "EventIdentifiers"
}

enum SharedWeekPlanIdError: String {
    case noId = "NO_ID"
    case notLoaded = "NOT_LOADED"
}
