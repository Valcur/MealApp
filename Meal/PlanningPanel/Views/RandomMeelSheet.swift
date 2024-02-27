//
//  RandomMeelSheet.swift
//  Meal
//
//  Created by Loic D on 29/01/2024.
//

import SwiftUI

struct RandomMeelSheet: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @Environment(\.presentationMode) var presentationMode
    @State var mealsPropositions = [Meal]()
    let day: WeekDays
    let time: TimeOfTheDay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("randomMeals_title".translate())
                .title()
            
            HStack {
                Text("\("randomMeals_content".translate()) \(day.name().lowercased()) \(time.name().lowercased())" )
                    .headLine()
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        mealsPropositions = planningPanelVM.getThreeRnadomMealsPropositions()
                    }
                }, label: {
                    ButtonLabel(title: "randomMeals_refresh", isCompact: true)
                })
            }
            
            if UIDevice.isIPhone {
                VStack {
                    ForEach(mealsPropositions, id: \.id) { meal in
                        Button(action: {
                            planningPanelVM.addMeal(meal, day: day, time: time)
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            MealElement(meal: meal, textColor: Color("BackgroundColor")).roundedCornerRectangle(color: meal.type.getColor(userPrefs: userPrefs))
                        })
                    }
                }.frame(maxWidth: .infinity)
            } else {
                HStack {
                    ForEach(mealsPropositions, id: \.id) { meal in
                        Button(action: {
                            planningPanelVM.addMeal(meal, day: day, time: time)
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            MealElement(meal: meal, textColor: Color("BackgroundColor")).roundedCornerRectangle(color: meal.type.getColor(userPrefs: userPrefs))
                        })
                    }
                }.frame(maxWidth: .infinity)
            }
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "cancel")
            })
        }.scrollableSheetVStack()
            .onAppear() {
                mealsPropositions = planningPanelVM.getThreeRnadomMealsPropositions()
            }
    }
}
