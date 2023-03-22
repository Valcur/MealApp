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
    @Binding var meal: Meal
    @State private var mealNotesField: String = "This is some editable text..."
    
    var body: some View {
        NotesSheet(meal: $meal, mealNotesField: $mealNotesField).sheetVStackWithStickyButton(button: AnyView(Button(action: {
            if mealNotesField != "" {
                meal.notes = mealNotesField
            } else {
                meal.notes = nil
            }
            meal = meal.new()
            planningPanelVM.saveWeek()
            presentationMode.wrappedValue.dismiss()
        }, label: {
            ButtonLabel(title: "confirmChangesButton")
        })))
    }
}

struct MealEditNotesSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var meal: Meal
    @State private var mealNotesField: String = "This is some editable text..."
    
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