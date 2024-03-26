//
//  CloudKitController.swift
//  Meal
//
//  Created by Loic D on 11/06/2023.
//

import Foundation
import CloudKit
import SwiftUI

// FAILED CRAETING KEY WITHOUT TEILLING ME ?
// TROP DE SAVE NEXT WEEK ????

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
    
    func getWeekPlanningFromCloud(recordType: String, localPlanning: WeekPlan, forceUpdate: Bool, completion: @escaping (WeekPlan?) -> ()) {
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
                
                if !forceUpdate {
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
                }
                
                guard let weekPlanString = record.value(forKey: "weekPlan") as? String else { return }
                let weekPlan = self.weekPlanStringToWeekPlan(weekPlanString, whichWeek: recordType == RecordType.thisWeekPlan.rawValue ? .thisWeek : .nextWeek)
                completion(weekPlan)
                self.setCloudSyncStatus(.completed)
            }
        }
    }
    
    private func weekPlanStringToWeekPlan_deprecated(_ text: String, whichWeek: WichWeekIsIt) -> WeekPlan {
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
            } else if lines[i] == CloudTextSavingLabels.date.rawValue {
                let dateStr = String(lines[i + 1])
                currentDate = dateFormatter.date(from: dateStr) ?? Date()
                i += 1
                weekPlan.week[currentWeekDay.rawValue] = DayPlan(day: currentWeekDay, date: currentDate, midday: [], evening: [])
            } else if lines[i] == CloudTextSavingLabels.midday.rawValue {
                currentTimeOfTheDay = .midday
            } else if lines[i] == CloudTextSavingLabels.evening.rawValue {
                currentTimeOfTheDay = .evening
            } else if lines[i] == CloudTextSavingLabels.meal.rawValue {
                let id = Int(lines[i + 1]) ?? 0
                let name = String(lines[i + 2])
                let type = Int(lines[i + 3])
                var sides: [Side] = []
                let sidesKeys = String(lines[i + 4]).components(separatedBy: "/")
                for sidesKey in sidesKeys {
                    if sidesKey.count > 1 {
                        if sidesKey.contains("CUSTOM-") {
                            sides.append(Side(name: String(sidesKey.dropFirst(7)), id: UUID().uuidString))
                        } else {
                            sides.append(Side(key: sidesKey))
                        }
                    }
                }
                
                i += 5
                var notes = ""
                
                while i < lines.count && lines[i] != CloudTextSavingLabels.endNotes.rawValue {
                    let isLast = lines[i+1].contains(CloudTextSavingLabels.endNotes.rawValue)
                    notes += "\(lines[i].dropFirst(2))\(isLast ? "" : "\n")"
                    i += 1
                }
                /*
                let notesArray = notes.split(whereSeparator: "a".first!)
                print(notesArray)
                */
                let meal = Meal(id: id,
                                name: name,
                                type: type == 1 ? .meat : (type == 2 ? .vegan : (type == 3 ? .outside : .other)),
                                sides: sides,
                                notes: notes == "" ? nil : notes
                )

                weekPlan.append(meal, day: currentWeekDay, time: currentTimeOfTheDay)
            }
            
            i += 1
        }
        return weekPlan
    }
    
    private func weekPlanStringToWeekPlan(_ text: String, whichWeek: WichWeekIsIt) -> WeekPlan {
        var weekPlan = WeekPlan(whichWeek)
        do {
            let jsonDecoder = JSONDecoder()
            if let textData = text.data(using: .utf8, allowLossyConversion: false) {
                let weekData = try jsonDecoder.decode([DayPlan].self, from: textData)
                print(text)
                for day in weekData {
                    for meal in day.midday {
                        weekPlan.append(meal, day: day.day, time: .midday)
                    }
                    for meal in day.evening {
                        weekPlan.append(meal, day: day.day, time: .evening)
                    }
                }
            }
        } catch {
            print("Failed to decode, switching to old method")
            weekPlan = weekPlanStringToWeekPlan_deprecated(text, whichWeek: whichWeek)
        }
        
        return weekPlan
    }
    
    
    func saveWeeksPlanningToCloud(thisWeek: WeekPlan, nexWeek: WeekPlan) {
        weekSavingProgress = 0
        savingWeekPlanningToCloud(recordType: RecordType.thisWeekPlan.rawValue, plan: thisWeek)
        savingWeekPlanningToCloud(recordType: RecordType.nextWeekPlan.rawValue, plan: nexWeek)
    }
    
    func saveWeekPlanningToCloud(recordType: String, plan: WeekPlan) {
        weekSavingProgress = 1
        savingWeekPlanningToCloud(recordType: recordType, plan: plan)
    }
    
    // Replace in a few weeks
    private func savingWeekPlanningToCloud_new(recordType: String, plan: WeekPlan) {
        self.setCloudSyncStatus(.inProgress)
        do {
            let myWeek = plan.week
            for d in 0..<myWeek.count {
                for m in 0..<myWeek[d].midday.count {
                    if myWeek[d].midday[m].sides != nil {
                        for i in 0..<myWeek[d].midday[m].sides!.count {
                            myWeek[d].midday[m].sides![i].customImage = nil
                        }
                    }
                }
                for m in 0..<myWeek[d].evening.count {
                    if myWeek[d].evening[m].sides != nil {
                        for i in 0..<myWeek[d].evening[m].sides!.count {
                            myWeek[d].evening[m].sides![i].customImage = nil
                        }
                    }
                }
            }
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(myWeek)
            let weekData = String(data: jsonData, encoding: String.Encoding.utf8)
            
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
                    
                    record["weekPlan"] = weekData
                    
                    let modifyRecords = CKModifyRecordsOperation(recordsToSave:[record], recordIDsToDelete: nil)
                    modifyRecords.savePolicy = .allKeys
                    modifyRecords.qualityOfService = QualityOfService.userInitiated
                    modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error == nil {
                            print("Week updated successfully")
                            self.weekSavingProgress += 1
                            if self.weekSavingProgress == 2 {
                                self.setCloudSyncStatus(.completed)
                            }
                        }else {
                            print(error ?? "Error modifying record")
                            self.setCloudSyncStatus(.error)
                            self.weekSavingProgress = -1
                        }
                    }
                    self.database.add(modifyRecords)
                }
            }
        } catch {
            print("ERROR: Failed to encode weekplan")
            self.setCloudSyncStatus(.error)
            self.weekSavingProgress = -1
        }
    }
    
    // TODO: Deprecated, replace with _new in a few weeks after update
    private func savingWeekPlanningToCloud(recordType: String, plan: WeekPlan) {
        self.setCloudSyncStatus(.inProgress)
        var text = "\(recordType)\n\n"
        for dayPlan in plan.week {
            text += "\(dayPlan.day)\n"
            text += "\(CloudTextSavingLabels.date.rawValue)\n"
            text += "\(dayPlan.date)\n"
            
            text += "\(CloudTextSavingLabels.midday.rawValue)\n"
            for midday in dayPlan.midday {
                text += "\(CloudTextSavingLabels.meal.rawValue)\n"
                text += "\(midday.id)\n"
                text += "\(midday.name == "" ? " " : midday.name)\n"
                text += "\(midday.type == .meat ? 1 : (midday.type == .vegan ? 2 : (midday.type == .outside ? 3 : 4)))\n"
                if let sides = midday.sides {
                    for side in sides {
                        if side.isDefaultSide {
                            text += "\(side.imageName)/"
                        } else {
                            print("Adding custom side \(side.name)")
                            text += "CUSTOM-\(side.name)/"
                        }
                    }
                }
                text += " \n"
                
                let notes = midday.notes ?? ""
                if notes != "" {
                    var notesArray = notes.replacingOccurrences(of: "\n", with: "\nN:").split(whereSeparator: \.isNewline)
                    notesArray[0] = "N:\(notesArray[0])"
                    for noteLine in notesArray {
                        text += "\(noteLine)\n"
                    }
                } else {
                    text += "N:\n"
                }
                text += "\(CloudTextSavingLabels.endNotes.rawValue)\n"
            }
            
            text += "\(CloudTextSavingLabels.evening.rawValue)\n"
            for evening in dayPlan.evening {
                text += "\(CloudTextSavingLabels.meal.rawValue)\n"
                text += "\(evening.id)\n"
                text += "\(evening.name == "" ? " " : evening.name)\n"
                text += "\(evening.type == .meat ? 1 : (evening.type == .vegan ? 2 : (evening.type == .outside ? 3 : 4)))\n"
                if let sides = evening.sides {
                    for side in sides {
                        if side.isDefaultSide {
                            text += "\(side.imageName)/"
                        } else {
                            print("Adding custom side \(side.name)")
                            text += "CUSTOM-\(side.name)/"
                        }
                    }
                }
                text += " \n"
                
                let notes = evening.notes ?? ""
                if notes != "" {
                    var notesArray = notes.replacingOccurrences(of: "\n", with: "\nN:").split(whereSeparator: \.isNewline)
                    notesArray[0] = "N:\(notesArray[0])"
                    for noteLine in notesArray {
                        text += "\(noteLine)\n"
                    }
                } else {
                    text += "N:\n"
                }
                text += "\(CloudTextSavingLabels.endNotes.rawValue)\n"
            }
        }
        
        //print("SAVING MY TEXT \(recordType)\n")
        //print(text)
        
        let predicate = NSPredicate(format: "id == %@", sharedWeekPlanId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        database.perform(query, inZoneWith: nil) { ckRecords, error in
            if let error = error {
                print(error)
                self.setCloudSyncStatus(.error)
            } else {
                guard let records = ckRecords else {
                    print("1111")
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                guard let record = records.first else {
                    print("2222")
                    self.setCloudSyncStatus(.error)
                    return
                }
                
                record["weekPlan"] = text
                
                let modifyRecords = CKModifyRecordsOperation(recordsToSave:[record], recordIDsToDelete: nil)
                modifyRecords.savePolicy = .allKeys
                modifyRecords.qualityOfService = QualityOfService.userInitiated
                modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if error == nil {
                        print("Week updated successfully")
                        self.weekSavingProgress += 1
                        if self.weekSavingProgress == 2 {
                            self.setCloudSyncStatus(.completed)
                        }
                    }else {
                        print(error ?? "Error modifying record")
                        self.setCloudSyncStatus(.error)
                        self.weekSavingProgress = -1
                    }
                }
                self.database.add(modifyRecords)
                
                /*
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
                }*/
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
    
    func userNotPremium() {
        shareYourPlanning = false
        UserDefaults.standard.set(false, forKey: CloudPreferenceKeys.shareYourPlanning.rawValue)
        self.updateSharedWeekPlanId()
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
    
    enum CloudTextSavingLabels: String {
        case date = "##_WEEK_PLAN_DATE_##"
        case evening = "##_WEEK_PLAN_EVENING_##"
        case midday = "##_WEEK_PLAN_MIDDAY_##"
        case meal = "##_MEAL_DATA_##"
        case endNotes = "##_END_NOTES_##"
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
