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

        var body: some View {
            ZStack {
                // Faire une vue commune quand j'ai le temps
                if selectedMealType == .meat {
                    MealList(mealList: mealsListPanelVM.meals.meatMeals)
                } else if selectedMealType == .vegan {
                    MealList(mealList: mealsListPanelVM.meals.veganMeals)
                } else {
                    MealList(mealList: mealsListPanelVM.meals.outsideMeals)
                }
            }
         }
        
        struct MealList: View {
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            let mealList: [Meal]
            
            var body: some View {
                VStack {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns) {
                            ForEach(mealList, id: \.self) { meal in
                                MealGridItem(meal: meal)
                            }
                        }.padding(.vertical, 10)
                    }
                    Spacer()
                }.transition(.slide.combined(with: .opacity))
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
