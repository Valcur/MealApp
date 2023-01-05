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
        ScrollView(.horizontal) {
            HStack {
                HorizontalDayTime()
                
                ForEach(planningPanelVM.weekPlan.week) { day in
                    DayView(dayPlan: day)
                }
            }
        }
    }
    
    struct HorizontalDayTime: View {
        var body: some View {
            VStack {
                Spacer()
                
                Text(TimeOfTheDay.midday.name())
                    .subTitle()
                    .frame(width: 120)
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
                Spacer()
                
                Text(TimeOfTheDay.evening.name())
                    .subTitle()
                    .frame(width: 120)
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
            }.frame(width: 50).padding(.top, ViewSizes._70())
        }
    }
    
    struct DayView: View {
        @ObservedObject var dayPlan: DayPlan
        let dateFormatter: DateFormatter
        let isToday: Bool
        
        init(dayPlan: DayPlan) {
            self.dayPlan = dayPlan
            self.dateFormatter = DateFormatter()
            self.dateFormatter.dateFormat = "d MMM"
            self.isToday = Calendar.current.isDateInToday(dayPlan.date)
        }
        
        var body: some View {
            VStack(spacing: 15) {
                VStack(spacing: 3) {
                    Text(dayPlan.day.name())
                        .title(style: isToday ? .secondary : .primary)
                    
                    Text(dateFormatter.string(from: dayPlan.date))
                        .subTitle(style: .secondary)
                }
                
                Divider()
                
                VStack {
                    DayMealView(dayPlan: dayPlan, time: .midday, meals: dayPlan.midday)
                    
                    Divider()
                        .frame(maxHeight: 10)
                    
                    DayMealView(dayPlan: dayPlan, time: .evening, meals: dayPlan.evening)
                }
                
                Spacer()
            }.frame(width: 200)
        }
        
        
        struct DayMealView: View {
            @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
            @ObservedObject var dayPlan: DayPlan
            @State private var showingNewMealSheet = false
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
                            if planningPanelVM.mealClipboard == nil {
                                Button(action: {
                                    showingNewMealSheet = true
                                }, label: {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                                    .sheet(isPresented: $showingNewMealSheet) {
                                        DayPlanNewMealSheet(dayPlan: dayPlan, time: time)
                                            .environmentObject(planningPanelVM)
                                    }
                                
                                Button(action: {
                                    planningPanelVM.addRandomMeal(day: dayPlan.day, time: time)
                                }, label: {
                                    Image(systemName: "questionmark.square")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                            } else {
                                Button(action: {
                                    planningPanelVM.addClipboardMeal(day: dayPlan.day, time: time)
                                }, label: {
                                    Image(systemName: "doc.on.clipboard")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                            }
                        }
                    }
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
                        //meal.type.getColor().opacity(0.4)
                        Color("WhiteBackgroundColor")
                        Text(meal.name)
                            .fontWeight(.bold)
                            .foregroundColor(meal.type.getColor())
                        
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(meal.type.getColor())
                            .position(x: 18, y: 18)
                            .onTapGesture {
                                showingMealInfoSheet = true
                            }
                    }.roundedCornerRectangle(padding: 2).frame(maxWidth: .infinity)
                    .onTapGesture {  }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        planningPanelVM.copyClipboardMeal(meal, day: dayPlan, time: time)
                    }
                    .sheet(isPresented: $showingMealInfoSheet) {
                        DayPlanMealEditSheet(dayPlan: dayPlan, time: time, meal: $meal, mealType: meal.type)
                            .environmentObject(planningPanelVM)
                    }
                }
            }
        }
    }
}
