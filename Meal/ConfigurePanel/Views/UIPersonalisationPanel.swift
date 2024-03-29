//
//  UIPersonalisationPanel.swift
//  Meal
//
//  Created by Loic D on 29/02/2024.
//

import Foundation

import SwiftUI

struct UIPersonalisationPanel: View {
    @EnvironmentObject var mealsListVM: MealsListPanelViewModel
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @State var selectedBackground = 1
    @State var selectedColor = 1
    @State var showButtonBackground = false
    
    var isPremium: Bool {
        configurePanelVM.isPremium || configurePanelVM.cloudKitController.useSharedPlanning
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !isPremium {
                GoingPremium()
                Text("ui-personalization.premium.intro".translate()).headLine()
            }
            
            Group {
                Text("ui-personalization.appColor.title".translate()).subTitle()
                Text("ui-personalization.appColor.content".translate()).headLine()
                ScrollView(.horizontal) {
                    HStack {
                        ColorPickerView(colorId: 0, selectedColor: $selectedColor)
                        ColorPickerView(colorId: 1, selectedColor: $selectedColor)
                        ColorPickerView(colorId: 2, selectedColor: $selectedColor)
                        ColorPickerView(colorId: 3, selectedColor: $selectedColor)
                        ColorPickerView(colorId: 4, selectedColor: $selectedColor)
                        ColorPickerView(colorId: 5, selectedColor: $selectedColor)
                    }
                }
                Text("ui-personalization.background.title".translate()).subTitle()
                HStack {
                    Text("ui-personalization.background.showButtonBackground".translate())
                        .headLine()
                    Spacer()
                    Toggle("", isOn: $showButtonBackground)
                        .labelsHidden()
                        .onChange(of: showButtonBackground) { _ in
                            userPrefs.applyNewValueShowButtonbackground(showButtonBackground)
                        }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))]) {
                    BackgroundChoice(backgroundId: 0, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: -1, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 1, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 2, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 3, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 4, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 5, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 6, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 7, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 8, selectedBackground: $selectedBackground)
                }.padding(.bottom, 10)
            }.opacity(isPremium ? 1 : 0.7)
            .allowsHitTesting(isPremium)
        }.scrollableSheetVStack()
        .navigationTitle("ui-personalization.title")
        .onAppear() {
            selectedBackground = userPrefs.backgroundImage
            selectedColor = userPrefs.accentColorId
            showButtonBackground = userPrefs.showButtonbackground
        }
    }
    
    struct BackgroundChoice: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let backgroundId: Int
        @Binding var selectedBackground: Int
        
        var isSelected: Bool {
            selectedBackground == backgroundId
        }
        @State var showImagePicker: Bool = false
        @State private var inputImage: UIImage?
        
        var body: some View {
            Button(action: {
                if backgroundId == -1 && isSelected {
                    showImagePicker = true
                } else {
                    selectedBackground = backgroundId
                    userPrefs.applyBackgroundImageIdChange(backgroundId)
                }
            }, label: {
                ZStack {
                    Color("BackgroundColor")
                    
                    if backgroundId > 0 {
                        ZStack {
                            Color("BackgroundColor")
                            Image("Background \(backgroundId) Dark")
                                .resizable()
                                .scaledToFill()
                        }.mask(Rectangle().frame(width: 98).padding(.leading, 102))
                        
                        ZStack {
                            Color("BackgroundColor")
                            Image("Background \(backgroundId)")
                                .resizable()
                                .scaledToFill()
                        }.mask(Rectangle().frame(width: 98).padding(.trailing, 102))
                    }
                    
                    if backgroundId == -1 {
                        AnyView(userPrefs.customBackgroundImageView)
                            .frame(width:  200, height: 200)
                        
                        ZStack {
                            Color.black.opacity(isSelected ? 0.5 : 0).cornerRadius(10)
                            
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(isSelected ? Color.white : Color.black)
                        }.padding(40)
                        .onChange(of: inputImage) { _ in
                            guard let inputImage = inputImage else { return }
                            userPrefs.applyCustomBackgroundImage(inputImage)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $inputImage).preferredColorScheme(.dark)
                                .ignoresSafeArea()
                        }
                    }
                }.frame(width: 200, height: 200).cornerRadius(15).opacity(0.9).clipped()
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? userPrefs.accentColor : Color("WhiteBackgroundColor"), lineWidth: 2)
                    )
                    .padding(2)
            })
        }
    }
    
    struct ColorPickerView: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        var colorId: Int
        @Binding var selectedColor: Int
        var isSelected: Bool {
            colorId == selectedColor
        }
        
        var body: some View {
            Button(action: {
                selectedColor = colorId
                userPrefs.applyAccentColorIdChange(colorId)
            }, label: {
                Circle()
                    .frame(width: 34, height: 34)
                    .foregroundColor(Color("AccentColor \(colorId)"))
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? userPrefs.accentColor : Color("WhiteBackgroundColor"), lineWidth: 2)
                    )
                    .padding(2)
            })
        }
    }
}
