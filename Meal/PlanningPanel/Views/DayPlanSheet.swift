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
    @State var mealType: MealType = .vegan

    var body: some View {
        DayPlanSheet(sheetTitle: "mealPlan_new_title", sheetIntro: "mealPlan_new_subtitle", dayPlan: dayPlan, time: time, meal: $newMeal, mealType: .vegan, showBin: false)
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
    @State var mealType: MealType = .vegan
    @State var mealIndex = -1

    var body: some View {
        DayPlanSheet(sheetTitle: "mealPlan_edit_title", sheetIntro: "mealPlan_edit_subtitle", dayPlan: dayPlan, time: time, meal: $meal, mealType: meal.type, showBin: true)
            .onChange(of: meal) { _ in
                if time == .midday {
                    dayPlan.midday[mealIndex] = meal.new()
                } else if time == .evening {
                    dayPlan.evening[mealIndex] = meal.new()
                }
                planningPanelVM.mealsVM.mealHasBeenPicked(meal)
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
    @State var mealType: MealType = .vegan
    
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
            HStack {
                Text(NSLocalizedString(sheetTitle, comment: sheetTitle))
                    .title()
                
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
            
            Text(dayPlan.day.name())
            
            Text(NSLocalizedString(sheetIntro, comment: sheetIntro))
                .subTitle()
            
            EditChoicePicker(editChoice: $editChoice)
            
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
                    .subTitle()
                TextField(NSLocalizedString("choice_write_placeholder", comment: "choice_write_placeholder"), text: $customMealName)
            } else {
                VStack(alignment: .center, spacing: 30) {
                    Spacer()
                    Text(NSLocalizedString("leftover", comment: "leftover"))
                        .headLine()
                        
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
                    let mealsThisLunch = time == .midday ? dayPlan.midday : dayPlan.evening
                    
                    var lowestId = 0
                    for meal in mealsThisLunch {
                        if meal.id < lowestId {
                            lowestId = meal.id
                        }
                    }
                    meal = Meal(id: lowestId - 1, name: customMealName, type: mealType)
                } else if editChoice == .leftOver {
                    meal = Meal.LeftOVer.new()
                }
                dayPlan.objectWillChange.send()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "done")
            })
        }.scrollableSheetVStack()
    }
    
    struct EditChoicePicker: View {
        @Binding var editChoice: EditMealChoice
        var selectorOffsetX: CGFloat {
            switch editChoice {
            case .choose:
                return 0
            case .write:
                return 1
            case .leftOver:
                return 2
            }
        }
        
        var body: some View {
            GeometryReader { geo in
                ZStack {
                    Color.accentColor.frame(width: geo.size.width / 3, height: 35).cornerRadius(8).offset(x: selectorOffsetX * geo.size.width / 3 - geo.size.width / 3)
                    HStack {
                        ChoiceButton(choice: .choose, editChoice: $editChoice, title: "choice_choose")
                        
                        ChoiceButton(choice: .write, editChoice: $editChoice, title: "choice_write")
                        
                        ChoiceButton(choice: .leftOver, editChoice: $editChoice, title: "choice_leftover")
                    }
                }
            }.frame(height: 35).padding(3).background(Color("TextColor").opacity(0.08)).cornerRadius(10)
        }
        
        struct ChoiceButton: View {
            let choice: EditMealChoice
            @Binding var editChoice: EditMealChoice
            let title: String
            
            var isSelected: Bool {
                choice == editChoice
            }
            
            var body: some View {
                Button(action: {
                    withAnimation(.spring()) {
                        editChoice = choice
                    }
                }, label: {
                    Text(NSLocalizedString(title, comment: title))
                        .foregroundColor(isSelected ? Color("BackgroundColor") : Color.gray)
                        .subTitle()
                }).frame(maxWidth: .infinity).frame(height: 35)
            }
        }
    }
    
    enum EditMealChoice {
        case choose
        case write
        case leftOver
    }
}
