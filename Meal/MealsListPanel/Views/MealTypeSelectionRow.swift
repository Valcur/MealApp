//
//  MealTypeSelectionRow.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
// Stickers by stickers
//

import SwiftUI

extension MealsListPanel {
    struct MealTypeSelectionRow: View {
        @Binding var selectedMealType: MealType
        
        var body: some View {
            if UIDevice.isIPhone {
                VStack {
                    HStack {
                        MealTypeSelector(mealType: .meat, selectedMealType: $selectedMealType)
                        Spacer()
                            .frame(width: ViewSizes._mealType_spacerWidth())
                        MealTypeSelector(mealType: .vegan, selectedMealType: $selectedMealType)
                    }
                    HStack {
                        MealTypeSelector(mealType: .other, selectedMealType: $selectedMealType)
                        Spacer()
                            .frame(width: ViewSizes._mealType_spacerWidth())
                        MealTypeSelector(mealType: .outside, selectedMealType: $selectedMealType)
                    }
                }
            } else {
                HStack {
                    MealTypeSelector(mealType: .meat, selectedMealType: $selectedMealType)
                    Spacer()
                        .frame(width: ViewSizes._mealType_spacerWidth())
                    MealTypeSelector(mealType: .vegan, selectedMealType: $selectedMealType)
                    Spacer()
                        .frame(width: ViewSizes._mealType_spacerWidth())
                    MealTypeSelector(mealType: .other, selectedMealType: $selectedMealType)
                    Spacer()
                        .frame(width: ViewSizes._mealType_spacerWidth())
                    MealTypeSelector(mealType: .outside, selectedMealType: $selectedMealType)
                }
            }
        }
    }
    
    struct MealTypeSelector: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let mealType: MealType
        @Binding var selectedMealType: MealType
        var isSelected: Bool {
            mealType == selectedMealType
        }
        
        var body: some View {
            HStack {
                Button(action: {
                    withAnimation(.spring()) {
                        selectedMealType = mealType
                    }
                }, label: {
                    ZStack(alignment: .bottomLeading) {
                        EmojiBackground(mealType: mealType, isSelected: isSelected)
                        Text(mealType.getName(userPrefs: userPrefs))
                            .font(ViewSizes._largeTitle())
                            .fontWeight(.bold)
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .foregroundColor(isSelected ? Color("TextColor") : mealType.getColor(userPrefs: userPrefs))
                            .padding(ViewSizes._15())
                    }
                }).frame(height: ViewSizes._120()).overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("BackgroundColor"), lineWidth: isSelected ? 0 : 2)
                ).roundedCornerRectangle(padding: 0, shadowRadius: isSelected ? 4 : 0)
            }
        }
    }
    
    struct EmojiBackground: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let mealType: MealType
        let isSelected: Bool
        
        var image: Image {
            switch mealType {
            case .meat:
                return Image(userPrefs.meatImage)
            case .vegan:
                return Image(userPrefs.veganImage)
            case .other:
                return Image(userPrefs.otherImage)
            case .outside:
                return Image(userPrefs.outsideImage)
            }
        }
        
        var body: some View {
            ZStack(alignment: .trailing) {
                LinearGradient(gradient: Gradient(colors: [mealType.getColor(userPrefs: userPrefs).opacity(0.5), mealType.getColor(userPrefs: userPrefs)]), startPoint: .top, endPoint: .bottom)
                    .opacity(isSelected ? 1 : 0)
                    
                
                image
                    .resizable()
                    .frame(width: isSelected ? ViewSizes._200() : ViewSizes._100(), height: isSelected ? ViewSizes._200() : ViewSizes._100())
                    .scaledToFit()
                    .offset(x: isSelected ? ViewSizes._50() : -15, y: isSelected ? ViewSizes._30() : 0)
            }.frame(height: ViewSizes._120())
        }
    }
}

