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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                MealTypeSelectionRow(selectedMealType: $selectedMealType)
            }.padding(15).background(Color("WhiteBackgroundColor").shadow(color: Color("ShadowColor"), radius: 4).mask(Rectangle().padding(.bottom, -20))).zIndex(1)

            ZStack(alignment: .bottomTrailing) {
                MealList(selectedMealType: $selectedMealType)
                
                NewMealButton(showingNewMealSheet: $showingNewMealSheet)
                    .padding(5)
                    .sheet(isPresented: $showingNewMealSheet) {
                        // A FIXER
                        NewMealSheet(mealType: $selectedMealType)
                    }
            }
            
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
}
