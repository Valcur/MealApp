//
//  CalendarPanel.swift
//  Meal
//
//  Created by Loic D on 20/12/2022.
//

import SwiftUI
import EventKitUI

struct CalendarPanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @State private var useCalendar = true
    @State private var showCalendarChooser = false
    @State private var middayTime = Date()
    @State private var eveningTime = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text(NSLocalizedString("options_calendar_title", comment: "options_calendar_title"))
                .title()
            
            HStack {
                Text(NSLocalizedString("options_calendar_use", comment: "options_calendar_use"))
                    .headLine()
                Spacer()
                Toggle("Allow the app to add plan to your calendar ?", isOn: $useCalendar)
                    .labelsHidden()
            }
            
            Text(NSLocalizedString("options_calendar_choose_desciption", comment: "options_calendar_choose_desciption"))
                .headLine()
            
            Button(action: {
                showCalendarChooser = true
            }, label: {
                ButtonLabel(title: "options_calendar_choose_buttonLabel")
            })
            .sheet(isPresented: $showCalendarChooser) {
                CalendarChooser(calendars: $configurePanelVM.calendarController.calendars,
                                eventStore: configurePanelVM.calendarController.eventStore)
            }
            
            Text(NSLocalizedString("options_calendar_midday", comment: "options_calendar_midday"))
                .headLine()
            
            DatePicker("Lunch time", selection: $middayTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            
            Text(NSLocalizedString("options_calendar_evening", comment: "options_calendar_evening"))
                .headLine()
            
            DatePicker("Lunch time", selection: $eveningTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
            
            Spacer()
            
            Button(action: {
                var calendarIdentifier = CalendarUsage.defaultCalendarIdentifier
                if configurePanelVM.calendarController.calendars?.count ?? 0 > 0 {
                    calendarIdentifier = configurePanelVM.calendarController.calendars!.first!.calendarIdentifier
                }
                configurePanelVM.saveCalendarUsage(useCalendar: useCalendar, calendarIdentifier: calendarIdentifier, middayDate: middayTime, eveningDate: eveningTime)
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
        }.scrollableSheetVStack()
    }
    
    struct CalendarChooser: UIViewControllerRepresentable {
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
        @Environment(\.presentationMode) var presentationMode
        @Binding var calendars: Set<EKCalendar>?

        let eventStore: EKEventStore

        func makeUIViewController(context: UIViewControllerRepresentableContext<CalendarChooser>) -> UINavigationController {
            let chooser = EKCalendarChooser(selectionStyle: .multiple, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
            chooser.selectedCalendars = calendars ?? []
            chooser.delegate = context.coordinator
            chooser.showsDoneButton = true
            chooser.showsCancelButton = true
            return UINavigationController(rootViewController: chooser)
        }

        func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<CalendarChooser>) {
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, EKCalendarChooserDelegate {
            let parent: CalendarChooser

            init(_ parent: CalendarChooser) {
                self.parent = parent
            }

            func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
                parent.calendars = calendarChooser.selectedCalendars
                parent.presentationMode.wrappedValue.dismiss()
            }

            func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

