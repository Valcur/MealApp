//
//  RecipesSearchPanel.swift
//  Meal
//
//  Created by Loic D on 19/07/2023.
//

import SwiftUI

struct RecipesSearchPanel: View
{
    @EnvironmentObject var recipesSearchVM: RecipesSearchPanelViewModel
    var recipes: [Recipe] {
        Array(recipesSearchVM.recipes.suffix(3))
    }
    
    private let cardOffset: CGFloat = 24
    private let cardRatio: CGFloat = 1.333
    private let cardOffsetMultiplier: CGFloat = 4
    private let cardAlphaStep: Double = 0.1
    
    @State private var showAddRecipeSheet = false
    @State private var recipeToAdd: Recipe = Recipe.empty
    
    private var yCardsOffset: CGFloat
    {
        return -CGFloat(recipes.count) * cardOffset / 2
    }
    
    private func calculateCardWidth(geo: GeometryProxy, offset: CGFloat, cardIndex: Int) -> CGFloat
    {
        return geo.size.width - ((offset * 2) * CGFloat(cardIndex))
    }
    
    private func calculateCardYOffset(offset: CGFloat, cardIndex: Int) -> CGFloat
    {
        return offset * CGFloat(cardIndex)
    }
    
    private func calculateItemInvertIndex(arr: [Recipe], item: Recipe) -> Int
    {
        if arr.isEmpty { return 0 }
        return arr.count - 1 - arr.firstIndex(of: item)!
    }
    
    private func calculateCardAlpha(cardIndex: Int) -> Double
    {
        return 1.0 - Double(cardIndex) * cardAlphaStep
    }
    
    var body: some View {
        ZStack {
            Color(AppColor.background.rawValue)
            HStack(spacing: 0) {
                Spacer()
                VStack {
                    TopBarView()
                    GeometryReader {
                        geometry in VStack {
                            Spacer()
                            ZStack {
                                ForEach (recipes, id: \.name) { recipe in
                                    CardView(recipe: recipe, cardAlpha: calculateCardAlpha(cardIndex: calculateItemInvertIndex(arr: recipes, item: recipe)), addRecipe: $showAddRecipeSheet)
                                        .frame(width: calculateCardWidth(geo: geometry, offset: cardOffset, cardIndex: calculateItemInvertIndex(arr: recipes, item: recipe)), height: geometry.size.width * cardRatio)
                                        .offset(x: 0, y: calculateCardYOffset(offset: cardOffset, cardIndex: calculateItemInvertIndex(arr: recipes, item: recipe)) * cardOffsetMultiplier)
                                }
                            }
                            .offset(y: yCardsOffset)
                            Spacer()
                        }
                    }
                    .onChange(of: showAddRecipeSheet, perform: { _ in
                        if showAddRecipeSheet, let r = recipes.last {
                            recipeToAdd = r
                        }
                    })
                }
                .frame(maxWidth: 400)
                .padding(cardOffset)
                .zIndex(100)
                
                Spacer()
                
                if UIDevice.isIPad, let showedRecipe = recipesSearchVM.recipes.last {
                    RecipeInfosSheet(recipe: showedRecipe).frame(maxWidth: 400).background(Color("WhiteBackgroundColor")).shadowed()
                }
            }
        }.ignoresSafeArea(.container)
        .sheet(isPresented: $showAddRecipeSheet) {
            AddRecipeSheet(recipe: recipeToAdd)
        }
    }
}
