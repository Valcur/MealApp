//
//  AlreadyPickedPanel.swift
//  Meal
//
//  Created by Loic D on 30/01/2024.
//

import SwiftUI

struct AlreadyPickedPanel: View {
    @EnvironmentObject var mealsListVM: MealsListPanelViewModel
    @EnvironmentObject var userPrefs: VisualUserPrefs
    private var tooOldPickedMealChoices = [0, 2, 3, 4, 5, 10]
    @State var tooOldChoice = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("availableMeals_content").headLine()
            
            Text("availableMeals_content_2".translate()).headLine()
            
            HStack {
                Text("time".translate()).headLine()
                Picker("", selection: $tooOldChoice) {
                    ForEach(tooOldPickedMealChoices, id: \.self) { c in
                        if c == 0 {
                            Text("disabled".translate())
                        } else {
                            Text("\(c) \("weeks".translate())")
                        }
                    }
                }
                Spacer()
            }
            .onChange(of: tooOldChoice) { _ in
                mealsListVM.tooOldMealPickedTreshold = tooOldChoice
                UserDefaults.standard.set(tooOldChoice, forKey: "TooOldTreshold")
            }
            .onAppear() {
                tooOldChoice = mealsListVM.tooOldMealPickedTreshold
            }
            
            MealGrid(categroyNumber: 1)
            MealGrid(categroyNumber: 2)
            MealGrid(categroyNumber: 3)
            MealGrid(categroyNumber: 4)
        }.scrollableSheetVStack()
        .navigationTitle("availableMeals_title")
    }
    
    struct MealGrid: View {
        @EnvironmentObject var mealsListVM: MealsListPanelViewModel
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let columns = ViewSizes._MealList_GridColumns()
        let categroyNumber: Int
        var title: String {
            switch categroyNumber
            {
                case 1: return userPrefs.meatTitle
                case 2: return userPrefs.veganTitle
                case 3: return userPrefs.otherTitle
                default: return userPrefs.outsideTitle
            }
        }
        var pickedMeals: [AlreadyPickedMeal] {
            switch categroyNumber
            {
                case 1: return mealsListVM.recentlyPickedMeals.pickedMeatIds
                case 2: return mealsListVM.recentlyPickedMeals.pickedVeganIds
                case 3: return mealsListVM.recentlyPickedMeals.pickedOtherIds
                default: return mealsListVM.recentlyPickedMeals.pickedOutsideIds
            }
        }
        var meals: [Meal] {
            switch categroyNumber
            {
                case 1: return mealsListVM.meals.meatMeals
                case 2: return mealsListVM.meals.veganMeals
                case 3: return mealsListVM.meals.otherMeals
                default: return mealsListVM.meals.outsideMeals
            }
        }
        var color: Color {
            switch categroyNumber
            {
                case 1: return Color(userPrefs.meatColor)
                case 2: return Color(userPrefs.veganColor)
                case 3: return Color(userPrefs.otherColor)
                default: return Color(userPrefs.outsideColor)
            }
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text(title).foregroundColor(color).title()
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            switch categroyNumber
                            {
                                case 1: mealsListVM.resetMeatMeals()
                                case 2: mealsListVM.resetVeganMeals()
                                case 3: mealsListVM.resetOtherMeals()
                                default: mealsListVM.resetOutsideMeals()
                            }
                        }
                    }, label: {
                        ButtonLabel(title: "reset", isCompact: true)
                    })
                }
                
                LazyVGrid(columns: columns) {
                    ForEach(meals) { meal in
                        HStack {
                            MealPickedElement(meal: meal, pickedMeal: pickedMeals.first(where: { $0.id == meal.id }))
                        }
                    }
                }.frame(maxWidth: .infinity).roundedCornerRectangle(color: Color("BackgroundColor"))
            }
        }
    }
}

struct MealElement: View {
    var meal: Meal
    let textColor: Color
    
    init(meal: Meal, textColor: Color = Color("TextColor")) {
        self.meal = meal
        self.textColor = textColor
    }
    
    var body: some View {
        VStack(spacing: 1) {
            Text(meal.name)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .headLine()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            if meal.sides?.count ?? 0 > 0 {
                Text(Side.sidesNameDescription(meal.sides ?? []))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }.frame(height: ViewSizes._50())
    }
}

struct MealPickedElement: View {
    var meal: Meal
    var pickedMeal: AlreadyPickedMeal?
    let textColor: Color
    let dateFormatter: DateFormatter
    
    init(meal: Meal, pickedMeal: AlreadyPickedMeal?, textColor: Color = Color("TextColor")) {
        self.meal = meal
        self.pickedMeal = pickedMeal
        self.textColor = textColor
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .short
    }
    
    var body: some View {
        ZStack {
            MealElement(meal: meal).roundedCornerRectangle().opacity(pickedMeal == nil ? 1 : 0.5)
            if let recentlyPicked = pickedMeal {
                Text(dateFormatter.string(from: recentlyPicked.lastPickedDate))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .roundedCornerRectangle()
                    .offset(y: ViewSizes._50() / 1.8)
            }
        }
    }
}

