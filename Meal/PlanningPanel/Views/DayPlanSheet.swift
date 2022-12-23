//
//  DayPlanMealEditSheet.swift
//  Meal
//
//  Created by Loic D on 09/12/2022.
//

import SwiftUI

struct DayPlanNewMealSheet: View {
    @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
    @State var dayPlan: DayPlan
    let time: TimeOfTheDay
    @State var newMeal: Meal = .EmptyMEal
    @State var mealType: MealType = .meat

    var body: some View {
        DayPlanSheet(sheetTitle: "mealPlan_new_title", sheetIntro: "mealPlan_new_subtitle", dayPlan: dayPlan, time: time, meal: $newMeal, mealType: .meat, showBin: false)
            .onChange(of: newMeal) { _ in
                planningPanelVM.addMeal(newMeal, day: dayPlan.day, time: time)
            }
    }
}

struct DayPlanMealEditSheet: View {
    @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
    @State var dayPlan: DayPlan
    let time: TimeOfTheDay
    @Binding var meal: Meal
    @State var mealType: MealType = .meat
    @State var mealIndex = -1

    var body: some View {
        DayPlanSheet(sheetTitle: "mealPlan_edit_title", sheetIntro: "mealPlan_edit_subtitle", dayPlan: dayPlan, time: time, meal: $meal, mealType: meal.type, showBin: true)
            .onChange(of: meal) { _ in
                if time == .midday {
                    dayPlan.midday[mealIndex] = meal.new()
                } else if time == .evening {
                    dayPlan.evening[mealIndex] = meal.new()
                }
                dayPlan.objectWillChange.send()
                planningPanelVM.saveWeek()
            }
            .onAppear() {
                if time == .midday {
                    mealIndex = dayPlan.midday.firstIndex(where: {$0.id == meal.id}) ?? -1
                } else if time == .evening {
                    mealIndex = dayPlan.evening.firstIndex(where: {$0.id == meal.id}) ?? -1
                }
            }
    }
}

struct DayPlanSheet: View {
    @EnvironmentObject var planningPanelVM: PlanningPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let sheetTitle: String
    let sheetIntro: String
    @State var dayPlan: DayPlan
    let time: TimeOfTheDay
    @Binding var meal: Meal
    @State var mealType: MealType = .meat
    
    @State var customMealName: String = ""
    @State var selection = 0
    @State var editChoice: EditMealChoice = .choose
    
    let showBin: Bool
    
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
            Text(NSLocalizedString(sheetTitle, comment: sheetTitle))
                .title()
            
            Text(dayPlan.day.name())
            
            HStack {
                Text(NSLocalizedString(sheetIntro, comment: sheetIntro))
                    .font(.title)
                
                Spacer()
                                
                if showBin {
                    Button(action: {
                        planningPanelVM.deleteMeal(meal, dayPlan: dayPlan, time: time)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    })
                }
            }
            
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .choose
                    }
                }, label: {
                    ChoiceButtonLabel(title: "choice_choose")
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .write
                    }
                }, label: {
                    ChoiceButtonLabel(title: "choice_write")
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editChoice = .leftOver
                    }
                }, label: {
                    ChoiceButtonLabel(title: "choice_leftover")
                })
            }
            
            if editChoice != .leftOver {
                HStack {
                    MealTypeSelector(mealType: .meat, selectedMealType: $mealType)
                    MealTypeSelector(mealType: .vegan, selectedMealType: $mealType)
                    MealTypeSelector(mealType: .outside, selectedMealType: $mealType)
                }
            }
            
            if editChoice == .choose {
                Picker("Meals to choose from", selection: $selection) {
                    ForEach(0..<mealsAvailable.count, id: \.self) { mealId in
                        Text(mealsAvailable[mealId].name)
                    }
                }.onChange(of: mealsAvailable) { _ in
                    selection = mealsAvailable.firstIndex(where: {$0.id == meal.id}) ?? 0
                }.onAppear() {
                    customMealName = meal.name
                    selection = mealsAvailable.firstIndex(where: {$0.id == meal.id}) ?? 0
                }
            } else if editChoice == .write {
                Text(NSLocalizedString("choice_write_intro", comment: "choice_write_intro"))
                TextField(NSLocalizedString("choice_write_placeholder", comment: "choice_write_placeholder"), text: $customMealName)
            } else {
                VStack(alignment: .center, spacing: 30) {
                    Spacer()
                    Text(NSLocalizedString("leftover", comment: "leftover"))
                        
                    Image("LeftOver")
                        .resizable()
                        .frame(width: 200, height: 200)
                    Spacer()
                }.frame(maxWidth: .infinity)
            }
            
            Spacer()

            Button(action: {
                if editChoice == .choose {
                    if selection >= 0 && mealsAvailable.count > 0 {
                        let newMeal = mealsAvailable[selection]
                        meal = newMeal
                        print("now selected \(meal.name)")
                    }
                } else if editChoice == .write {
                    meal = Meal(id: -1, name: customMealName, type: mealType)
                } else if editChoice == .leftOver {
                    meal = Meal.LeftOVer.new()
                }
                dayPlan.objectWillChange.send()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "done")
            })
        }.padding(30)
    }
    
    struct ChoiceButtonLabel: View {
        let title: String
        var body: some View {
            Text(NSLocalizedString(title, comment: title))
        }
    }
    
    enum EditMealChoice {
        case choose
        case write
        case leftOver
    }
}
