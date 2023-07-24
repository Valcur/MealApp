//
//  VisualUserPrefs.swift
//  Meal
//
//  Created by Loic D on 23/07/2023.
//

import Foundation

class VisualUserPrefs: ObservableObject {
    private var categoriesPrefs: CategoriesCustomizationData
    private let data: MealsDataController
    
    var meatTitle: String {
        categoriesPrefs.meatTitle
    }
    var veganTitle: String {
        categoriesPrefs.veganTitle
    }
    
    var meatColorId: Int {
        categoriesPrefs.meatColorId
    }
    var veganColorId: Int {
        categoriesPrefs.veganColorID
    }
    var outsideColorId: Int {
        categoriesPrefs.outsideColorId
    }
    
    var meatColor: String {
        "ColorChoice \(meatColorId)"
    }
    var veganColor: String {
        "ColorChoice \(veganColorId)"
    }
    var outsideColor: String {
        "ColorChoice \(outsideColorId)"
    }
    
    var meatImage: String {
        "ImageChoice \(categoriesPrefs.meatImageId)"
    }
    var veganImage: String {
        "ImageChoice \(categoriesPrefs.veganImageId)"
    }
    var outsideImage: String {
        "ImageChoice \(categoriesPrefs.outsideImageId)"
    }
    
    init() {
        data = MealsDataController()
        categoriesPrefs = data.loadCategoriesCustomization()
    }
    
    func applyChanges(_ categories: CategoriesCustomizationData) {
        categoriesPrefs = categories
        data.saveCategoriesCustomization(categoriesCustomization: categories)
        self.objectWillChange.send()
    }
}
