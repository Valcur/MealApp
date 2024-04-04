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
            ScrollViewReader { reader in
                HStack {
                    HorizontalDayTime()
                        .id(-1)
                    
                    ForEach(planningPanelVM.weekPlan.week) { day in
                        DayView(dayPlan: day)
                            .id(day.day)
                    }
                }
                .padding(.trailing, 20).padding(.top, 10)
                .onAppear() {
                    for day in planningPanelVM.weekPlan.week {
                        if Calendar.current.isDateInToday(day.date) {
                            if day.day == .monday {
                                reader.scrollTo(-1, anchor: .bottomLeading)
                            } else {
                                if UIDevice.isIPhone {
                                    if day.day == .sunday {
                                        reader.scrollTo(day.day, anchor: .bottomTrailing)
                                    } else {
                                        reader.scrollTo(day.day, anchor: .bottomLeading)
                                    }
                                } else {
                                    reader.scrollTo(day.day)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct HorizontalDayTime: View {
        var body: some View {
            VStack {
                Spacer()
                
                Text(TimeOfTheDay.midday.name())
                    .headLine()
                    .frame(width: 90)
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
                Spacer()
                
                Text(TimeOfTheDay.evening.name())
                    .headLine()
                    .frame(width: 90)
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()
            }.frame(width: 50).padding(.top, ViewSizes._70())
        }
    }
    
    struct DayView: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
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
            VStack(spacing: 10) {
                VStack(spacing: 3) {
                    Text(dayPlan.day.name())
                        .title(style: isToday ? .secondary : .primary, accentColor: userPrefs.accentColor)
                 
                    Text(dateFormatter.string(from: dayPlan.date))
                        .subTitle(style: .secondary)
                }
                
                Divider()
                    .opacity(userPrefs.isUsingDefaultBackground ? 1 : 0)
                
                VStack(spacing: 0) {
                    DayMealView(dayPlan: dayPlan, time: .midday, meals: dayPlan.midday, isToday: isToday)
                    
                    Divider()
                        .frame(height: 20)
                        .opacity(userPrefs.isUsingDefaultBackground ? 1 : 0)
                    
                    DayMealView(dayPlan: dayPlan, time: .evening, meals: dayPlan.evening, isToday: isToday)
                }
            }.frame(width: 200).padding(.bottom, 12)
        }
        
        
        struct DayMealView: View {
            @EnvironmentObject var userPrefs: VisualUserPrefs
            @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
            @ObservedObject var dayPlan: DayPlan
            @State private var showingNewMealSheet = false
            @State private var showingRandomMealSheet = false
            let time: TimeOfTheDay
            let meals: [Meal]
            let isToday: Bool
                
            var body: some View {
                VStack {
                    if meals.count > 0 {
                        ForEach(meals, id: \.uuid) { meal in
                            MealView(dayPlan: dayPlan, time: time, meal: meal, isToday: isToday)
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
                                        .foregroundColor(isToday ? userPrefs.accentColor : Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                                    .sheet(isPresented: $showingNewMealSheet) {
                                        DayPlanNewMealSheet(dayPlan: dayPlan, time: time)
                                            .environmentObject(planningPanelVM)
                                    }
                                
                                Button(action: {
                                    showingRandomMealSheet = true
                                }, label: {
                                    Image(systemName: "questionmark.square")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(isToday ? userPrefs.accentColor : Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                                    .sheet(isPresented: $showingRandomMealSheet) {
                                        RandomMeelSheet(day: dayPlan.day, time: time)
                                    }
                            } else {
                                Button(action: {
                                    planningPanelVM.addClipboardMeal(day: dayPlan.day, time: time)
                                }, label: {
                                    Image(systemName: "doc.on.clipboard")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(isToday ? userPrefs.accentColor : Color("TextColor"))
                                }).padding(5).transition(.slide.combined(with: .opacity))
                            }
                        }.padding(5).background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                                .cornerRadius(10)
                                .opacity(userPrefs.showButtonbackground ? 1 : 0)
                        ).padding(-5)
                    }
                }
            }
            
            struct MealView: View {
                @EnvironmentObject var userPrefs: VisualUserPrefs
                @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
                @State private var showingMealInfoSheet = false
                @State private var showingNotesSheet = false
                @ObservedObject var dayPlan: DayPlan
                let time: TimeOfTheDay
                @State var meal: Meal
                var mealHasNotes: Bool {
                    return meal.notes != nil && meal.notes! != ""
                }
                let isToday: Bool
                @State var isLongPressing = false
                @State var longPressProgress: CGFloat = 0
                
                var body: some View {
                    ZStack {
                        Color("WhiteBackgroundColor")
                        
                        VStack(spacing: 1) {
                            Text(meal.name)
                                .fontWeight(.bold)
                                .foregroundColor(meal.type.getColor(userPrefs: userPrefs))
                                .padding(.horizontal, 30)
                            if meal.sides?.count ?? 0 > 0 {
                                Text(Side.sidesNameDescription(meal.sides ?? []))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(meal.type.getColor(userPrefs: userPrefs))
                                    .padding(.horizontal, 10)
                            }
                        }.allowsHitTesting(false)

                        VStack {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .frame(width: 25, height: 20)
                                    .foregroundColor(meal.type.getColor(userPrefs: userPrefs))
                                    .onTapGesture {
                                        showingMealInfoSheet = true
                                    }
                                
                                Spacer()
                                
                                Image(systemName: mealHasNotes ? "note.text" : "plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(meal.type.getColor(userPrefs: userPrefs))
                                    .onTapGesture {
                                        showingNotesSheet = true
                                    }.opacity(mealHasNotes ? 1 : 0.3)
                            }.padding(8)
                            Spacer()
                        }
                    }.padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isToday ? userPrefs.accentColor : Color.clear, lineWidth: 4)
                    )
                    .roundedCornerRectangle(padding: 0).frame(maxWidth: .infinity)
                    
                    .scaleEffect(1 - longPressProgress)
                    .opacity(1 - longPressProgress)
                    .delaysTouches(for: 0.05) {
                        //some code here, if needed
                    }
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            if !isLongPressing {
                                isLongPressing = true
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    longPressProgress = 0.2
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    if isLongPressing {
                                        isLongPressing = false
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            longPressProgress = 0
                                        }
                                        planningPanelVM.copyClipboardMeal(meal, day: dayPlan, time: time)
                                    }
                                })
                            }
                        })
                        .onEnded({ _ in
                            isLongPressing = false
                            withAnimation(.easeInOut(duration: 0.5)) {
                                longPressProgress = 0
                            }
                        })
                    )
                    .sheet(isPresented: $showingMealInfoSheet) {
                        DayPlanMealEditSheet(dayPlan: dayPlan, time: time, meal: $meal, mealType: meal.type)
                            .environmentObject(planningPanelVM)
                    }
                    .sheet(isPresented: $showingNotesSheet) {
                        WeekPlanNotesSheet(dayPlan: dayPlan, time: time, meal: $meal)
                    }
                    
                }
            }
        }
    }
}
