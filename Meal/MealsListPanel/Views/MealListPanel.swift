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
                // Faire une vue commune quand j'ai le temps
                if selectedMealType == .meat {
                    VStack {
                        MealTypeDesription(text: "mealList_meat_intro")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.meatMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }.transition(.slide.combined(with: .opacity))
                } else if selectedMealType == .vegan {
                    VStack {
                        MealTypeDesription(text: "mealList_vegan_intro")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.veganMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }.transition(.slide.combined(with: .opacity))
                } else {
                    VStack {
                        MealTypeDesription(text: "mealList_outside_intro")
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns) {
                                ForEach(mealsListPanelVM.meals.outsideMeals, id: \.self) { meal in
                                    MealGridItem(meal: meal)
                                }
                            }
                        }
                        Spacer()
                    }.transition(.slide.combined(with: .opacity))
                }
            }
         }
    }
    
    struct MealTypeDesription: View {
        let text: String
        
        var body: some View {
            HStack {
                Text(NSLocalizedString(text, comment: text))
                    .subTitle()
                Spacer()
            }
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
                    .lineLimit(2)
                    .frame(height: 50)
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
