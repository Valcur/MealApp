//
//  AutoFillSheet.swift
//  Meal
//
//  Created by Loic D on 18/12/2022.
//

import SwiftUI

struct AutoFillSheet: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var meatPercentageThisWeek: Double = 0
    @State private var outsideThisWeek: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(NSLocalizedString("autofill", comment: "autofill"))
                .title()
            
            Text(NSLocalizedString("autofill_intro", comment: "autofill_intro"))
                .subTitle()
            
            Text(NSLocalizedString("autofill_meat-vegan_title", comment: "autofill_meat-vegan_title"))
            
            HStack {
                Slider(value: $meatPercentageThisWeek, in: 0...100)
                Text("\(meatPercentageThisWeek, specifier: "%.0f")%")
                    .foregroundColor(.accentColor)
            }
            
            Text(NSLocalizedString("autofill_outside_title", comment: "autofill_outside_title"))
            
            HStack {
                Slider(value: $outsideThisWeek, in: 0...7)
                Text("\(outsideThisWeek, specifier: "%.0f")")
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Button(action: {
                planningPanelVM.autoFill(meatPercentage: meatPercentageThisWeek, desiredOutside: Int(outsideThisWeek))
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ButtonLabel(title: "autoFill")
            })
        }.padding(30)
    }
}

struct AutoFillSheet_Previews: PreviewProvider {
    static var previews: some View {
        AutoFillSheet()
    }
}
