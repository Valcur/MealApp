//
//  PlanningPannel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import SwiftUI

struct PlanningPannel: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    
    var body: some View {
        WeekPlanOrganiser()
    }
}

struct PlanningPannel_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15, *) {
            PlanningPannel()
                .environmentObject(PlanningPanelViewModel(mealsVM: MealsListPanelViewModel()))
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        } else {
            PlanningPannel()
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        }

    }
}
