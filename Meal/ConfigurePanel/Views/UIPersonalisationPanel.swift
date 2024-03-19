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
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @State var selectedBackground = 1
    @State var selectedColor = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GoingPremium()
            Text("Background").subTitle()
            ScrollView(.horizontal) {
                HStack {
                    BackgroundChoice(backgroundId: 0, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 1, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 2, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 3, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 4, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 5, selectedBackground: $selectedBackground)
                }
            }
            Text("App main color").subTitle()
            ScrollView(.horizontal) {
                HStack {
                    ColorPickerView(colorId: 0, selectedColor: $selectedColor)
                    ColorPickerView(colorId: 1, selectedColor: $selectedColor)
                }
            }
        }.scrollableSheetVStack()
        .navigationTitle("ui-personalization.title")
        .onAppear() {
            selectedBackground = userPrefs.backgroundImage
            selectedColor = userPrefs.accentColorId
        }
    }
    
    struct BackgroundChoice: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let backgroundId: Int
        @Binding var selectedBackground: Int
        var body: some View {
            Button(action: {
                selectedBackground = backgroundId
                userPrefs.applyBackgroundImageIdChange(backgroundId)
            }, label: {
                ZStack {
                    Color("BackgroundColor")
                    
                    if backgroundId > 0 {
                        ZStack {
                            Color("BackgroundColor")
                            Image("Background \(backgroundId) Dark")
                                .resizable()
                                .scaledToFill()
                                .opacity(0.4)
                        }.mask(Rectangle().frame(width: 98).padding(.leading, 102))
                        
                        ZStack {
                            Color("BackgroundColor")
                            Image("Background \(backgroundId)")
                                .resizable()
                                .scaledToFill()
                                .opacity(0.4)
                        }.mask(Rectangle().frame(width: 98).padding(.trailing, 102))
                    }
                }.frame(width: 200, height: 200).cornerRadius(15).clipped()
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedBackground == backgroundId ? userPrefs.accentColor : Color("WhiteBackgroundColor"), lineWidth: 2)
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
