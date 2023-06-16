//
//  MealScheduleSheet.swift
//  Meal
//
//  Created by Loic D on 16/12/2022.
//

import SwiftUI

struct NewMealSchedule: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @State var selectedMeal: Meal = .EmptyMEal
    @State var selectedDays: [Bool] = [false, false, false, false, false, false, false]
    @State var selectedHours: [Bool] = [false, false]
    
    var body: some View {
        MealScheduleScheet(title: "options_schedule_new_title",
                           intro: "options_schedule_new_mealChoice_subtitle",
                           selectedMeal: $selectedMeal,
                           selectedDays: $selectedDays,
                           selectedHours: $selectedHours,
                           trashButton: AnyView(Spacer()),
                           confirmButton:
                            AnyView(Button(action: {
                                configurePanelVM.newSchedule(meal: selectedMeal, selectedDays: selectedDays, selectedHours: selectedHours)
                            }, label: {
                                ButtonLabel(title: "options_schedule_new_confirmButton")
                            })))
    }
}

struct EditMealSchedule: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    let selectedSchedule: Schedule
    @State var selectedMeal: Meal
    @State var selectedDays: [Bool]
    @State var selectedHours: [Bool]
    
    init(selectedSchedule: Schedule) {
        self.selectedSchedule = selectedSchedule
        self.selectedDays = [selectedSchedule.days.contains(where: {$0 == .monday}),
                             selectedSchedule.days.contains(where: {$0 == .tuesday}),
                             selectedSchedule.days.contains(where: {$0 == .wednesday}),
                             selectedSchedule.days.contains(where: {$0 == .thursday}),
                             selectedSchedule.days.contains(where: {$0 == .friday}),
                             selectedSchedule.days.contains(where: {$0 == .saturday}),
                             selectedSchedule.days.contains(where: {$0 == .sunday})]
        
        self.selectedHours = [selectedSchedule.time.contains(where: {$0 == .midday}),
                              selectedSchedule.time.contains(where: {$0 == .evening})]
        
        self.selectedMeal = selectedSchedule.meal
    }
    
    var body: some View {
        MealScheduleScheet(title: "options_schedule_edit_title",
                           intro: "options_schedule_edit_mealChoice_subtitle",
                           selectedMeal: $selectedMeal,
                           selectedDays: $selectedDays,
                           selectedHours: $selectedHours,
                           trashButton:
                                AnyView(Button(action: {
                                    configurePanelVM.removeSchedule(schedule: selectedSchedule)
                                }, label: {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                })),
                           confirmButton:
                                AnyView(Button(action: {
                                    configurePanelVM.editSchedule(meal: selectedMeal, selectedDays: selectedDays, selectedHours: selectedHours, schedule: selectedSchedule)
                                }, label: {
                                    ButtonLabel(title: "confirmChangesButton")
                                })))
    }
}

struct MealScheduleScheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    let title: String
    let intro: String
    @Binding var selectedMeal: Meal
    @Binding var selectedDays: [Bool]
    @Binding var selectedHours: [Bool]
    let trashButton: AnyView
    let confirmButton: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            trashButton
            
            Text(NSLocalizedString(intro, comment: intro))
                .headLine()
            
            MealPicker(selectedMeal: $selectedMeal, mealsList: mealsListPanelVM.meals)
            
            Text(NSLocalizedString("options_schedule_new_subtitle", comment: "options_schedule_new_subtitle"))
                .headLine()
            
            DaySelector(selectedDays: $selectedDays, selectedHours: $selectedHours)
            
            Spacer()
            
            confirmButton
        }.scrollableSheetVStack()
        .navigationTitle(NSLocalizedString(title, comment: title))
    }
    
    struct DaySelector: View {
        
        @Binding var selectedDays: [Bool]
        @Binding var selectedHours: [Bool]
        
        var body: some View {
            if UIDevice.current.userInterfaceIdiom == .phone {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        DayView(day: .monday, isSelected: $selectedDays[0])
                        DayView(day: .tuesday, isSelected: $selectedDays[1])
                        DayView(day: .wednesday, isSelected: $selectedDays[2])
                        DayView(day: .thursday, isSelected: $selectedDays[3])
                        DayView(day: .friday, isSelected: $selectedDays[4])
                        DayView(day: .saturday, isSelected: $selectedDays[5])
                        DayView(day: .sunday, isSelected: $selectedDays[6])
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        HourView(hour: .midday, isSelected: $selectedHours[0])
                        HourView(hour: .evening, isSelected: $selectedHours[1])
                        Spacer()
                    }
                }
            } else {
                HStack {
                    DayView(day: .monday, isSelected: $selectedDays[0])
                    DayView(day: .tuesday, isSelected: $selectedDays[1])
                    DayView(day: .wednesday, isSelected: $selectedDays[2])
                    DayView(day: .thursday, isSelected: $selectedDays[3])
                    DayView(day: .friday, isSelected: $selectedDays[4])
                    DayView(day: .saturday, isSelected: $selectedDays[5])
                    DayView(day: .sunday, isSelected: $selectedDays[6])
                    
                    Spacer()
                    
                    HourView(hour: .midday, isSelected: $selectedHours[0])
                    HourView(hour: .evening, isSelected: $selectedHours[1])
                }
            }
        }
        
        struct HourView: View {
            let hour: TimeOfTheDay
            @Binding var isSelected: Bool
            
            var body: some View {
                Button(action: {
                    isSelected.toggle()
                }, label: {
                    hour.image()
                        .foregroundColor(isSelected ? .white : Color("AccentColor"))
                        .padding(10)
                }).frame(width: 40, height: 40).background(Color("AccentColor").opacity(isSelected ? 1 : 0.0).cornerRadius(20).shadow(color: Color("ShadowColor"), radius: 5)).padding(ViewSizes._5())
            }
        }
        
        struct DayView: View {
            let day: WeekDays
            @Binding var isSelected: Bool
            
            var body: some View {
                Button(action: {
                    isSelected.toggle()
                }, label: {
                    Text(day.name().prefix(2))
                        .foregroundColor(isSelected ? .white : Color("AccentColor"))
                }).frame(width: 40, height: 40).background(Color("AccentColor").opacity(isSelected ? 1 : 0.0).cornerRadius(20).shadow(color: Color("ShadowColor"), radius: 5)).padding(ViewSizes._5())
            }
        }
    }
}
