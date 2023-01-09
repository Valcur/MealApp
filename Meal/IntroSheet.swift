//
//  IntroSheet.swift
//  Meal
//
//  Created by Loic D on 06/01/2023.
//

import SwiftUI

struct IntroSheet: View {
    
    @Environment(\.presentationMode) var presentationMode
    let introPannels: [AnyView]
    @State var selectedPannelId = 0
    var isLastPannelSelected: Bool {
        selectedPannelId >= introPannels.count - 1
    }
    
    init() {
        let welcomePannel = IntroPannel() {
            Text(NSLocalizedString("intro_welcome_title", comment: "intro_welcome_title"))
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
            
            Text(NSLocalizedString("intro_welcome_intro", comment: "intro_welcome_intro"))
                .headLine()
        }
        
        let addMealsPannel = IntroPannel() {
            Text(NSLocalizedString("intro_addMeal_title", comment: "intro_addMeal_title"))
                .title()
                .padding(.bottom, 20)
            
            Text(NSLocalizedString("intro_addMeal_intro", comment: "intro_addMeal_intro"))
                .headLine()
            
            HStack {
                Text(NSLocalizedString("intro_addMeal_add", comment: "intro_addMeal_add"))
                    .headLine()
                    .frame(height: 80)
                
                Spacer()
                
                ButtonLabel(title: "+", isCompact: true)
            }

            Text(NSLocalizedString("intro_addMeal_category", comment: "intro_addMeal_category"))
                .headLine()
            
            HStack {
                Text(NSLocalizedString("intro_addMeal_meat", comment: "intro_addMeal_meat"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 50)
                Spacer()
                Image("Meat")
                    .resizable()
                    .frame(width: 50, height: 50)
            }.roundedCornerRectangle(color: MealType.meat.getColor())
            
            HStack {
                Text(NSLocalizedString("intro_addMeal_vegan", comment: "intro_addMeal_vegan"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 50)
                Spacer()
                Image("Vegan")
                    .resizable()
                    .frame(width: 50, height: 50)
            }.roundedCornerRectangle(color: MealType.vegan.getColor())
            
            HStack {
                Text(NSLocalizedString("intro_addMeal_outside", comment: "intro_addMeal_outside"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 50)
                Spacer()
                Image("Outside")
                    .resizable()
                    .frame(width: 50, height: 50)
            }.roundedCornerRectangle(color: MealType.outside.getColor())
        }
        
        let yourWeekPannel = IntroPannel() {
            Text(NSLocalizedString("intro_organize_title", comment: "intro_organize_title"))
                .title()
                .padding(.bottom, 20)
            
            Text(NSLocalizedString("intro_organize_intro", comment: "intro_organize_intro"))
                .headLine()
            
            HStack {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 10)
                
                Text(NSLocalizedString("intro_organize_+", comment: "intro_organize_+"))
                    .headLine()
            }
            
            HStack {
                Image(systemName: "questionmark.square")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 10)
                
                Text(NSLocalizedString("intro_organize_?", comment: "intro_organize_?"))
                    .headLine()
            }
            
            Text(NSLocalizedString("intro_organize_hold", comment: "intro_organize_hold"))
                .headLine()
            
            HStack {
                Text(NSLocalizedString("intro_organize_auto", comment: "intro_organize_auto"))
                    .headLine()
                    .frame(height: 80)
                
                Spacer()
                
                ButtonLabel(title: "autofill", isCompact: true)
            }
        }
        
        let finalPannel = IntroPannel() {
            Text(NSLocalizedString("intro_end_title", comment: "intro_end_title"))
                .title()
                .padding(.bottom, 20)
            
            Text(NSLocalizedString("intro_end_calendar", comment: "intro_end_calendar"))
                .headLine()
            
            Text(NSLocalizedString("intro_end_schedule", comment: "intro_end_schedule"))
                .headLine()
        }
        
        introPannels = [AnyView(welcomePannel), AnyView(addMealsPannel), AnyView(yourWeekPannel), AnyView(finalPannel)]
    }
    
    var body: some View {
            VStack{
                GeometryReader { geo in
                    HStack(spacing: 20) {
                        ForEach(0..<introPannels.count, id: \.self) { i in
                            introPannels[i].frame(width: geo.size.width).offset(x: -CGFloat(selectedPannelId) * (geo.size.width + 20))
                        }
                    }
                }

                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        if !isLastPannelSelected {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedPannelId += 1
                            }
                        }
                        else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text(NSLocalizedString(isLastPannelSelected ? "intro_start" : "intro_continue", comment: "Continue"))
                            .foregroundColor(.white)
                            .title()
                            .padding(.vertical, 20).padding(.horizontal, 40)
                    })
                    Spacer()//.frame(minHeight: 150)
                }.background(
                    GeometryReader { geo in
                        IntroArc()
                            .frame(width: geo.size.width + 50, height: 600)
                            .foregroundColor(Color.accentColor)
                            .offset(x: -20, y: -40)
                    }
                )
            }.scrollableSheetVStack()
    }
    
    struct IntroPannel<Content>: View where Content: View {
        var content: () -> Content
        
        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20, content: content).frame(maxWidth: .infinity).transition(.slide)
        }
    }
    
    struct IntroArc: Shape {
        let coeff: CGFloat = 1.3
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 10 * coeff))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: 10 * coeff),
                control: CGPoint(x: rect.midX / 2, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: 10 * coeff),
                control: CGPoint(x: rect.midX + rect.midX / 2, y: 20 * coeff))
            path.addLines([CGPoint(x: rect.maxX, y: 10 * coeff),
                           CGPoint(x: rect.maxX, y: rect.maxY),
                           CGPoint(x: 0, y: rect.maxY),
                           CGPoint(x: 0, y: 10 * coeff)
                          ])
            path.closeSubpath()

            return path
        }
    }
}
