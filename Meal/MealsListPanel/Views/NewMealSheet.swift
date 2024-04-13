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
    @State var mealRecipe: Recipe? = nil
    @State var mealSides: [Side] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        MealInfoSheet(
            mealName: $mealName,
            mealType: $mealType,
            mealNotes: $mealNotes,
            mealRecipe: $mealRecipe,
            mealSides: $mealSides,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_new_title", intro: "mealList_new_subtitle"),
            trashButton: AnyView(Spacer()),
            confirmButton:
                AnyView(Button(action: {
                    mealsListPanelVM.createNewMealWith(name: mealName, type: mealType, notes: mealNotes, recipe: mealRecipe, sides: mealSides)
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
    @State var mealName: String = ""
    @State var mealType: MealType = .outside
    @State var mealNotes: String?
    @State var mealRecipe: Recipe?
    @State var showDeleteMealAlert = false
    
    var body: some View {
        MealInfoSheet(
            mealName: $mealName,
            mealType: $mealType,
            mealNotes: $mealNotes,
            mealRecipe: $mealRecipe,
            mealSides: $defaultSides,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_edit_title", intro: "mealList_edit_subtitle"),
            trashButton:
                AnyView(Button(action: {
                    showDeleteMealAlert = true
                }, label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                })),
            confirmButton:
                AnyView(Button(action: {
                    meal.sides = defaultSides
                    meal.name = mealName
                    meal.type = mealType
                    meal.notes = mealNotes
                    meal.recipe = mealRecipe
                    mealsListPanelVM.updateMealInfo(meal: meal)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "confirmChangesButton")
                }))
        )
        .onAppear() {
            defaultSides = meal.sides ?? []
            mealName = meal.name
            mealType = meal.type
            mealNotes = meal.notes
            mealRecipe = meal.recipe
        }
        .alert(isPresented: $showDeleteMealAlert) {
            Alert(
                title: Text("mealList_delete_title".translate()),
                message: Text("mealList_delete_content".translate()),
                primaryButton: .default(
                    Text("cancel".translate()),
                    action: {showDeleteMealAlert = false}
                ),
                secondaryButton: .destructive(
                    Text("delete".translate()),
                    action: {
                        mealsListPanelVM.deleteMeal(meal: meal)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            )
        }
    }
}

struct MealInfoSheet: View {
    @State var mealTmp: Meal = Meal.EmptyMEal
    @Binding var mealName: String
    @Binding var mealType: MealType
    @Binding var mealNotes: String?
    @Binding var mealRecipe: Recipe?
    @Binding var mealSides: [Side]
    let sheetInfo: MealInfoSheetData
    let trashButton: AnyView
    let confirmButton: AnyView
    @State private var mealNameField: String = ""
    @State private var mealTypeField: MealType = .meat
    @State private var mealNotesField: String = "This is some editable text..."
    @State private var showingNotesSheet = false
    @State private var showingRecipeSheet = false
    @State private var showDeleteRecipeAlert = false

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
            
            HStack(spacing: 20) {
                VStackBlock {
                    HStack {
                        Text("mealList_notes_title".translate())
                            .subTitle()
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        showingNotesSheet = true
                    }, label: {
                        ButtonLabel(title: "mealPlan_notes_edit_title", isCompact: true)
                    })
                }
                
                if #available(iOS 15.0, *) {
                    VStackBlock {
                        HStack {
                            Text("recipe".translate())
                                .subTitle()
                            
                            Spacer()
                            
                            if mealRecipe != nil {
                                Button(action: {
                                    showDeleteRecipeAlert = true
                                }, label: {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                })
                                .alert("recipe_delete_title".translate(), isPresented: $showDeleteRecipeAlert) {
                                    Button("delete".translate(), role: .destructive) {
                                        mealRecipe = nil
                                    }
                                    Button("cancel".translate(), role: .cancel) {
                                        
                                    }
                                } message: {
                                    Text("recipe_delete_content".translate())
                                }
                            }
                        }
                        
                        Button(action: {
                            showingRecipeSheet = true
                        }, label: {
                            ButtonLabel(title: mealRecipe == nil ? "add" : "edit", isCompact: true)
                        })
                    }
                    .sheet(isPresented: $showingRecipeSheet) {
                        RecipeSheetWrapper(mealName: mealName, mealType: mealType, recipe: $mealRecipe)
                    }
                }
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
            .onChange(of: mealName) { _ in
                if mealName != mealNameField {
                    mealNameField = mealName
                    mealTypeField = mealType
                }
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
