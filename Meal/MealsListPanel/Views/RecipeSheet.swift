//
//  RecipeSheet.swift
//  Meal
//
//  Created by Loic D on 09/04/2024.
//

import SwiftUI

struct RecipeSheetWrapper: View {
    let mealName: String
    let mealType: MealType
    @Binding var recipe: Recipe?
    @State var recipeTmp: Recipe?
    
    var body: some View {
        ZStack {
            if let r = recipeTmp {
                RecipeSheet(mealName: mealName, mealType: mealType, recipe: r, recipeFinal: $recipe)
            }
        }.onAppear() {
            if recipe == nil {
                recipeTmp = Recipe()
            } else {
                recipeTmp = recipe
            }
        }
    }
}

struct RecipeSheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    let mealName: String
    let mealType: MealType
    @State var recipe: Recipe
    @Binding var recipeFinal: Recipe?
    @State var showFullscreenRecipe = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showFullscreenRecipe = true
                    }, label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                    })
                    .fullScreenCover(isPresented: $showFullscreenRecipe) {
                        FullScreenRecipe(recipe, mealName: mealName, mealType: mealType)
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Text(mealName)
                        .title()
                    
                    Spacer()
                        
                    HStack {
                        Button(action: {
                            if recipe.serving > 1 {
                                recipe.updateServing(recipe.serving - 1)
                            }
                        }, label: {
                            Image(systemName: "minus.square.fill")
                                .font(.title)
                        })
                        Text("\(recipe.serving)")
                            .title()
                        Image(systemName: "figure.stand")
                            .font(.title2)
                        Button(action: {
                            recipe.updateServing(recipe.serving + 1)
                        }, label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title)
                        })
                    }
                }
                .padding(.horizontal, 20)
                .frame(minHeight: 80)
                .frame(maxWidth: .infinity)
                .blurredBackground()
            }
            .frame(height: 350)
            .background(RecipeBackgroundImage(recipe: recipe, mealType: mealType).frame(height: 350).clipped())
            .padding(.horizontal, -20)
            .padding(.top, -20)
            
            
            VStack(alignment: .leading, spacing: 20) {
                IngredientsView(recipe: $recipe)
                
                RecipeStepsView(recipe: $recipe)
                
                Spacer().frame(minHeight: 500)
            }.padding(.top, 20)
        }.scrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                recipeFinal = recipe
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "done")
            })
        )).background(Color("BackgroundColor").ignoresSafeArea())
    }
    
    struct IngredientsView: View {
        @Binding var recipe: Recipe
        
        @State var showIngredientAlert = false
        @State var ingredientTextLine: String = ""
        @State var ingredientAlertIndex: Int = -1
        
        var isEditingIngredient: Bool {
            ingredientAlertIndex != -1
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("ingredients".translate())
                        .subTitle()
                    Spacer()
                }

                ForEach(Array(recipe.ingredients.enumerated()), id: \.element) { index, ingredient in
                    VStackBlock {
                        HStack {
                            Text("\(ingredient.displayedQuantity.clean)")
                                .fontWeight(.bold)
                                .headLine()
                            Text("\(ingredient.name)")
                                .headLine()
                            Spacer()
                            Button(action: {
                                showIngredientAlert = true
                                ingredientAlertIndex = index
                                ingredientTextLine = "\(ingredient.displayedQuantity.clean)\(ingredient.name)"
                            }, label: {
                                Image(systemName: "pencil")
                                    .font(.title2)
                            })
                        }
                    }
                }
                
                if #available(iOS 15.0, *) {
                    Button(action: {
                        showIngredientAlert = true
                        ingredientAlertIndex = -1
                        ingredientTextLine = ""
                    }, label: {
                        ButtonLabel(title: "recipe_ingredient_add", isCompact: true)
                    })
                    .alert(isEditingIngredient ? "recipe_ingredient_edit".translate() : "recipe_ingredient_add".translate(), isPresented: $showIngredientAlert) {
                            TextField("", text: $ingredientTextLine)
                            Button("done".translate()) {
                                if isEditingIngredient {
                                    recipe.ingredients[ingredientAlertIndex] = Ingredient(textLine: ingredientTextLine, servings: recipe.serving)
                                } else {
                                    recipe.ingredients.append(Ingredient(textLine: ingredientTextLine, servings: recipe.serving))
                                }
                            }
                            if isEditingIngredient {
                                Button("delete".translate(), role: .destructive) {
                                    if ingredientAlertIndex >= 0 && ingredientAlertIndex < recipe.ingredients.count {
                                        recipe.ingredients.remove(at: ingredientAlertIndex)
                                    }
                                }
                            }
                            Button("cancel".translate(), role: .cancel) {
                                
                            }
                        } message: {
                            Text("recipe_ingredient_add_content")
                        }
                }
            }
        }
    }
    
    struct RecipeStepsView: View {
        @Binding var recipe: Recipe
        @State var showDeleteAlert = false
        @State var stepToDelete = -1
        
        var body: some View {
            if #available(iOS 16.0, *) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("recipe_steps".translate())
                            .subTitle()
                        Spacer()
                    }
                    
                    ForEach(0..<recipe.steps.count, id: \.self) { i in
                        RecipeStepView(step: $recipe.steps[i], recipe: $recipe, showDeleteAlert: $showDeleteAlert, stepToDelete: $stepToDelete, stepId: i)
                    }
                    
                    Button(action: {
                        recipe.steps.append(RecipeStep(step: ""))
                    }, label: {
                        ButtonLabel(title: "recipe_steps_add", isCompact: true)
                    })
                }
                .alert("recipe_steps_delete".translate(), isPresented: $showDeleteAlert)  {
                    Button("delete".translate(), role: .destructive) {
                        if stepToDelete >= 0 && stepToDelete < recipe.steps.count {
                            recipe.steps.remove(at: stepToDelete)
                        }
                    }
                    Button("cancel".translate(), role: .cancel) {
                        
                    }
                } message: {
                    Text("recipe_steps_delete_content".translate())
                }
            }
        }
        
        struct RecipeStepView: View {
            @Binding var step: RecipeStep
            @Binding var recipe: Recipe
            @Binding var showDeleteAlert: Bool
            @Binding var stepToDelete: Int
            let stepId: Int
            
            var body: some View {
                VStackBlock {
                    HStack {
                        ZStack {
                            if #available(iOS 16.0, *) {
                                TextField("recipe_steps_placeholder".translate(), text: $step.step, axis: .vertical)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .lineLimit(2...100)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        Spacer()
                        Button(action: {
                            showDeleteAlert = true
                            stepToDelete = stepId
                        }, label: {
                            Image(systemName: "trash")
                                .font(.headline)
                        })
                    }
                }
            }
        }
    }
}

struct FullScreenRecipe: View {
    @Environment(\.presentationMode) var presentationMode
    @State var recipe: Recipe = Recipe()
    var mealName: String = ""
    var mealType: MealType = .meat
    @State var currentStep = -1
    let textSize: CGFloat = 40
    
    init(_ recipe: Recipe, meal: Meal) {
        self.recipe = recipe
        self.mealName = meal.name
        self.mealType = meal.type
    }
    
    init(_ recipe: Recipe, mealName: String, mealType: MealType) {
        self.recipe = recipe
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
            
            VStack {
                
                //MARK: Content
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 30) {
                        Spacer().frame(maxHeight: 100)
                        
                        if currentStep == -1 {
                            HStack(spacing: 40) {
                                HStack {
                                    Button(action: {
                                        if recipe.serving > 1 {
                                            recipe.updateServing(recipe.serving - 1)
                                        }
                                    }, label: {
                                        Image(systemName: "minus.square.fill")
                                            .font(.system(size: textSize))
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
                                            .font(.system(size: textSize))
                                    })
                                }
                                
                                Spacer()
                            }
                            
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
                            
                        } else {
                            Text(recipe.steps[currentStep].step)
                                .font(.system(size: textSize))
                                .frame(maxWidth: .infinity)
                        }
                        
                        Spacer()
                    }
                }
                
                //MARK:  Navigation
                HStack {
                    Button(action: {
                        if currentStep >= 0 {
                            currentStep -= 1
                        }
                    }, label: {
                        ZStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 80))
                        }.frame(maxWidth: .infinity)
                    }).opacity(currentStep >= 0 ? 1 : 0)
                    
                    Text(currentStep == -1 ? "ingredients".translate() : "\("recipe_step".translate()) \(currentStep + 1)")
                        .title()
                    
                    Button(action: {
                        if currentStep < recipe.steps.count - 1 {
                            currentStep += 1
                        }
                    }, label: {
                        ZStack {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 80))
                        }.frame(maxWidth: .infinity)
                    }).opacity(currentStep < recipe.steps.count - 1 ? 1 : 0)
                }.frame(height: 100)
            }.padding(20).background(Color.white)
        }.background(
            GeometryReader { geo in
                ZStack {
                    RecipeBackgroundImage(recipe: recipe, mealType: mealType)
                    Color.clear.blurredBackground()
                }.frame(height: geo.size.height).clipped()
            }.ignoresSafeArea()
        )
    }
}

struct RecipeBackgroundImage: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    let recipe: Recipe
    let mealType: MealType
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [mealType.getColor(userPrefs: userPrefs).opacity(0.5), mealType.getColor(userPrefs: userPrefs)]), startPoint: .topTrailing, endPoint: .bottomLeading)
            Image(recipe.imageName)
                .resizable()
                .scaledToFill()
        }
    }
}
