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
        VStack(alignment: .leading, spacing: 20) {
            Text("Recipe Info")
                .title()
            
            VStack(alignment: .leading, spacing: stackSpacing) {
                Text("Preparation")
                    .subTitle()
                
                Link(destination: URL(string: recipe.preparation)!) {
                    ButtonLabel(title: "Instructions", isCompact: true)
                }
            }
            
            VStack(alignment: .leading, spacing: stackSpacing) {
                Text("Ingredients for \(recipe.nutrition.servings)")
                    .subTitle()
                
                ForEach(0..<recipe.ingredients.count, id: \.self) { i in
                    Text(recipe.ingredients[i])
                        .headLine()
                }
            }
            
            HStack {
                Spacer()
            }
            
            Spacer()
        }.scrollableSheetVStack()
    }
}
