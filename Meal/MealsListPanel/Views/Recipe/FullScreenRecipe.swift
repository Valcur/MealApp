//
//  FullScreenRecipe.swift
//  Meal
//
//  Created by Loic D on 13/04/2024.
//

import SwiftUI

struct FullScreenRecipe: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @State var recipe: Recipe
    var mealName: String = ""
    var mealType: MealType = .meat
    @State var currentStep = -1
    let textSize: CGFloat = UIDevice.isIPhone ? 19 : 22
    
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
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            if recipe.ingredients.count > 0 {
                                IngredientsView(recipe: recipe, textSize: textSize, mealType: mealType)
                            }
                            
                            StepsView(recipe: recipe, mealType: mealType, textSize: textSize)
                        }
                    }
                } else {
                    GeometryReader { geo in
                        HStack(alignment: .top) {
                            ScrollView(.vertical, showsIndicators: false) {
                                StepsView(recipe: recipe, mealType: mealType, textSize: textSize)
                                    .frame(minWidth: 1.75 * geo.size.width / 3)
                            }
                            
                            if recipe.ingredients.count > 0 {
                                ScrollView(.vertical, showsIndicators: false) {
                                    IngredientsView(recipe: recipe, textSize: textSize, mealType: mealType)
                                }
                            }
                        }
                    }
                }
            }.background(mealType.getColor(userPrefs: userPrefs).opacity(0.0).ignoresSafeArea())
        }.background(
            GeometryReader { geo in
                ZStack {
                    //RecipeBackgroundImage(recipe: recipe, mealType: mealType)
                    Color("WhiteBackgroundColor")
                    //Color.clear.blurredBackground()
                }.frame(height: geo.size.height).clipped()
            }.ignoresSafeArea()
        )
    }
    
    struct IngredientsView: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        @State var recipe: Recipe
        let textSize: CGFloat
        let mealType: MealType
        var body: some View {
            VStack(spacing: 20) {
                //MARK: Servings
                HStack {
                    
                    Text("Ingredients")
                        .font(.system(size: textSize))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        if recipe.serving > 1 {
                            recipe.updateServing(recipe.serving - 1)
                        }
                    }, label: {
                        Image(systemName: "minus.square.fill")
                            .font(.system(size: textSize * 1.5))
                            .foregroundColor(mealType.getColor(userPrefs: userPrefs))
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
                            .font(.system(size: textSize * 1.5))
                            .foregroundColor(mealType.getColor(userPrefs: userPrefs))
                    })
                }
                
                Color("TextColor").frame(height: 1).padding(.horizontal, 10)
                
                //MARK: Ingredients
                ForEach(recipe.ingredients) { ingredient in
                    HStack(alignment: .top, spacing: 0) {
                        Text(ingredient.displayedQuantity)
                            .fontWeight(.bold)
                            .font(.system(size: textSize))
                        Text("\(ingredient.name)")
                            .font(.system(size: textSize))
                        Spacer()
                    }
                }
            }.roundedCornerRectangle(color: mealType.getColor(userPrefs: userPrefs).opacity(0.15)).padding(20)
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
                        
                        Text(step.step)
                            .font(.system(size: textSize))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }.border(width: 3, edges: [.leading], color: mealType.getColor(userPrefs: userPrefs))
                }
            }.padding(20)
        }
    }
}
