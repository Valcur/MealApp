//
//  AutoFillSheet.swift
//  Meal
//
//  Created by Loic D on 18/12/2022.
//

import SwiftUI

struct AutoFillSheet: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @Environment(\.presentationMode) var presentationMode
    @State private var meatPercentageThisWeek: Double = 0
    @State private var outsideThisWeek: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(NSLocalizedString("autofill", comment: "autofill"))
                .title()
            
            Text(NSLocalizedString("autofill_intro", comment: "autofill_intro"))
                .subTitle()
            
            Text(String(format: "autofill_meat-vegan_title".translate(), userPrefs.meatTitle, userPrefs.veganTitle))
            
            HStack {
                Text("\(meatPercentageThisWeek, specifier: "%.0f")%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userPrefs.accentColor)
                    .frame(width: 70)
                Slider(value: $meatPercentageThisWeek, in: 0...100, step: 1.0)
            }
            
            Text(NSLocalizedString("autofill_outside_title", comment: "autofill_outside_title"))
            
            HStack {
                Text("\(outsideThisWeek, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userPrefs.accentColor)
                    .frame(width: 70)
                Slider(value: $outsideThisWeek, in: 0...7, step: 1.0)
            }
            
            Spacer()
            
            Button(action: {
                planningPanelVM.autoFill(meatPercentage: meatPercentageThisWeek, desiredOutside: Int(outsideThisWeek))
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "autofill")
            })
        }.scrollableSheetVStack()
    }
}

struct AutoFillSheet_Previews: PreviewProvider {
    static var previews: some View {
        AutoFillSheet()
    }
}
