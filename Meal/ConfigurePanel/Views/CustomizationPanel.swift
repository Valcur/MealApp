//
//  CustomizationPanel.swift
//  Meal
//
//  Created by Loic D on 23/07/2023.
//

import SwiftUI

struct CustomizationPanel: View {
    var userPrefs: VisualUserPrefs
    @State private var meatCategorieName: String
    @State private var veganCategorieName: String
    @State private var meatCategorieColorId: Int
    @State private var veganCategorieColorId: Int
    @State private var outsideCategorieColorId: Int = 2
    @State private var meatImageId: Int = 0
    @State private var veganImageId: Int = 1
    @State private var outsideImageId: Int = 2
    
    private let numberOfColor: Int = 9
    private let numberOfImages: Int = 10
    
    init(userPrefs: VisualUserPrefs) {
        self.userPrefs = userPrefs
        
        meatCategorieName = userPrefs.meatTitle
        veganCategorieName = userPrefs.veganTitle
        meatCategorieColorId = userPrefs.meatColorId
        veganCategorieColorId = userPrefs.veganColorId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 60)  {
            Text("customization.intro".translate())
                .headLine()
            
            VStack(alignment: .leading, spacing: 20)  {
                Text("\("customization.category".translate()) 1")
                    .subTitle()
                
                TextField("customization.title.placeholder".translate(), text: $meatCategorieName)
                    .textFieldBackground()
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.color.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfColor) { n in
                            ColorPickerView(colorId: n, selectedColor: $meatCategorieColorId)
                        }
                    }.padding(.bottom, 5)
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.image.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfImages) { n in
                            ImagePickerView(imageId: n, selectedImage: $meatImageId)
                        }
                    }.padding(.bottom, 8)
                }
            }
                
            VStack(alignment: .leading, spacing: 20)  {
                Text("\("customization.category".translate()) 1")
                    .subTitle()
                
                TextField("customization.title.placeholder".translate(), text: $veganCategorieName)
                    .textFieldBackground()
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.color.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfColor) { n in
                            ColorPickerView(colorId: n, selectedColor: $veganCategorieColorId)
                        }
                    }.padding(.bottom, 5)
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.image.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfImages) { n in
                            ImagePickerView(imageId: n, selectedImage: $veganImageId)
                        }
                    }.padding(.bottom, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 20)  {
                Text("Outside".translate())
                    .subTitle()
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.color.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfColor) { n in
                            ColorPickerView(colorId: n, selectedColor: $outsideCategorieColorId)
                        }
                    }.padding(.bottom, 5)
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        Text("customization.image.title".translate()).padding(.trailing, 10)
                        ForEach(0..<numberOfImages) { n in
                            ImagePickerView(imageId: n, selectedImage: $outsideImageId)
                        }
                    }.padding(.bottom, 8)
                }
            }
                
            Spacer()
            
        }.safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                userPrefs.applyChanges(CategoriesCustomizationData(meatTitle: meatCategorieName,
                                                                   meatColorId: meatCategorieColorId,
                                                                   meatImageId: meatImageId,
                                                                   veganTitle: veganCategorieName,
                                                                   veganColorID: veganCategorieColorId,
                                                                   veganImageId: veganImageId,
                                                                   outsideColorId: outsideCategorieColorId,
                                                                   outsideImageId: outsideImageId))
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
        ))
        .navigationTitle("customization.title".translate())
    }
    
    private struct ColorPickerView: View {
        var colorId: Int
        @Binding var selectedColor: Int
        var isSelected: Bool {
            colorId == selectedColor
        }
        
        var body: some View {
            Button(action: {
                selectedColor = colorId
            }, label: {
                Circle()
                    .frame(width: 34, height: 34)
                    .foregroundColor(Color("ColorChoice \(colorId)"))
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.accentColor : Color("WhiteBackgroundColor"), lineWidth: 2)
                    )
                    .padding(2)
            })
        }
    }
    
    private struct ImagePickerView: View {
        var imageId: Int
        @Binding var selectedImage: Int
        var isSelected: Bool {
            imageId == selectedImage
        }
        
        var body: some View {
            Button(action: {
                selectedImage = imageId
            }, label: {
                Image("ImageChoice \(imageId)")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isSelected ? Color.accentColor : Color("WhiteBackgroundColor"), lineWidth: 2)
                    )
                    .padding(2)
            })
        }
    }
}
