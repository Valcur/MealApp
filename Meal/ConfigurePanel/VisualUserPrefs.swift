//
//  VisualUserPrefs.swift
//  Meal
//
//  Created by Loic D on 23/07/2023.
//

import Foundation
import SwiftUI

class VisualUserPrefs: ObservableObject {
    private var categoriesPrefs: CategoriesCustomizationData
    private let data: MealsDataController
    @Published private var backgroundImageId: Int
    @Published private var accentColorId: Int
    
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
    
    var backgroundImageName: String {
        "Background \(backgroundImageId)"
    }
    var backgroundDarkImageName: String {
        "BackgroundDark \(backgroundImageId)"
    }
    
    var accentColor: Color {
        Color("AccentColor \(accentColorId)")
    }
    
    init() {
        data = MealsDataController()
        categoriesPrefs = data.loadCategoriesCustomization()
        backgroundImageId = 1
        accentColorId = 2
    }
    
    func applyBackgroundImageIdChange(_ newId: Int) {
        backgroundImageId = newId
    }
    
    func applyAccentColorIdChange(_ newId: Int) {
        accentColorId = newId
    }
    
    func applyChanges(_ categories: CategoriesCustomizationData) {
        categoriesPrefs = categories
        data.saveCategoriesCustomization(categoriesCustomization: categories)
        self.objectWillChange.send()
    }
}
