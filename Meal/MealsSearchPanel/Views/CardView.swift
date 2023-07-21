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
    var recipe: Recipe
    var cardAlpha: Double = 1.0
    @Binding var addRecipe: Bool
    
    @State private var translation: CGSize = .zero
    @State private var motionOffset: Double = 0.0
    @State private var motionScale: Double = 0.0
    @State private var lastCardState: DayState = .empty
    
    @State private var showRecipeInfoSheet = false
    @State private var image: UIImage? = nil
    
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
            ZStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            {
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
                                Text(recipe.name.uppercased())
                                    .font(.system(size: CardViewConsts.labelTextSize))
                                    .kerning(CardViewConsts.labelTextKerning)
                                    .foregroundColor(Color(AppColor.primaryTextColor.rawValue))
                                
                                HStack {
                                    Button(action: {
                                        showRecipeInfoSheet = true
                                    }, label: {
                                        ButtonLabel(title: "Info", isCompact: true)
                                    })
                                    
                                    Spacer()
                                    
                                    HStack {
                                        RecipeInfoListElement(value: "164", title: "Calories / Serving")
                                        RecipeInfoListElement(value: "8%", title: "Daily Value")
                                        RecipeInfoListElement(value: "9", title: "Ingredients")
                                    }
                                }.padding(.horizontal, 5)
                            }
                        }
                        Spacer()
                    }
                }
                
                VStack
                {
                    Spacer()
                    Image(systemName: getIconName(state: self.lastCardState))
                        .font(.system(size: CardViewConsts.iconSize.height, weight: .bold))
                        .foregroundColor(.white)
                        //.frame(width: CardViewConsts.iconSize.width, height: CardViewConsts.iconSize.height)
                        .opacity(self.motionScale)
                        .scaleEffect(CGFloat(self.motionScale))
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width * CardViewConsts.cardRatio)
            .background(Color.white)
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
                        response: CardViewConsts.springResponse,
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
                    }
                    .onEnded
                    {
                        gesture in
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
    static let springBlendDur: Double = 0.3
    
    static let iconSize: CGSize = CGSize(width: 96.0, height: 96.0)
}
