//
//  FullScreenRecipe.swift
//  Meal
//
//  Created by Loic D on 13/04/2024.
//

import SwiftUI

struct FullScreenRecipe: View {
    @Environment(\.presentationMode) var presentationMode
    @State var recipe: Recipe
    var mealName: String = ""
    var mealType: MealType = .meat
    @State var currentStep = -1
    let textSize: CGFloat = 22
    
    init(_ recipe: Recipe, meal: Meal) {
        self._recipe = State(initialValue: recipe)
        self.mealName = meal.name
        self.mealType = meal.type
    }
    
    init(_ recipe: Recipe, mealName: String, mealType: MealType) {
        self._recipe = State(initialValue: recipe)
        self.mealName = mealName
        self.mealType = mealType
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(mealName).largeTitle()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ButtonLabel(title: "close", isCompact: true)
                })
            }.padding(.horizontal, 20)
            
            ZStack {
                //MARK: Content
                if UIDevice.isIPhone {
                    ScrollView(.vertical) {
                        VStack {
                            IngredientsView(recipe: recipe, textSize: textSize)
                            
                            StepsView(recipe: recipe, mealType: mealType, textSize: textSize)
                        }
                    }
                } else {
                    GeometryReader { geo in
                        HStack(alignment: .top) {
                            ScrollView(.vertical) {
                                StepsView(recipe: recipe, mealType: mealType, textSize: textSize)
                                    .frame(maxWidth: 2 * geo.size.width / 3)
                            }
                            
                            IngredientsView(recipe: recipe, textSize: textSize)
                        }
                    }
                }
            }.background(Color("BackgroundColor").ignoresSafeArea())
        }.background(
            GeometryReader { geo in
                ZStack {
                    RecipeBackgroundImage(recipe: recipe, mealType: mealType)
                    Color.clear//.blurredBackground()
                }.frame(height: geo.size.height).clipped()
            }.ignoresSafeArea()
        )
    }
    
    struct IngredientsView: View {
        @State var recipe: Recipe
        let textSize: CGFloat
        var body: some View {
            VStackBlock {
                //MARK: Servings
                HStack {
                    Button(action: {
                        if recipe.serving > 1 {
                            recipe.updateServing(recipe.serving - 1)
                        }
                    }, label: {
                        Image(systemName: "minus.square.fill")
                            .font(.system(size: textSize * 1.3))
                    })
                    
                    Text("\(recipe.serving)")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                    Image(systemName: "figure.stand")
                        .font(.system(size: textSize))
                    
                    Button(action: {
                        recipe.updateServing(recipe.serving + 1)
                    }, label: {
                        Image(systemName: "plus.square.fill")
                            .font(.system(size: textSize * 1.3))
                    })
                }.roundedCornerRectangle()
                
                //MARK: Ingredients
                ForEach(recipe.ingredients) { ingredient in
                    HStack(spacing: 0) {
                        Text("- ")
                            .font(.system(size: textSize))
                        Text("\(ingredient.displayedQuantity.clean)")
                            .fontWeight(.bold)
                            .font(.system(size: textSize))
                        Text("\(ingredient.name)")
                            .font(.system(size: textSize))
                        Spacer()
                    }
                }
            }.padding(20)
        }
    }
    
    struct StepsView: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        let recipe: Recipe
        let mealType: MealType
        let textSize: CGFloat
        
        var body: some View {
            VStack(spacing: 40) {
                ForEach(0..<recipe.steps.count, id: \.self) { i in
                    let step = recipe.steps[i]
                    HStack(alignment: .top, spacing: 20) {
                        /*ZStack {
                            Text("\(i + 1)")
                                .font(.system(size: textSize))
                                .fontWeight(.semibold)
                        }.frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(mealType.getColor(userPrefs: userPrefs), lineWidth: 3)
                            )
                         */
                        mealType.getColor(userPrefs: userPrefs)
                            .frame(maxWidth: 3)
                        
                        Text(step.step)
                            .font(.system(size: textSize))
                            //.padding(.top, (40 - textSize) / 2 - 5)
                        
                        Spacer()
                    }
                }
            }.padding(20)
        }
    }
}
