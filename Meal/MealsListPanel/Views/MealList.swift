//
//  MealList.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import SwiftUI

extension MealsListPanel {
    struct MealList: View {
        @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
        @Binding var selectedMealType: MealType
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        var body: some View {
            ZStack {
                if selectedMealType == .meat {
                    VStack {
                        MealTypeDesription(text: "When you don't want to bother")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.meatMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }
                } else if selectedMealType == .vegan {
                    VStack {
                        MealTypeDesription(text: "When you don't want to eat meat")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.veganMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }
                } else {
                    VStack {
                        MealTypeDesription(text: "When you don't want to cook")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.outsideMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
         }
    }
    
    struct MealTypeDesription: View {
        let text: String
        
        var body: some View {
            Text(text)
                .font(.caption)
        }
    }
    
    struct MealGridItem: View {
        @State private var showingMealInfoSheet = false
        @State var meal: Meal
        
        var body: some View {
            HStack {
                Text(meal.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    showingMealInfoSheet = true
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                })
            }.roundedCornerRectangle()
            .sheet(isPresented: $showingMealInfoSheet) {
                EditMealSheet(meal: $meal)
            }
        }
    }
}
