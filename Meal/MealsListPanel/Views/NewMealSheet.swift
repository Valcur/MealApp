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
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_new_title", intro: "mealList_new_subtitle"),
            showBin: false,
            confirmButton:
                Button(action: {
                    mealsListPanelVM.createNewMealWith(name: mealName, type: mealType)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "done")
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
            sheetInfo: MealInfoSheetData(sheetType: .newMeal, title: "mealList_edit_title", intro: "mealList_edit_subtitle"),
            showBin: false,
            confirmButton:
                Button(action: {
                    mealsListPanelVM.updateMealInfo(meal: meal)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "confirmChangesButton")
                })
        )
    }
}

struct MealInfoSheet<ConfirmButton>: View where ConfirmButton: View {
    @Binding var mealName: String
    @Binding var mealType: MealType
    let sheetInfo: MealInfoSheetData
    let showBin: Bool
    let confirmButton: ConfirmButton
    @State private var mealNameField: String = ""
    @State private var mealTypeField: MealType = .meat

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text(NSLocalizedString(sheetInfo.title, comment: sheetInfo.title))
                    .title()
                
                Spacer()
                                
                if showBin {
                    Button(action: {
                        // Delete
                        //presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    })
                }
            }
            
            Text(NSLocalizedString(sheetInfo.intro, comment: sheetInfo.intro))
            
            Text(NSLocalizedString("mealList_name_title", comment: "mealList_name_title"))
                .font(.title)
            
            TextField(NSLocalizedString("mealList_name_placeholder", comment: "mealList_name_placeholder"), text: $mealNameField)
                .onChange(of: mealNameField) { _ in
                    mealName = mealNameField
                }
                .onAppear() {
                    mealNameField = mealName
                }
            
            Text(NSLocalizedString("mealList_type_title", comment: "mealList_type_title"))
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
            
            Spacer()
   
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
                    .foregroundColor(Color("TextColor"))
            }.frame(height: 40).roundedCornerRectangle(padding: 0, cornerRadius: 10).opacity(isSelected ? 1 : 0.5)
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
