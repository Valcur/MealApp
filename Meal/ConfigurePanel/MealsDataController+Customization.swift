//
//  MealsDataController+Customization.swift
//  Meal
//
//  Created by Loic D on 23/07/2023.
//

import Foundation

extension MealsDataController {
    func saveCategoriesCustomization(categoriesCustomization: CategoriesCustomizationData) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(categoriesCustomization) {
            userDefaults.set(data, forKey: "\(CATEGORIES_CUSTOMIZATION_KEY)")
        }
    }
    
    func loadCategoriesCustomization() -> CategoriesCustomizationData {
        if let data = userDefaults.object(forKey: "\(CATEGORIES_CUSTOMIZATION_KEY)") as? Data {
            let decoder = JSONDecoder()
            if let categories = try? decoder.decode(CategoriesCustomizationData.self, from: data) {
                return categories
            }
        }
        return CategoriesCustomizationData(meatTitle: "Meat".translate(),
                                           meatColorId: 0,
                                           meatImageId: 0,
                                           veganTitle: "Vegan".translate(),
                                           veganColorID: 1,
                                           veganImageId: 1,
                                           otherTitle: "Dessert".translate(),
                                           otherColorID: 2,
                                           otherImageId: 2,
                                           outsideColorId: 3,
                                           outsideImageId: 3)
    }
}

struct CategoriesCustomizationData: Codable {
    var meatTitle: String
    var meatColorId: Int
    var meatImageId: Int
    
    var veganTitle: String
    var veganColorID: Int
    var veganImageId: Int
    
    var otherTitle: String
    var otherColorID: Int
    var otherImageId: Int
    
    var outsideColorId: Int
    var outsideImageId: Int
}
