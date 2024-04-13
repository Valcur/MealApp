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
    var recipe: Recipe?
    
    init(id: Int, name: String, type: MealType, sides: [Side]? = [], notes: String? = nil, recipe: Recipe? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.sides = sides
        self.notes = notes
        self.recipe = recipe
    }
    
    static func ==(lhs: Meal, rhs: Meal) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    func new() -> Meal {
        return Meal(id: self.id, name: self.name, type: self.type, sides: self.sides ?? nil, notes: self.notes ?? nil, recipe: self.recipe ?? nil)
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
    case other
    case outside
    
    func getColor(userPrefs: VisualUserPrefs) -> Color {
        switch self {
        case .meat:
            return Color(userPrefs.meatColor)
        case .vegan:
            return Color(userPrefs.veganColor)
        case .other:
            return Color(userPrefs.otherColor)
        case .outside:
            return Color(userPrefs.outsideColor)
        }
    }
    
    func getName(userPrefs: VisualUserPrefs) -> String {
        switch self {
        case .meat:
            return userPrefs.meatTitle
        case .vegan:
            return userPrefs.veganTitle
        case .other:
            return userPrefs.otherTitle
        case .outside:
            return "Outside".translate()
        }
    }
    
    static func randomNonOutside() -> MealType {
        return [MealType.meat, MealType.vegan].randomElement()!
    }
}
