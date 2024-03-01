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
            Text("Background").subTitle()
            ScrollView(.horizontal) {
                HStack {
                    BackgroundChoice(backgroundId: 1, selectedBackground: $selectedBackground)
                    BackgroundChoice(backgroundId: 2, selectedBackground: $selectedBackground)
                }
            }
            Text("App main color").subTitle()
            ScrollView(.horizontal) {
                HStack {
                    ColorPickerView(colorId: 1, selectedColor: $selectedColor)
                    ColorPickerView(colorId: 2, selectedColor: $selectedColor)
                }
            }
        }.scrollableSheetVStack()
        .navigationTitle("availableMeals_title")
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
                    Image("Background \(backgroundId)")
                        .resizable()
                        .scaledToFill()
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
