//
//  Recipe.swift
//  Meal
//
//  Created by Loic D on 09/04/2024.
//

import Foundation

struct Recipe: Codable {
    var serving: Int
    var ingredients: [Ingredient]
    var steps: [RecipeStep]
    
    mutating func updateServing(_ serving: Int) {
        self.serving = serving
        for i in 0..<ingredients.count {
            ingredients[i].updateDisplayedQuantity(servings: serving)
        }
    }
    
    init(serving: Int, ingredients: [Ingredient], steps: [RecipeStep]) {
        self.serving = serving
        self.ingredients = ingredients
        self.steps = steps
    }
    
    init() {
        self.serving = 4
        self.ingredients = []
        self.steps = []
    }
}

struct RecipeStep: Codable, Identifiable {
    var id = UUID()
    var step: String
}

struct Ingredient: Codable, Identifiable, Hashable {
    var id = UUID()
    var displayedQuantity: String
    var quantityPerServing: Float
    var name: String
    
    init(textLine: String, servings: Int) {
        var text = textLine
        let digits = "0123456789.,"
        
        var q = ""
        var toQ2 = false
        var q2 = ""
        var charToRemove = 0
        
        // Clean to remove whitespace at the beginning
        
        // If fisrt != digit, reverse digit position in the string
        if !digits.contains(where: { $0 == text.first ?? "?" })  {
            var firstDigitLocation = 0
            for char in text {
                if digits.contains(where: { $0 == char }) {
                    break
                } else {
                    firstDigitLocation += 1
                }
            }
            let beforeDigit = String(text.prefix(firstDigitLocation))
            text = String(text.dropFirst(firstDigitLocation))
            text.append(" ")
            text.append(beforeDigit)
        }
        
        for char in text {
            if digits.contains(where: { $0 == char }) {
                if toQ2 {
                    q2 += "\(char)"
                } else {
                    q += "\(char)"
                }
                charToRemove += 1
            } else if char == "/" {
                toQ2 = true
                charToRemove += 1
            } else {
                break
            }
        }
        
        if q == "" {
            self.quantityPerServing = -1
        } else {
            q = q.replacingOccurrences(of: ",", with: ".")
            var value = Float(q) ?? 1
            
            if q2 != "" {
                q2 = q2.replacingOccurrences(of: ",", with: ".")
                let value2 = Float(q2) ?? 1
                value = value / value2
            }
            self.quantityPerServing = value / Float(servings)
        }
        
        // Last clean
        text = text.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.displayedQuantity = ""
        self.name = String(text.dropFirst(charToRemove))
        self.updateDisplayedQuantity(servings: servings)
    }
    
    mutating func updateDisplayedQuantity(servings: Int) {
        displayedQuantity = quantityPerServing == -1 ? "" : "\((quantityPerServing * Float(servings)).clean)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
