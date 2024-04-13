//
//  Recipe.swift
//  Meal
//
//  Created by Loic D on 09/04/2024.
//

import Foundation

struct Recipe: Codable {
    var imageName: String
    var serving: Int
    var ingredients: [Ingredient]
    var steps: [RecipeStep]
    
    mutating func updateServing(_ serving: Int) {
        self.serving = serving
        for i in 0..<ingredients.count {
            ingredients[i].updateDisplayedQuantity(servings: serving)
        }
    }
    
    init(imageName: String, serving: Int, ingredients: [Ingredient], steps: [RecipeStep]) {
        self.imageName = imageName
        self.serving = serving
        self.ingredients = ingredients
        self.steps = steps
    }
    
    init() {
        self.imageName = ""
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
    var displayedQuantity: Float
    var quantityPerServing: Float
    var name: String
    
    init(textLine: String, servings: Int) {
        let digits = "0123456789.,"
        
        var q = ""
        var toQ2 = false
        var q2 = ""
        var charToRemove = 0
        
        for char in textLine {
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
        
        q = q.replacingOccurrences(of: ",", with: ".")
        var value = Float(q) ?? 1
        
        if q2 != "" {
            q2 = q2.replacingOccurrences(of: ",", with: ".")
            let value2 = Float(q2) ?? 1
            value = value / value2
        }
        
        self.displayedQuantity = 0
        self.quantityPerServing = value / Float(servings)
        self.name = String(textLine.dropFirst(charToRemove))
        self.updateDisplayedQuantity(servings: servings)
    }
    
    mutating func updateDisplayedQuantity(servings: Int) {
        displayedQuantity = quantityPerServing * Float(servings)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
