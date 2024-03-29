//
//  IntroSheet.swift
//  Meal
//
//  Created by Loic D on 06/01/2023.
//

import SwiftUI

struct IntroSheet: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @Environment(\.presentationMode) var presentationMode
    let introPannels: [AnyView]
    @State var selectedPannelId = 0
    var isLastPannelSelected: Bool {
        selectedPannelId >= introPannels.count - 1
    }
    
    init() {
        let welcomePannel = IntroPannel() {
            VStack(alignment: .leading, spacing: 30) {
                Text(NSLocalizedString("intro_welcome_title", comment: "intro_welcome_title"))
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 100)
                
                Text(NSLocalizedString("intro_welcome_intro", comment: "intro_welcome_intro"))
                    .headLine()
            }.padding(.bottom, 100).scrollableSheetVStack()
        }
        
        let addMealsPannel = IntroPannel() {
            VStack(alignment: .leading, spacing: 30) {
                Text(NSLocalizedString("intro_addMeal_title", comment: "intro_addMeal_title"))
                    .title()
                    .padding(.bottom, 20)
                /*
                Text(NSLocalizedString("intro_addMeal_intro", comment: "intro_addMeal_intro"))
                    .headLine()
                
                HStack {
                    Text(NSLocalizedString("intro_addMeal_add", comment: "intro_addMeal_add"))
                        .headLine()
                        .frame(height: 80)
                    
                    Spacer()
                    
                    ButtonLabel(title: "+", isCompact: true)
                }*/
                
                Text(NSLocalizedString("intro_addMeal_category", comment: "intro_addMeal_category"))
                    .headLine()
                
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("MeatColor").opacity(0.8), Color("MeatColor")]), startPoint: .top, endPoint: .bottom)
                    HStack {
                        Text(NSLocalizedString("intro_addMeal_meat", comment: "intro_addMeal_meat"))
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(height: 65)
                        Spacer()
                        Image("Meat")
                            .resizable()
                            .frame(width: 130, height: 130).offset(y: 15)
                    }.frame(height: 65).padding(15)
                }.roundedCornerRectangle(padding: 0)
                
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("VeganColor").opacity(0.8), Color("VeganColor")]), startPoint: .top, endPoint: .bottom)
                    HStack {
                        Text(NSLocalizedString("intro_addMeal_vegan", comment: "intro_addMeal_vegan"))
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(height: 65)
                        Spacer()
                        Image("Vegan")
                            .resizable()
                            .frame(width: 130, height: 130).offset(y: 15)
                    }.frame(height: 65).padding(15)
                }.roundedCornerRectangle(padding: 0)
                
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("OtherColor").opacity(0.8), Color("OtherColor")]), startPoint: .top, endPoint: .bottom)
                    HStack {
                        Text(NSLocalizedString("intro_addMeal_other", comment: "intro_addMeal_other"))
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(height: 65)
                        Spacer()
                        Image("ImageChoice 2")
                            .resizable()
                            .frame(width: 130, height: 130).offset(y: 15)
                    }.frame(height: 65).padding(15)
                }.roundedCornerRectangle(padding: 0)
                
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("OutsideColor").opacity(0.8), Color("OutsideColor")]), startPoint: .top, endPoint: .bottom)
                    HStack {
                        Text(NSLocalizedString("intro_addMeal_outside", comment: "intro_addMeal_outside"))
                            .foregroundColor(.black)
                            .font(.headline)
                            .frame(height: 65)
                            .minimumScaleFactor(0.01)
                        Spacer()
                        Image("Outside")
                            .resizable()
                            .frame(width: 130, height: 130).offset(y: 15)
                    }.frame(height: 65).padding(15)
                }.roundedCornerRectangle(padding: 0)
            }.padding(.bottom, 100).scrollableSheetVStack()
        }
        
        let yourWeekPannel = IntroPannel() {
            VStack(alignment: .leading, spacing: 30) {
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
            }.padding(.bottom, 100).scrollableSheetVStack()
        }
        
        let finalPannel = IntroPannel() {
            VStack(alignment: .leading, spacing: 30) {
                Text(NSLocalizedString("intro_end_title", comment: "intro_end_title"))
                    .title()
                    .padding(.bottom, 20)
                
                Text(NSLocalizedString("intro_end_calendar", comment: "intro_end_calendar"))
                    .headLine()
                
                Text(NSLocalizedString("intro_end_schedule", comment: "intro_end_schedule"))
                    .headLine()
                
                Text("intro_end_collaboration".translate())
                    .headLine()
            }.padding(.bottom, 100).scrollableSheetVStack()
        }
        
        introPannels = [AnyView(welcomePannel), AnyView(addMealsPannel), AnyView(yourWeekPannel), AnyView(finalPannel)]
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 20) {
                    ForEach(0..<introPannels.count, id: \.self) { i in
                        VStack {
                            introPannels[i].frame(width: geo.size.width).offset(x: (-CGFloat(selectedPannelId) + CGFloat(1.5)) * (geo.size.width + 20))
                            Spacer()
                        }
                    }
                }.frame(minHeight: geo.size.height)
                
                VStack {
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
                        Spacer()
                    }.background(
                        IntroArc()
                            .frame(width: geo.size.width + 50, height: 600)
                            .foregroundColor(userPrefs.accentColor)
                            .offset(x: -20, y: 250)
                    )
                }
            }.frame(width: geo.size.width)
        }
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
        let coeff: CGFloat = 1.5
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 10 * coeff))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: 10 * coeff),
                control: CGPoint(x: rect.midX / 2, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: 10 * coeff),
                control: CGPoint(x: rect.midX + rect.midX / 2, y: 15 * coeff))
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

struct NewUserInfoBuble: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    let text: String
    let xOffset: CGFloat
    let yOffset: CGFloat
    let height: CGFloat
    let arrowSide: ArrowSide
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            ZStack(alignment: .bottom) {
                Color.clear
                VStack(alignment: arrowSide.alignment(), spacing: 10) {
                    Text(text.translate()).foregroundColor(Color("BackgroundColor")).headLine()
                    Image(systemName: arrowSide.imageSystemName()).font(.title).foregroundColor(Color("BackgroundColor"))
                }.roundedCornerRectangle(color: userPrefs.accentColor).frame(width: 200, height: height).offset(x: xOffset, y: yOffset)
            }
        }
    }
    
    enum ArrowSide {
        case center
        case right
        
        func alignment() -> SwiftUI.HorizontalAlignment {
            switch self {
            case .center:
                return .center
            case .right:
                return .trailing
            }
        }
        
        func imageSystemName() -> String {
            switch self {
            case .center:
                return "arrow.down"
            case .right:
                return "arrow.down.forward"
            }
        }
    }
}
