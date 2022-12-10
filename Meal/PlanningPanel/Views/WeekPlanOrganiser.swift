//
//  weekPlanOrganiser.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import UniformTypeIdentifiers
import SwiftUI

struct WeekPlanOrganiser: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("This week")
                    .subTitle()
                Spacer()
                Text("Next week")
                    .subTitle(style: .secondary)
                Spacer()
                Text("Autofill")
                    .subTitle()
                Text("Autofill options")
                    .subTitle(style: .secondary)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    HorizontalDayTime()
                    
                    ForEach(planningPanelVM.weekPlan.week) { day in
                        DayView(dayPlan: day)
                    }
                }
            }
             
        }
    }
    
    struct HorizontalDayTime: View {
        var body: some View {
            VStack {
                Spacer()
                
                Text("Midi")
                    .subTitle()
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
                
                Text("Soir")
                    .subTitle()
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
            }.frame(width: 50).padding(.top, 70)
        }
    }
    
    struct DayView: View {
        @ObservedObject var dayPlan: DayPlan
        
        var body: some View {
            VStack(spacing: 15) {
                VStack(spacing: 3) {
                    Text(dayPlan.day.name())
                        .title()
                    
                    Text("2 november")
                        .subTitle()
                }
                
                Divider()
                
                VStack {
                    DayMealView(dayPlan: dayPlan, time: .midday, meals: dayPlan.midday)
                    
                    Divider()
                        .frame(height: 10)
                    
                    DayMealView(dayPlan: dayPlan, time: .evening, meals: dayPlan.evening)
                }
                
                Spacer()
            }.frame(width: 200)
        }
        
        
        struct DayMealView: View {
            @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
            @ObservedObject var dayPlan: DayPlan
            let time: TimeOfTheDay
            let meals: [Meal]
            
            var body: some View {
                VStack {
                    if meals.count > 0 {
                        ForEach(meals) { meal in
                            MealView(dayPlan: dayPlan, time: time, meal: meal)
                        }
                    }
                    if meals.count < 3 {
                        Spacer()
                        HStack {
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }).padding(5)
                            
                            Button(action: {
                                planningPanelVM.addRandomMeal(day: dayPlan.day, time: time)
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }).padding(5)
                        }
                    }
                    Spacer()
                }
            }
            
            struct MealView: View {
                @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
                @State private var showingMealInfoSheet = false
                @ObservedObject var dayPlan: DayPlan
                let time: TimeOfTheDay
                @State var meal: Meal
                
                var body: some View {
                    ZStack {
                        meal.type.getColor()
                        Text(meal.name)
                            .fontWeight(.bold)
                        Button(action: {
                            showingMealInfoSheet = true
                        }, label: {
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .position(x: 20, y: 20)
                        })
                    }.roundedCornerRectangle(padding: 0).frame(maxWidth: .infinity)
                    .sheet(isPresented: $showingMealInfoSheet) {
                        DayPlanMealEditSheet(dayPlan: dayPlan, time: time, meal: $meal, mealType: meal.type)
                            .environmentObject(planningPanelVM)
                    }
                }
            }
        }
    }
}
