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
                }  else if selectedMealType == .other {
                    MealList(mealList: mealsListPanelVM.meals.otherMeals)
                } else {
                    MealList(mealList: mealsListPanelVM.meals.outsideMeals)
                }
            }
         }
        
        struct MealList: View {
            let columns = ViewSizes._MealList_GridColumns()
            let mealList: [Meal]
            
            var body: some View {
                VStack {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns) {
                            ForEach(mealList, id: \.self) { meal in
                                MealGridItem(meal: meal)
                            }
                            Spacer()
                        }.padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 100)
                    }
                }.transition(.slide.combined(with: .opacity))
            }
        }
    }
    
    struct MealGridItem: View {
        @State private var showingMealInfoSheet = false
        @State var meal: Meal
        
        var body: some View {
            HStack {
                MealElement(meal: meal)
                
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
