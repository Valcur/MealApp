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
    var otherTitle: String {
        categoriesPrefs.otherTitle
    }
    var outsideTitle: String {
        "Outside".translate()
    }
    
    var meatColorId: Int {
        categoriesPrefs.meatColorId
    }
    var veganColorId: Int {
        categoriesPrefs.veganColorID
    }
    var otherColorId: Int {
        categoriesPrefs.otherColorID
    }
    var outsideColorId: Int {
        categoriesPrefs.outsideColorId
    }
    
    var meatImageId: Int {
        categoriesPrefs.meatImageId
    }
    var veganImageId: Int {
        categoriesPrefs.veganImageId
    }
    var otherImageId: Int {
        categoriesPrefs.otherImageId
    }
    var outsideImageId: Int {
        categoriesPrefs.outsideImageId
    }
    
    var meatColor: String {
        "ColorChoice \(meatColorId)"
    }
    var veganColor: String {
        "ColorChoice \(veganColorId)"
    }
    var otherColor: String {
        "ColorChoice \(otherColorId)"
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
    var otherImage: String {
        "ImageChoice \(categoriesPrefs.otherImageId)"
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
