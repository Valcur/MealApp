//
//  Meal.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import Foundation
import SwiftUI
import EventKit

class Meal: Hashable, Codable, Identifiable {
    var uuid = UUID()
    let id: Int
    var name: String
    var type: MealType
    var sides: [Side]?
    var notes: String?
    
    init(id: Int, name: String, type: MealType, sides: [Side]? = [], notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.sides = sides
        self.notes = notes
    }
    
    static func ==(lhs: Meal, rhs: Meal) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    func new() -> Meal {
        return Meal(id: self.id, name: self.name, type: self.type, sides: self.sides ?? nil, notes: self.notes ?? nil)
    }
    
    func hasNotes() -> Bool {
        return notes != nil && notes != ""
    }
    
    static var LeftOVer: Meal = Meal(id: -1, name: NSLocalizedString("leftover", comment: "leftover"), type: .vegan)
    
    static var EmptyMEal: Meal = Meal(id: -2, name: "", type: .vegan)
}

enum MealType: Codable {
    case meat
    case vegan
    case outside
    
    func getColor() -> Color {
        switch self {
        case .meat:
            return Color("MeatColor")
        case .vegan:
            return Color("VeganColor")
        case .outside:
            return Color("OutsideColor")
        }
    }
    
    func getName() -> String {
        switch self {
        case .meat:
            return NSLocalizedString("Meat", comment: "Meat")
        case .vegan:
            return NSLocalizedString("Vegan", comment: "Vegan")
        case .outside:
            return NSLocalizedString("Outside", comment: "Outside")
        }
    }
    
    static func randomNonOutside() -> MealType {
        return [MealType.meat, MealType.vegan].randomElement()!
    }
}
