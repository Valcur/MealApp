//
//  PlanningPannel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import SwiftUI

struct PlanningPannel: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @State private var showingAutoFillSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    planningPanelVM.switchToThisWeek()
                }, label: {
                    Text(WichWeekIsIt.thisWeek.name())
                        .largeTitle(style: planningPanelVM.selectedWeek == .thisWeek ? .primary : .secondary)
                })
                Spacer()
                Button(action: {
                    planningPanelVM.switchToNextWeek()
                }, label: {
                    Text(WichWeekIsIt.nextWeek.name())
                        .largeTitle(style: planningPanelVM.selectedWeek == .nextWeek ? .primary : .secondary)
                })
                Spacer()
                Spacer()
                Button(action: {
                    showingAutoFillSheet = true
                }, label: {
                    ButtonLabel(title: "autofill", isCompact: true)
                })
                .sheet(isPresented: $showingAutoFillSheet) {
                    AutoFillSheet()
                }
            }.padding(20).background(Color("WhiteBackgroundColor").shadow(color: Color("ShadowColor"), radius: 4)).ignoresSafeArea()
            
            WeekPlanOrganiser()
        }.background(Color("BackgroundColor"))
    }
}

struct PlanningPannel_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15, *) {
            PlanningPannel()
                .environmentObject(PlanningPanelViewModel(mealsVM: MealsListPanelViewModel(), configureVM: ConfigurePanelViewModel()))
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        } else {
            PlanningPannel()
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        }

    }
}
