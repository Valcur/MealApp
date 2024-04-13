//
//  CardView.swift
//  Swipeable Cards
//
//  Created by Oleg Frolov on 27.06.2021.
//
// My original concept https://dribbble.com/shots/2313705-Ambivalence-ll-Monday

import SwiftUI

enum DayState
{
    case love
    case poop
    case empty
}

struct CardView: View
{
    @EnvironmentObject var recipesSearchVM: RecipesSearchPanelViewModel
    var recipe: OnlineRecipe
    var cardAlpha: Double = 1.0
    @Binding var addRecipe: Bool
    
    @State private var translation: CGSize = .zero
    @State private var motionOffset: Double = 0.0
    @State private var motionScale: Double = 0.0
    @State private var lastCardState: DayState = .empty
    
    @State private var showRecipeInfoSheet = false
    @State private var image: UIImage? = nil
    @State private var animationSpeed = CardViewConsts.springResponse
    
    private func getIconName(state: DayState) -> String
    {
        switch state
        {
            case .love:     return "plus"
            case .poop:     return "xmark"
            default:        return "Empty"
        }
    }
    
    private func setCardState(offset: CGFloat) -> DayState
    {
        if offset <= CardViewConsts.poopTriggerZone   { return .poop }
        if offset >= CardViewConsts.loveTriggerZone   { return .love }
        return .empty
    }
    
    private func gestureEnded(offset: CGFloat) {
        let cancelMargin: CGFloat = 100
        if offset <= CardViewConsts.poopTriggerZone - cancelMargin {
            print("Remove")
            self.removeShowedCard(translationDirection: -1)
        } else if offset >= CardViewConsts.loveTriggerZone + cancelMargin {
            print("Add")
            self.removeShowedCard(translationDirection: 1)
            addRecipe = true
        } else {
            self.translation = .zero
        }
        self.motionScale = 0.0
    }
    
    private func removeShowedCard(translationDirection: CGFloat) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.translation.width = 500 * translationDirection
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            withAnimation(.easeInOut(duration: 0.3)) {
                recipesSearchVM.removeShowedRecipe()
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.translation = .zero
        })
    }
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            ZStack(alignment: .top) {
                if cardAlpha > 0.85 {
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height - 150)
                        } else {
                            Color("WhiteBackgroundColor")
                                .frame(width: geometry.size.width, height: geometry.size.height - 150)
                        }
                        
                        Spacer()
                        if cardAlpha > 0.91 {
                            VStack {
                                Text(recipe.name)
                                    .font(.system(size: CardViewConsts.labelTextSize))
                                    .fontWeight(.semibold)
                                    //.kerning(CardViewConsts.labelTextKerning)
                                    .foregroundColor(Color("TextColor"))
                                    .lineLimit(2)
                                    .padding(.horizontal, 15)
                                
                                Spacer()
                                
                                HStack {
                                    RecipeInfoListElement(value: recipe.nutrition.calories, title: "Calories / Serving")
                                    RecipeInfoListElement(value: recipe.nutrition.dailyValue, title: "Daily Kcal")
                                    RecipeInfoListElement(value: "\(recipe.ingredients.count)", title: "Ingredients")
                                }.padding(.horizontal, 5)
                            }.padding(.vertical, 15).frame(height: 150, alignment: .center)
                        }
                        Spacer()
                    }
                }
                
                VStack {
                    Spacer()
                    Image(systemName: getIconName(state: self.lastCardState))
                        .font(.system(size: CardViewConsts.iconSize.height, weight: .bold))
                        .foregroundColor(self.lastCardState == .love ? .accentColor : .red)
                        .padding(20)
                        .background(Color("WhiteBackgroundColor"))
                        .cornerRadius(CardViewConsts.iconSize.height)
                        .opacity(self.motionScale)
                        .scaleEffect(CGFloat(self.motionScale))
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                
                if UIDevice.isIPhone && cardAlpha > 0.91 {
                    HStack {
                        Button(action: {
                            showRecipeInfoSheet = true
                        }, label: {
                            ButtonLabel(title: "Info", isCompact: true)
                        })
                        Spacer()
                    }.padding(.horizontal, 10).offset(y: geometry.size.height - 150 - 60)
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.width * CardViewConsts.cardRatio)
            .background(Color("WhiteBackgroundColor"))
            .opacity(cardAlpha)
            .cornerRadius(CardViewConsts.cardCornerRadius)
            .shadow(
                color: Color(AppColor.cardShadow.rawValue),
                radius: CardViewConsts.cardShadowBlur,
                x: 0,
                y: CardViewConsts.cardShadowOffset
            )
            .rotationEffect(
                .degrees(Double(self.translation.width / geometry.size.width * CardViewConsts.cardRotLimit)),
                anchor: .bottom
            )
            .offset(x: self.translation.width, y: self.translation.height)
            .animation(.interactiveSpring(
                        response: animationSpeed,
                        blendDuration: CardViewConsts.springBlendDur)
            )
            .gesture(
                DragGesture()
                    .onChanged
                    {
                        gesture in
                            self.translation = gesture.translation
                            self.motionOffset = Double(gesture.translation.width / geometry.size.width)
                            self.motionScale = Double.remap(
                                from: self.motionOffset,
                                fromMin: CardViewConsts.motionRemapFromMin,
                                fromMax: CardViewConsts.motionRemapFromMax,
                                toMin: CardViewConsts.motionRemapToMin,
                                toMax: CardViewConsts.motionRemapToMax
                            )
                            self.lastCardState = setCardState(offset: gesture.translation.width)
                            self.animationSpeed = CardViewConsts.springResponseFast
                    }
                    .onEnded
                    {
                        gesture in
                            self.animationSpeed = CardViewConsts.springResponse
                            self.gestureEnded(offset: gesture.translation.width)
                    }
            )
            
        }.transition(.opacity)
            .sheet(isPresented: $showRecipeInfoSheet) {
                RecipeInfosSheet(recipe: recipe)
            }
            .onAppear() {
                if image == nil {
                    loadRecipeImage()
                }
            }
    }
    
    private func loadRecipeImage() {
        guard let url = URL(string: recipe.imageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private struct RecipeInfoListElement: View {
        let value: String
        let title: String
        var body: some View {
            VStack {
                Text(value)
                    .font(.title2)
                    .foregroundColor(Color("TextColor"))
                Text(title.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }.padding(.horizontal, 5)
        }
    }
}

private struct CardViewConsts
{
    static let cardRotLimit: CGFloat = 20.0
    static let poopTriggerZone: CGFloat = -0.1
    static let loveTriggerZone: CGFloat = 0.1
    
    static let cardRatio: CGFloat = 1.333
    static let cardCornerRadius: CGFloat = 24.0
    static let cardShadowOffset: CGFloat = 16.0
    static let cardShadowBlur: CGFloat = 16.0
    
    static let labelTextSize: CGFloat = 24.0
    static let labelTextKerning: CGFloat = 6.0
    
    static let motionRemapFromMin: Double = 0.0
    static let motionRemapFromMax: Double = 0.25
    static let motionRemapToMin: Double = 0.0
    static let motionRemapToMax: Double = 1.0
    
    static let springResponse: Double = 0.5
    static let springResponseFast: Double = 0.1
    static let springBlendDur: Double = 0.3
    
    static let iconSize: CGSize = CGSize(width: 76.0, height: 76.0)
}
