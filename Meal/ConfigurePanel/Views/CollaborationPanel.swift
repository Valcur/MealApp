//
//  CollaborationPanel.swift
//  Meal
//
//  Created by Loic D on 12/06/2023.
//

import SwiftUI

struct CollaborationPanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @State var keyUsed = "earreret"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text(NSLocalizedString("Collaboration", comment: "options_calendar_title"))
                .title()
            
            Text(NSLocalizedString("Partagez votre code avec votre famille ou entrez celui d'un autre membre pour travailler sur le même planning (seul la personne qui partage son code doit avoir un compte payant)", comment: "options_calendar_title"))
                .headLine()
            
            Text(NSLocalizedString("Rejoindre un espace", comment: "options_calendar_title"))
                .title()
            
            HStack {
                Text(NSLocalizedString("Entrez le code d'un membre de votre famille", comment: "options_calendar_title"))
                    .headLine()
                
                TextField("", text: $keyUsed)
                    .roundedCornerRectangle(cornerRadius: 5)
            }
            
            Text(NSLocalizedString("Partagez votre espace", comment: "options_calendar_title"))
                .title()
            
            if keyUsed.count > 0 {
                Text(NSLocalizedString("Supprimez le code de votre famille pour créer votre propre espace", comment: "options_calendar_title"))
                    .headLine()
            } else {
                HStack {
                    Text(NSLocalizedString("Partagez votre code avec votre famille.", comment: "options_calendar_title"))
                        .headLine()
                    
                    Text("hfhrhfyerhfyehfh")
                        .headLine()
                        .roundedCornerRectangle(cornerRadius: 5)
                }
            }
            
            Text(NSLocalizedString("You need to pay for this feature", comment: "options_calendar_title"))
                .headLine()
            
            Button(action: {
                
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
        }.scrollableSheetVStack()
            .onAppear() {
                keyUsed = configurePanelVM.cloudKitController.sharedWeekPlanId
            }
    }
}

