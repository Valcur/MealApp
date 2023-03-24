//
//  MealsListPanel.swift
//  Meal
//
//  Created by Loic D on 06/12/2022.
//

import SwiftUI

struct MealsListPanel: View {
    @State private var showingNewMealSheet = false
    @State private var selectedMealType: MealType = .meat
    var selectedMealIntroString: String {
        if selectedMealType == .meat {
            return "mealList_meat_intro"
        } else if selectedMealType == .vegan {
            return "mealList_vegan_intro"
        } else {
            return "mealList_outside_intro"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(NSLocalizedString("mealList_title", comment: "mealList_title"))
                    .largeTitle(style: .secondary, numberOfLine: 1)
                
                MealTypeSelectionRow(selectedMealType: $selectedMealType)
                
                HStack {
                    MealTypeDesription(text: selectedMealIntroString)
                    
                    Spacer()
                    
                    NewMealButton(showingNewMealSheet: $showingNewMealSheet)
                        .sheet(isPresented: $showingNewMealSheet) {
                            NewMealSheet(mealType: selectedMealType)
                        }
                } 
            }.padding(15).background(Color("WhiteBackgroundColor").shadow(color: Color("ShadowColor"), radius: 4).mask(Rectangle().padding(.bottom, -20))).zIndex(1)

            MealList(selectedMealType: $selectedMealType)
        }.background(Color("BackgroundColor"))
    }
    
    struct NewMealButton: View {
        @Binding var showingNewMealSheet: Bool
        
        var body: some View {
            Button(action: {
                showingNewMealSheet = true
            }, label: {
                ButtonLabel(title: "+", isCompact: true)
            })
        }
    }
    
    struct MealTypeDesription: View {
        let text: String
        
        var body: some View {
            Text(NSLocalizedString(text, comment: text))
                .headLine()
        }
    }
}


struct MealsListPanel_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15, *) {
            MealsListPanel()
                .environmentObject(MealsListPanelViewModel())
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        } else {
            MealsListPanel()
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        }

    }
}
