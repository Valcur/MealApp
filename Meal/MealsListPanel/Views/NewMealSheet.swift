//
//  NewMealSheet.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import SwiftUI

struct NewMealSheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @State var mealName: String = ""
    @Binding var mealType: MealType
    @State var mealNotes: String? = ""
    @State var mealSides: [Side] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        MealInfoSheet(
            mealName: $mealName,
            mealType: $mealType,
            mealNotes: $mealNotes,
            mealSides: $mealSides,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_new_title", intro: "mealList_new_subtitle"),
            trashButton: AnyView(Spacer()),
            confirmButton:
                AnyView(Button(action: {
                    mealsListPanelVM.createNewMealWith(name: mealName, type: mealType, notes: mealNotes, sides: mealSides)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "done")
                }))
        )
    }
}

struct EditMealSheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @Binding var meal: Meal
    @Environment(\.presentationMode) var presentationMode
    @State var defaultSides = [Side]()
    
    var body: some View {
        MealInfoSheet(
            mealName: $meal.name,
            mealType: $meal.type,
            mealNotes: $meal.notes,
            mealSides: $defaultSides,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_edit_title", intro: "mealList_edit_subtitle"),
            trashButton:
                AnyView(Button(action: {
                    mealsListPanelVM.deleteMeal(meal: meal)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                })),
            confirmButton:
                AnyView(Button(action: {
                    meal.sides = defaultSides
                    mealsListPanelVM.updateMealInfo(meal: meal)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "confirmChangesButton")
                }))
        )
        .onAppear() {
            defaultSides = meal.sides ?? []
        }
    }
}

struct MealInfoSheet: View {
    @State var mealTmp: Meal = Meal.EmptyMEal
    @Binding var mealName: String
    @Binding var mealType: MealType
    @Binding var mealNotes: String?
    @Binding var mealSides: [Side]
    let sheetInfo: MealInfoSheetData
    let trashButton: AnyView
    let confirmButton: AnyView
    @State private var mealNameField: String = ""
    @State private var mealTypeField: MealType = .meat
    @State private var mealNotesField: String = "This is some editable text..."
    @State private var showingNotesSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(NSLocalizedString(sheetInfo.title, comment: sheetInfo.title))
                    .title()
                
                Spacer()
                                
                trashButton
            }
            
            Text(NSLocalizedString(sheetInfo.intro, comment: sheetInfo.intro))
                .headLine()
            
            VStackBlock {
                Text(NSLocalizedString("mealList_name_title", comment: "mealList_name_title"))
                    .subTitle()
                
                TextField(NSLocalizedString("mealList_name_placeholder", comment: "mealList_name_placeholder"), text: $mealNameField)
                    .textFieldBackground()
            }
            
            VStackBlock {
                Text(NSLocalizedString("mealList_type_title", comment: "mealList_type_title"))
                    .subTitle()
                
                MealTypeSelection(selectedMealType: $mealTypeField)
            }
            
            VStackBlock {
                Text(NSLocalizedString("mealList_notes_title", comment: "mealList_notes_title"))
                    .subTitle()
                
                Button(action: {
                    showingNotesSheet = true
                }, label: {
                    ButtonLabel(title: "mealPlan_notes_edit_title", isCompact: true)
                })
            }
            
            VStackBlock {
                Text("mealList_defaultSides".translate())
                    .subTitle()
                
                SidePickerView(selectedSides: $mealSides)
            }
            
            Spacer()
        }.scrollableSheetVStackWithStickyButton(button: confirmButton)
            .background(Color("BackgroundColor"))
            .onChange(of: mealNameField) { _ in
                mealName = mealNameField
            }
            .onAppear() {
                mealNameField = mealName
            }
            .onChange(of: mealTypeField) { _ in
                mealType = mealTypeField
            }
            .onAppear() {
                mealTypeField = mealType
            }
            .onChange(of: mealTmp.notes) { _ in
                mealNotes = mealTmp.notes
            }
            .onAppear() {
                mealTmp.notes = mealNotes ?? ""
            }
            .sheet(isPresented: $showingNotesSheet) {
                MealEditNotesSheet(meal: $mealTmp)
            }
    }
}
                      
struct MealInfoSheetData {
    let sheetType: SheetType
    let title: String
    let intro: String

    enum SheetType {
      case newMeal
      case editMeal
    }
}
