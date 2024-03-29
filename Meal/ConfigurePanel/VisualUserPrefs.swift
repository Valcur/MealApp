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
    @Published private var interfacePrefs: InterfaceCustomizationData
    @Published private var customBackground: UIImage?
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
    
    var backgroundImage: Int {
        interfacePrefs.backgroundId
    }
    var backgroundImageName: String {
        "Background \(interfacePrefs.backgroundId)"
    }
    var backgroundDarkImageName: String {
        "Background \(interfacePrefs.backgroundId) Dark"
    }
    var customBackgroundImageView: any View {
        ZStack(alignment: .top) {
            if let image = customBackground {
                Image(uiImage: image).resizable().scaledToFill()
            }
        }
    }
    var isUsingDefaultBackground: Bool {
        return interfacePrefs.backgroundId == 0
    }
    
    var accentColorId: Int {
        interfacePrefs.appAccentColorId
    }
    var accentColor: Color {
        Color("AccentColor \(interfacePrefs.appAccentColorId)")
    }
    
    var showButtonbackground: Bool {
        interfacePrefs.showButtonbackground && backgroundImage != 0
    }
    
    
    init() {
        data = MealsDataController()
        categoriesPrefs = data.loadCategoriesCustomization()
        interfacePrefs = data.loadInterfaceCustomization()
        customBackground = SaveManager.getSavedUIImage(fileName: "CustomBackgroundImage")
    }
    
    func applyBackgroundImageIdChange(_ newId: Int) {
        interfacePrefs.backgroundId = newId
        data.saveInterfaceCustomization(interfaceCustomization: interfacePrefs)
    }
    
    func applyAccentColorIdChange(_ newId: Int) {
        interfacePrefs.appAccentColorId = newId
        data.saveInterfaceCustomization(interfaceCustomization: interfacePrefs)
    }
    
    func applyNewValueShowButtonbackground(_ newValue: Bool) {
        interfacePrefs.showButtonbackground = newValue
        data.saveInterfaceCustomization(interfaceCustomization: interfacePrefs)
    }
    
    func applyCustomBackgroundImage(_ newImage: UIImage) {
        customBackground = newImage
        SaveManager.saveUIImage(uiImage: newImage, fileName: "CustomBackgroundImage")
    }
    
    func applyChanges(_ categories: CategoriesCustomizationData) {
        categoriesPrefs = categories
        data.saveCategoriesCustomization(categoriesCustomization: categories)
        self.objectWillChange.send()
    }
}
