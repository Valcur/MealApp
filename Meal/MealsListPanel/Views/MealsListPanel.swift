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
    
    var body: some View {
        ZStack {
            NewMealButton(showingNewMealSheet: $showingNewMealSheet)
                .position(x: 400, y: 30)
                .sheet(isPresented: $showingNewMealSheet) {
                    NewMealSheet(mealType: selectedMealType)
                }
            
            VStack(alignment: .leading) {
                Text("Your meals")
                    .font(.largeTitle)
                
                Text("Add/Edit your meals")
                
                MealTypeSelectionRow(selectedMealType: $selectedMealType)
                Divider()
                MealList(selectedMealType: $selectedMealType)
            }.padding(.horizontal, 40)
        }
    }
    
    struct NewMealButton: View {
        @Binding var showingNewMealSheet: Bool
        
        var body: some View {
            Button(action: {
                showingNewMealSheet = true
            }, label: {
                ZStack {
                    Color.green
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }).frame(width: 50, height: 50)
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
