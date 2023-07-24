//
//  ConfigurePanel.swift
//  Meal
//
//  Created by Loic D on 16/12/2022.
//

import SwiftUI

struct ConfigurePanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @EnvironmentObject var userPrefs: VisualUserPrefs
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("options_schedule_title", comment: "options_schedule_title"))) {
                    ForEach(configurePanelVM.schedules, id: \.self) { schedule in
                        NavigationLink(destination: EditMealSchedule(selectedSchedule: schedule)) {
                            Text(schedule.meal.name)
                        }
                    }
                    NavigationLink(destination: NewMealSchedule()) {
                        HStack {
                            Image(systemName: "plus").foregroundColor(.accentColor)
                            Text(NSLocalizedString("options_schedule_new", comment: "options_schedule_new"))
                        }
                    }
                }
                Section(header: Text("Options")) {
                    NavigationLink(destination: CustomizationPanel(userPrefs: userPrefs)) {
                        Text("customization.title".translate())
                    }
                    NavigationLink(destination: CollaborationPanel()) {
                        Text(NSLocalizedString("collaboration.title", comment: "collaboration.title"))
                    }
                    NavigationLink(destination: CalendarPanel()) {
                        Text(NSLocalizedString("options_calendar_title", comment: "options_calendar_title"))
                    }
                    NavigationLink(destination: WhatsNewPanel()) {
                        Text(NSLocalizedString("whatsNew_title", comment: "whatsNew_title"))
                    }
                    NavigationLink(destination: ThanksPanel()) {
                        Text("Thanks")
                    }
                }
            }.navigationTitle(NSLocalizedString("tab_options", comment: "tab_options"))
        }
    }
}

struct ConfigurePanel_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurePanel()
    }
}
