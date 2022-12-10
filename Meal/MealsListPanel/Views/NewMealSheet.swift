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
    @State var mealType: MealType
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        MealInfoSheet(
            mealName: $mealName,
            mealType: $mealType,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "New meal", intro: "Enter the info for you new meal, then press Done"),
            confirmButton:
                Button(action: {
                    mealsListPanelVM.createNewMealWith(name: mealName, type: mealType)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "Done")
                })
        )
    }
}

struct EditMealSheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @Binding var meal: Meal
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        MealInfoSheet(
            mealName: $meal.name,
            mealType: $meal.type,
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "Edit meal", intro: "Change the info of your meal"),
            confirmButton:
                Button(action: {
                    mealsListPanelVM.updateMealInfo(meal: meal)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "Confirm")
                })
        )
    }
}

struct MealInfoSheet<ConfirmButton>: View where ConfirmButton: View {
    @Binding var mealName: String
    @Binding var mealType: MealType
    let sheetInfo: MealInfoSheetData
    let confirmButton: ConfirmButton
    @State private var mealNameField: String = ""
    @State private var mealTypeField: MealType = .meat

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(sheetInfo.title)
                .title()
            
            Text(sheetInfo.intro)
            
            Text("Meal name")
                .font(.title)
            
            TextField("Enter meal name", text: $mealNameField)
                .onChange(of: mealNameField) { _ in
                    mealName = mealNameField
                }
                .onAppear() {
                    mealNameField = mealName
                }
            
            Text("Meal type")
                .font(.title)
            
            HStack {
                MealTypeSelector(mealType: .meat, selectedMealType: $mealTypeField)
                MealTypeSelector(mealType: .vegan, selectedMealType: $mealTypeField)
                MealTypeSelector(mealType: .outside, selectedMealType: $mealTypeField)
            }
            .onChange(of: mealTypeField) { _ in
                mealType = mealTypeField
            }
            .onAppear() {
                mealTypeField = mealType
            }
   
            confirmButton
        }.padding(30)
    }
}

struct MealTypeSelector: View {
    let mealType: MealType
    @Binding var selectedMealType: MealType
    var isSelected: Bool {
        mealType == selectedMealType
    }
    
    var body: some View {
        Button(action: {
            selectedMealType = mealType
        }, label: {
            ZStack {
                mealType.getColor()
                Text(mealType.getName())
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }.frame(height: 40).roundedCornerRectangle(padding: 0, cornerRadius: 10).opacity(isSelected ? 1 : 0.7)
        })
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

struct NewMealSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewMealSheet(mealType: .meat)
            .environmentObject(MealsListPanelViewModel())
    }
}
