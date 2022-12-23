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
    
    init(id: Int, name: String, type: MealType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    static func ==(lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id && lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    func new() -> Meal {
        return Meal(id: self.id, name: self.name, type: self.type)
    }
    
    static var LeftOVer: Meal = Meal(id: -1, name: NSLocalizedString("leftover", comment: "leftover"), type: .vegan)
    
    static var EmptyMEal: Meal = Meal(id: -2, name: "Nothing", type: .meat)
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
}
