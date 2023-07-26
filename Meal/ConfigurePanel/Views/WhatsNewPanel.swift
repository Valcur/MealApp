//
//  WhatsNewPanel.swift
//  Meal
//
//  Created by Loic D on 26/03/2023.
//

import SwiftUI

struct WhatsNewPanel: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("whatsNew_content", comment: "whatsNew_content"))
                .headLine()
            
            HStack {
                Spacer()
                /*Image("WhatsNew")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)*/
                Spacer()
            }.padding(.horizontal, 50)
            
            if true {
                Text(NSLocalizedString("whatsNew_old_title", comment: "whatsNew_title"))
                    .largeTitle(style: .secondary)
                
                Text(NSLocalizedString("whatsNew_old_content", comment: "whatsNew_content"))
                    .headLine()
            }
            Spacer()
        }.scrollableSheetVStack()
        .navigationTitle(NSLocalizedString("whatsNew_title", comment: "whatsNew_title"))
    }
}
