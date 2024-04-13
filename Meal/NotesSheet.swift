//
//  NotesSheet.swift
//  Meal
//
//  Created by Loic D on 16/03/2023.
//

import SwiftUI

struct WeekPlanNotesSheet: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var dayPlan: DayPlan
    let time: TimeOfTheDay
    @Binding var meal: Meal
    @State var mealIndex = -1
    @State private var mealNotesField: String = "Add notes ..."
    @State private var showRecipe = false
    
    var body: some View {
        VStack {
            if let recipe = meal.recipe {
                Button(action: {
                    showRecipe = true
                }, label: {
                    ButtonLabel(title: "Voir Recette")
                }).padding(.horizontal, 20).padding(.top, 20)
                .fullScreenCover(isPresented: $showRecipe) {
                    FullScreenRecipe(recipe, meal: meal)
                }
            }
            NotesSheet(meal: $meal, mealNotesField: $mealNotesField).sheetVStackWithStickyButton(button: AnyView(Button(action: {
                if mealNotesField != "" {
                    meal.notes = mealNotesField
                } else {
                    meal.notes = nil
                }
                if time == .midday && mealIndex >= 0 {
                    dayPlan.midday[mealIndex] = meal
                } else if time == .evening && mealIndex >= 0 {
                    dayPlan.evening[mealIndex] = meal
                }
                dayPlan.objectWillChange.send()
                planningPanelVM.saveWeek()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })))
        }
        .onAppear() {
            if time == .midday {
                mealIndex = dayPlan.midday.firstIndex(where: {$0.uuid == meal.uuid}) ?? -1
            } else if time == .evening {
                mealIndex = dayPlan.evening.firstIndex(where: {$0.uuid == meal.uuid}) ?? -1
            }
        }
    }
}

struct MealEditNotesSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var meal: Meal
    @State private var mealNotesField: String = "Add notes ..."
    
    var body: some View {
        NotesSheet(meal: $meal, mealNotesField: $mealNotesField).sheetVStackWithStickyButton(button: AnyView(Button(action: {
            if mealNotesField != "" {
                meal.notes = mealNotesField
            } else {
                meal.notes = nil
            }
            meal = meal.new()
            presentationMode.wrappedValue.dismiss()
        }, label: {
            ButtonLabel(title: "confirmChangesButton")
        })))
    }
}

struct NotesSheet: View {
    @Binding var meal: Meal
    @Binding var mealNotesField: String
    @State var sheetTitle: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(sheetTitle)
                .title()
            
            NotesTextField(mealNotesField: $mealNotesField)
                .onAppear() {
                    mealNotesField = meal.notes ?? ""
                    sheetTitle = meal.hasNotes() ? NSLocalizedString("mealPlan_notes_edit_title", comment: "mealPlan_notes_edit_title") :
                                                   NSLocalizedString("mealPlan_notes_new_title", comment: "mealPlan_notes_new_title")
                }
            Spacer()
        }
    }
}

struct NotesTextField: View {
    @Binding var mealNotesField: String
    let vPadding: CGFloat = 3
    let hPadding: CGFloat = 6
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if #available(iOS 16.0, *) {
                ZStack {
                    Text(mealNotesField).opacity(0).padding(.all, 10)
                    TextEditor(text: $mealNotesField)
                        .textFieldBackground(hPadding: hPadding, vPadding: vPadding)
                        .scrollContentBackground(.hidden)
                }
            } else {
                ZStack {
                    Text(mealNotesField).opacity(0).padding(.all, 10)
                    TextEditor(text: $mealNotesField)
                        .textFieldBackground(hPadding: hPadding, vPadding: vPadding)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
            }
            
            if mealNotesField.isEmpty {
                Text(NSLocalizedString("notes_placeholder", comment: "notes_placeholder"))
                    .foregroundColor(Color(UIColor.systemGray2))
                    .padding(.all, 10)
                    .allowsHitTesting(false)
            }
        }
    }
}
