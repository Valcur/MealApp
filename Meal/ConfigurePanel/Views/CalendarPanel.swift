//
//  CalendarPanel.swift
//  Meal
//
//  Created by Loic D on 20/12/2022.
//

import SwiftUI

struct CalendarPanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @State private var useCalendar = true
    @State private var middayTime = Date()
    @State private var eveningTime = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text(NSLocalizedString("options_calendar_title", comment: "options_calendar_title"))
                .title()
            
            HStack {
                Text(NSLocalizedString("options_calendar_use", comment: "options_calendar_use"))
                    .subTitle()
                Spacer()
                Toggle("Allow the app to add plan to your calendar ?", isOn: $useCalendar)
                    .labelsHidden()
            }
            
            Text(NSLocalizedString("options_calendar_midday", comment: "options_calendar_midday"))
                .subTitle()
            
            DatePicker("Lunch time", selection: $middayTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            
            Text(NSLocalizedString("options_calendar_evening", comment: "options_calendar_evening"))
                .subTitle()
            
            DatePicker("Lunch time", selection: $eveningTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            
            Spacer()
            
            Button(action: {
                configurePanelVM.saveCalendarUsage(useCalendar: useCalendar, middayDate: middayTime, eveningDate: eveningTime)
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
            .onAppear() {
                let calendar = Calendar.current
                let calendarUsage = configurePanelVM.loadCalendarUsage()
                useCalendar = calendarUsage.useCalendar
                middayTime = calendar.date(bySettingHour: calendarUsage.middayHour.hour, minute: calendarUsage.middayHour.minutes, second: 0, of: middayTime) ?? Date()
                eveningTime = calendar.date(bySettingHour: calendarUsage.eveningHour.hour, minute: calendarUsage.eveningHour.minutes, second: 0, of: eveningTime) ?? Date()
            }
        }.padding(20)
    }
}
