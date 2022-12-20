//
//  CalendarPanel.swift
//  Meal
//
//  Created by Loic D on 20/12/2022.
//

import SwiftUI

struct CalendarPanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text("Hello, World!")
            
            Button(action: {
                configurePanelVM.calendarController.addWeekToCalendar(weekPlan: configurePanelVM.planningPanelVM!.weekPlan)
            }, label: {
                ButtonLabel(title: "Add to calendar")
            })
        }.padding(20)
    }
}
