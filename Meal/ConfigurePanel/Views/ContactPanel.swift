//
//  ContactPanel.swift
//  Meal
//
//  Created by Loic D on 27/03/2024.
//

import SwiftUI

struct ContactPanel: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    private let mail = "mailto:loic.danjean@burning-beard.com"
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text("options.contact.content".translate())
            if #available(iOS 16.0, *) {
                Link("options.contact.button".translate(), destination: URL(string: mail)!)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .roundedCornerRectangle(color: userPrefs.accentColor)
            } else {
                Link("options.contact.button".translate(), destination: URL(string: mail)!)
                    .foregroundColor(.white)
                    .roundedCornerRectangle(color: userPrefs.accentColor)
            }
        }.padding(20)
        .navigationTitle("Contact")
    }
}
