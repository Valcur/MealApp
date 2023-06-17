//
//  CloudKitController.swift
//  Meal
//
//  Created by Loic D on 11/06/2023.
//

import Foundation
import CloudKit
import SwiftUI

// MARCHE PAS SI LE MEC UTILISE PAS LE CLOUD, LOGO CLOUD TOUJOURS VISIBLE

class CloudKitController: ObservableObject {
    private let data = MealsDataController()
    private var database: CKDatabase
    private var container: CKContainer
    @Published var thisWeekIniCompleted = false
    @Published var nextWeekIniCompleted = false
    @Published var cloudSyncStatus: CloudSyncStatus = .completed
    private var weekSavingProgress = 0
    var sharedWeekPlanId: String = SharedWeekPlanIdError.notLoaded.rawValue
    
    @Published var userUUID: String = ""
    @Published var sharedPlanningUUID: String = ""
    @Published var shareYourPlanning = false
    @Published var useSharedPlanning = false
    
    init() {
        self.container = CKContainer(identifier: "iCloud.BurningBeard.Meal.MealPlanning")
        self.database = self.container.publicCloudDatabase
        iniUserPreferences()
        updateSharedWeekPlanId()
    }
    
    func iniUserPreferences() {
        let userDefaults = UserDefaults.standard
        
        userUUID = userDefaults.string(forKey: CloudPreferenceKeys.userUUID.rawValue) ?? UUID().uuidString
        userDefaults.set(userUUID, forKey: CloudPreferenceKeys.userUUID.rawValue)
        
        sharedPlanningUUID = userDefaults.string(forKey: CloudPreferenceKeys.sharedUUID.rawValue) ?? ""
        shareYourPlanning = userDefaults.bool(forKey: CloudPreferenceKeys.shareYourPlanning.rawValue)
        useSharedPlanning = userDefaults.bool(forKey: CloudPreferenceKeys.useSharedPlanning.rawValue)
    }
    
    func getWeekPlanningFromCloud(recordType: String, localPlanning: WeekPlan, completion: @escaping (WeekPlan?) -> ()) {
        self.setCloudSyncStatus(.inProgress)
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(nil)
                self.setCloudSyncStatus(.error)
                return
            } else {
                guard let records = ckRecords else {
                    completion(nil)
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                guard let record = records.first else {
                    completion(nil)
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                let localModificationDate: Date? = self.data.getPlanningModificationDate(forWeek: recordType == RecordType.thisWeekPlan.rawValue ? .thisWeek : .nextWeek)
                let cloudModificationDate: Date? = record.modificationDate
                if let cloudModificationDate = cloudModificationDate, let localModificationDate = localModificationDate {
                    if localModificationDate > cloudModificationDate {
                        completion(localPlanning)
                        self.setCloudSyncStatus(.completed)
                        print("Local is more recent than cloud, using local for \(recordType)")
                        return
                    } else {
                        print("Cloud is more recent than local, using cloud for \(recordType)")
                    }
                } else {
                    if cloudModificationDate == nil {
                        print("Error : cloud modification date is nil for \(recordType)")
                    } else if localModificationDate == nil {
                        print("Error : local modification date is nil for \(recordType)")
                    }
                }
                
                guard let weekPlanString = record.value(forKey: "weekPlan") as? String else { return }
                let weekPlan = self.weekPlanStringToWeekPlan(weekPlanString, whichWeek: recordType == RecordType.thisWeekPlan.rawValue ? .thisWeek : .nextWeek)
                completion(weekPlan)
                self.setCloudSyncStatus(.completed)
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
        weekSavingProgress = 0
        saveWeekPlanningToCloud(recordType: RecordType.thisWeekPlan.rawValue, plan: thisWeek)
        saveWeekPlanningToCloud(recordType: RecordType.nextWeekPlan.rawValue, plan: nexWeek)
    }
    
    private func saveWeekPlanningToCloud(recordType: String, plan: WeekPlan) {
        self.setCloudSyncStatus(.inProgress)
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
                self.setCloudSyncStatus(.error)
            } else {
                guard let records = ckRecords else {
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                guard let record = records.first else {
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                record["weekPlan"] = text
                
                self.database.save(record) { _, error in
                    if let error = error {
                        print(error)
                        self.setCloudSyncStatus(.error)
                        self.weekSavingProgress = -1
                    } else {
                        print("Week updated successfully")
                        self.weekSavingProgress += 1
                        if self.weekSavingProgress == 2 {
                            self.setCloudSyncStatus(.completed)
                        }
                    }
                }
            }
        }
    }
    
    func isIniComplete() -> Bool {
        return thisWeekIniCompleted && nextWeekIniCompleted
    }
    
    private func setCloudSyncStatus(_ status: CloudSyncStatus) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.cloudSyncStatus = status
            }
        }
    }
}

// Collaboration Panel

extension CloudKitController {
    func createWeekPlanningRecordIfNeeded(completion: @escaping (Bool) -> ()) {
        // Check if both exist, create if it doesn't

        let predicate = NSPredicate(format: "id == %@", userUUID)
        var recordCount = 0
        
        // Check if this week exist
        let queryThisWeek = CKQuery(recordType: RecordType.thisWeekPlan.rawValue, predicate: predicate)
        database.perform(queryThisWeek, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                guard let records = ckRecords else {
                    completion(false)
                    return
                }

                if records.first != nil {
                    print("Record already exist")
                    recordCount += 1
                    if recordCount == 2 { completion(true) }
                } else {
                    self.createEmptyRecord(recordType: RecordType.thisWeekPlan.rawValue, completion: { success in
                        if success {
                            recordCount += 1
                            if recordCount == 2 { completion(true) }
                        } else {
                            completion(false)
                        }
                    })
                }
            }
        }
        
        // Check if next week exist
        let queryNextWeek = CKQuery(recordType: RecordType.nextWeekPlan.rawValue, predicate: predicate)
        self.database.perform(queryNextWeek, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                guard let records = ckRecords else {
                    completion(false)
                    return
                }

                if records.first != nil {
                    print("Record already exist")
                    recordCount += 1
                    if recordCount == 2 { completion(true) }
                } else {
                    self.createEmptyRecord(recordType: RecordType.nextWeekPlan.rawValue, completion: { success in
                        if success {
                            recordCount += 1
                            if recordCount == 2 { completion(true) }
                        } else {
                            completion(false)
                        }
                    })
                }
            }
        }
    }
    
    private func createEmptyRecord(recordType: String, completion: @escaping (Bool) -> ()) {
        let record = CKRecord(recordType: recordType)
        record.setValue(userUUID, forKey: "id")
        record.setValue("", forKey: "weekPlan")
        
        self.database.save(record) { newRecord, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                if let _ = newRecord {
                    print("Record created for \(self.userUUID)")
                    completion(true)
                }
            }
        }
    }
    
    func isKeyValid(_ key: String, completion: @escaping (Bool) -> ()) {
        let predicate = NSPredicate(format: "id == %@", key)
        let query = CKQuery(recordType: RecordType.thisWeekPlan.rawValue, predicate: predicate)
        print("Checking if record with \(key) exist")
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                guard let records = ckRecords else {
                    completion(false)
                    return
                }

                guard records.first != nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    func updateUserPreferences(useShared: Bool, sharedKey: String, isSharing: Bool) {
        DispatchQueue.main.async {
            self.useSharedPlanning = useShared
            self.sharedPlanningUUID = sharedKey
            self.shareYourPlanning = isSharing
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(sharedKey, forKey: CloudPreferenceKeys.sharedUUID.rawValue)
            userDefaults.set(isSharing, forKey: CloudPreferenceKeys.shareYourPlanning.rawValue)
            userDefaults.set(useShared, forKey: CloudPreferenceKeys.useSharedPlanning.rawValue)
            
            self.updateSharedWeekPlanId()
        }
    }
    
    private func updateSharedWeekPlanId() {
        if useSharedPlanning {
            sharedWeekPlanId = sharedPlanningUUID
        } else if shareYourPlanning {
            sharedWeekPlanId = userUUID
        } else {
            sharedWeekPlanId = ""
            self.cloudSyncStatus = .completed
        }
    }
    
    func isSavingToCloud() -> Bool {
        return sharedWeekPlanId.count > 0
    }
    
    enum CloudPreferenceKeys: String {
        case userUUID = "USER_UUID"
        case sharedUUID = "SHARED_UUID"
        case useSharedPlanning = "IS_USING_SHARED_PLANNING"
        case shareYourPlanning = "IS_SHARING_PLANNING"
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

enum CloudSyncStatus: String {
    case completed = "COMPLETED"
    case inProgress = "IN_PROGRESS"
    case error = "ERROR"
}
