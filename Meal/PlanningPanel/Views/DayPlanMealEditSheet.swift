//
//  DayPlanMealEditSheet.swift
//  Meal
//
//  Created by Loic D on 09/12/2022.
//

import SwiftUI

struct DayPlanMealEditSheet: View {
    @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var dayPlan: DayPlan
    let time: TimeOfTheDay
    
    @Binding var meal: Meal
    @State var mealType: MealType = .meat
    @State var customMealName: String = ""
    @State var selection = 0
    @State var editChoice: EditMealChoice = .choose
    
    var mealsAvailable: [Meal] {
        switch mealType {
        case .meat:
            return planningPanelVM.mealsVM.meals.meatMeals
        case .vegan:
            return planningPanelVM.mealsVM.meals.veganMeals
        case .outside:
            return planningPanelVM.mealsVM.meals.outsideMeals
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Edit info")
                .title()
            
            Text(dayPlan.day.name())
            
            HStack {
                Text("Change meal")
                    .font(.title)
                
                Spacer()
                                
                Button(action: {
                    if time == .midday {
                        dayPlan.midday.removeAll(where: {$0.id == meal.id})
                    } else {
                        dayPlan.evening.removeAll(where: {$0.id == meal.id})
                    }
                    dayPlan.objectWillChange.send()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                })
            }
            
            HStack {
                MealTypeSelector(mealType: .meat, selectedMealType: $mealType)
                MealTypeSelector(mealType: .vegan, selectedMealType: $mealType)
                MealTypeSelector(mealType: .outside, selectedMealType: $mealType)
            }
            
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .choose
                    }
                }, label: {
                    Text("Choose")
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .write
                    }
                }, label: {
                    Text("Write")
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .leftOver
                    }
                }, label: {
                    Text("LeftOver")
                })
            }
            
            if editChoice == .choose {
                Picker("Meals to choose from", selection: $selection) {
                    ForEach(mealsAvailable) { meal in
                        Text(meal.name)
                    }
                }.onChange(of: mealsAvailable) { _ in
                    selection = mealsAvailable.firstIndex(where: {$0.id == meal.id}) ?? 0
                }
                .onChange(of: selection, perform: { newValue in
                    print(newValue)
                })
            } else if editChoice == .write {
                Text("Choose a custom name for this one time meal")
                TextField("Enter meal name", text: $customMealName)
            } else {
                Text("Leftover")
            }

            Button(action: {
                if editChoice == .choose {
                    let index = mealsAvailable.firstIndex(where: {$0.id == meal.id}) ?? -1
                    if index > -1 {
                        meal = mealsAvailable[index]
                        print("now selected \(meal.name)")
                    }
                } else if editChoice == .write {
                    meal = Meal(id: -1, name: customMealName, type: mealType)
                } else if editChoice == .leftOver {
                    meal = Meal.LeftOVer
                }
                dayPlan.objectWillChange.send()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "Done")
            })
        }.padding(30)
    }
    
    enum EditMealChoice {
        case choose
        case write
        case leftOver
    }
}
