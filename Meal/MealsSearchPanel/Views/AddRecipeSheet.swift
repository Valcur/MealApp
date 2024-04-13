//
//  AddRecipeSheet.swift
//  Meal
//
//  Created by Loic D on 20/07/2023.
//

import SwiftUI


struct AddRecipeSheet: View {
    @EnvironmentObject var mealsListVM: MealsListPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    let recipe: OnlineRecipe
    private let stackSpacing: CGFloat = 15
    @State private var mealNameField: String = ""
    @State private var mealNotesField: String = ""
    @State private var mealTypeField: MealType = .meat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add recipe".translate())
                .title()
            VStack(alignment: .leading, spacing: stackSpacing) {
                Text("Name".translate())
                    .subTitle()
                
                TextField("PLACEHOLDER".translate(), text: $mealNameField)
                    .textFieldBackground()
            }
            
            VStack(alignment: .leading, spacing: stackSpacing) {
                Text("mealList_type_title".translate())
                    .subTitle()
                
                MealTypeSelection(selectedMealType: $mealTypeField)
            }

            VStack(alignment: .leading, spacing: stackSpacing) {
                Text("Notes")
                    .subTitle()
                
                NotesTextField(mealNotesField: $mealNotesField)
                    .textFieldBackground()
            }
            
            Spacer()
        }.safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                //mealsListVM.createNewMealWith(name: mealNameField, type: mealTypeField, notes: mealNotesField)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "Add")
            })
        ))
            .onAppear() {
                self.mealNameField = recipe.name
                self.mealNotesField = "Preparation" + "\n------------------\n" +
                recipe.preparation + "\n\n\n" + "Ingredients" + "\n------------------\n"
                for ingredient in recipe.ingredients {
                    self.mealNotesField += "- \(ingredient)\n"
                }
            }
    }
}
