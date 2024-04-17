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

struct PlayRecipe: View {
    let recipe: Recipe
    let mealName: String
    let mealType: MealType
    @State var showFullscreenRecipe = false
    
    var body: some View {
        Button(action: {
            showFullscreenRecipe = true
        }, label: {
            Image(systemName: "play.fill")
                .font(.system(size: 50))
                .foregroundColor(.black)
        })
        .fullScreenCover(isPresented: $showFullscreenRecipe) {
            FullScreenRecipe(recipe, mealName: mealName, mealType: mealType)
        }.padding(.trailing, 15)
    }
}

struct RecipeServings: View {
    @Binding var recipe: Recipe
    
    var body: some View {
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
}

struct RecipeSheet: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    let mealName: String
    let mealType: MealType
    @State var recipe: Recipe
    @Binding var recipeFinal: Recipe?
    
    var body: some View {
        VStack {
                ZStack {
                    if UIDevice.isIPhone {
                        VStack(alignment: .leading) {
                            Text(mealName)
                                .title()
                                .frame(minHeight: 80)
                            
                            HStack {
                                PlayRecipe(recipe: recipe, mealName: mealName, mealType: mealType)
                                
                                Spacer()
                                
                                RecipeServings(recipe: $recipe)
                            }.frame(minHeight: 80).padding(.horizontal, 20).blurredBackground().padding(.horizontal, -20)
                        }
                    } else {
                        HStack(spacing: 10) {
                            PlayRecipe(recipe: recipe, mealName: mealName, mealType: mealType)
                            
                            Text(mealName)
                                .title()
                            
                            Spacer()
                            
                            RecipeServings(recipe: $recipe)
                        }.frame(minHeight: 80)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(Color.white)
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
        
        @State var showImportIngredientsAlert = false
        @State var userClipboard: String = ""
        
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
                        HStack(alignment: .top, spacing: 2) {
                            Text(ingredient.displayedQuantity)
                                .fontWeight(.bold)
                                .headLine()
                            Text("\(ingredient.name)")
                                .headLine()
                            Spacer()
                            Button(action: {
                                showIngredientAlert = true
                                ingredientAlertIndex = index
                                ingredientTextLine = "\(ingredient.displayedQuantity)\(ingredient.name)"
                            }, label: {
                                Image(systemName: "pencil")
                                    .font(.title2)
                            })
                        }
                    }
                }
                
                if #available(iOS 15.0, *) {
                    HStack {
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
                        
                        Button(action: {
                            showImportIngredientsAlert = true
                            userClipboard = UIPasteboard.general.string ?? ""
                        }, label: {
                            ButtonLabel(title: "All", isCompact: true)
                        })
                        .alert("recipe_ingredient_add_all".translate(), isPresented: $showImportIngredientsAlert)  {
                            Button("add".translate()) {
                                addIngredientsFromClipboard()
                            }
                            Button("cancel".translate(), role: .cancel) {
                                
                            }
                        } message: {
                            Text("\("recipe_clipboard_content".translate())\n\n\(userClipboard)".translate())
                        }
                    }
                }
            }
        }
        
        private func addIngredientsFromClipboard() {
            let ingredients = userClipboard.split(separator: "\n")
            for i in ingredients {
                if i.replacingOccurrences(of: " ", with: "") != "" {
                    let textLine = String(i)
                    recipe.ingredients.append(Ingredient(textLine: textLine, servings: recipe.serving))
                }
            }
        }
    }
    
    struct RecipeStepsView: View {
        @Binding var recipe: Recipe
        @State var showDeleteAlert = false
        @State var showImportStepsAlert = false
        @State var stepToDelete = -1
        @State var userClipboard: String = ""
        
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
                    
                    HStack {
                        Button(action: {
                            recipe.steps.append(RecipeStep(step: ""))
                        }, label: {
                            ButtonLabel(title: "recipe_steps_add", isCompact: true)
                        })
                        
                        Button(action: {
                            showImportStepsAlert = true
                            userClipboard = UIPasteboard.general.string ?? ""
                        }, label: {
                            ButtonLabel(title: "All", isCompact: true)
                        })
                        .alert("recipe_steps_add_all".translate(), isPresented: $showImportStepsAlert)  {
                            Button("add".translate()) {
                                let steps = userClipboard.split(separator: "\n")
                                for s in steps {
                                    if s.replacingOccurrences(of: " ", with: "") != "" {
                                        recipe.steps.append(RecipeStep(step: String(s)))
                                    }
                                }
                            }
                            Button("cancel".translate(), role: .cancel) {
                                
                            }
                        } message: {
                            Text("\("recipe_clipboard_content".translate())\n\n\(userClipboard)".translate())
                        }
                    }
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
                    HStack(spacing: 15) {
                        Button(action: {
                            step.step = UIPasteboard.general.string ?? step.step
                        }, label: {
                            Image(systemName: "doc.on.clipboard")
                                .font(.headline)
                        })
                        ZStack {
                            if #available(iOS 16.0, *) {
                                TextField("recipe_steps_placeholder".translate(), text: $step.step, axis: .vertical)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .fixedSize(horizontal: false, vertical: true)
                                    .scrollDisabled(true)
                                    //.lineLimit(1...100)
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

// NOT CURRENTLY USED
struct RecipeBackgroundImage: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    let recipe: Recipe
    let mealType: MealType
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [mealType.getColor(userPrefs: userPrefs).opacity(0.5), mealType.getColor(userPrefs: userPrefs)]), startPoint: .topTrailing, endPoint: .bottomLeading)
            /*Image(recipe.imageName)
                .resizable()
                .scaledToFill()*/
        }
    }
}
