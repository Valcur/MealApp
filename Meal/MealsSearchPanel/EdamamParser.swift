//
//  EdamamParser.swift
//  Meal
//
//  Created by Loic D on 22/07/2023.
//

import Foundation

// MARK: - Welcome
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
        let recipe: Recipe
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
    struct Recipe: Codable {
        let label: String
        let image: String
        let url: String
        let yield: Int
        let ingredientLines: [String]
        let calories: Double
    }

    // MARK: - WelcomeLinks
    struct RecipeQueryLinks: Codable {
        let next: Next
    }
}
