//
//  EdamamParser.swift
//  Meal
//
//  Created by Loic D on 22/07/2023.
//

import Foundation

// MARK: - RecipeQuery
struct RecipeQuery: Codable {
    let from, to, count: Int
    let links: RecipeQueryLinks
    let hits: [Hit]

    enum CodingKeys: String, CodingKey {
        case from, to, count
        case links = "_links"
        case hits
    }
    
    // MARK: - Hit
    struct Hit: Codable {
        let recipe: RecipeData
        let links: HitLinks

        enum CodingKeys: String, CodingKey {
            case recipe
            case links = "_links"
        }
    }

    // MARK: - HitLinks
    struct HitLinks: Codable {
        let linksSelf: Next

        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
        }
    }

    // MARK: - Next
    struct Next: Codable {
        let href: String
        let title: Title
    }

    enum Title: String, Codable {
        case nextPage = "Next page"
        case titleSelf = "Self"
    }

    // MARK: - Recipe
    struct RecipeData: Codable {
        let uri: String
        let label: String
        let images: Images
        let url: String
        let yield: Int?
        let ingredientLines: [String]
        let ingredients: [Ingredient]
        let calories: Double
        let totalTime: Int
        let totalDaily: [String: TotalDaily]
    }

    // MARK: - Images
    struct Images: Codable {
        let thumbnail, small, regular: Large?
        let large: Large?

        enum CodingKeys: String, CodingKey {
            case thumbnail = "THUMBNAIL"
            case small = "SMALL"
            case regular = "REGULAR"
            case large = "LARGE"
        }
    }

    // MARK: - Large
    struct Large: Codable {
        let url: String
        let width, height: Int
    }

    // MARK: - Ingredient
    struct Ingredient: Codable {
        let text: String
        let quantity: Double
        let measure: String?
        let food: String
        let weight: Double
        let foodCategory, foodID: String
        let image: String?

        enum CodingKeys: String, CodingKey {
            case text, quantity, measure, food, weight, foodCategory
            case foodID = "foodId"
            case image
        }
    }

    // MARK: - TotalDaily
    struct TotalDaily: Codable {
        let label: String
        let quantity: Double
        let unit: Unit
    }

    enum Unit: String, Codable {
        case empty = "%"
    }

    // MARK: - RecipeQueryLinks
    struct RecipeQueryLinks: Codable {
        let next: Next?
    }

}
