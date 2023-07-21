//
//  RecipeInfoSheet.swift
//  Meal
//
//  Created by Loic D on 20/07/2023.
//

import SwiftUI

struct RecipeInfosSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let recipe: Recipe
    private let stackSpacing: CGFloat = 15
    var body: some View {
        VStack {
            VStack(spacing: stackSpacing) {
                Text("Preparation")
                    .title()
                
                Button(action: {
                    
                }, label: {
                    ButtonLabel(title: "Instructions", isCompact: true)
                })
            }
            
            VStack(spacing: stackSpacing) {
                Text("Ingredients for \(recipe.nutrition.servings)")
                    .title()
                
                ForEach(0..<recipe.ingredients.count, id: \.self) { i in
                    Text(recipe.ingredients[i])
                        .headLine()
                }
            }
            
            Spacer()
        }.scrollableSheetVStack()
    }
}
