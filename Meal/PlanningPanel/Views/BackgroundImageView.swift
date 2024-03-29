//
//  BackgroundImageView.swift
//  Meal
//
//  Created by Loic D on 23/03/2024.
//

import SwiftUI

struct BackgroundImageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPrefs: VisualUserPrefs
    var body: some View {
        ZStack {
            Color("BackgroundColor")
            if userPrefs.backgroundImage > 0 {
                if colorScheme == .light {
                    Image(userPrefs.backgroundImageName)
                        .resizable(resizingMode: .tile)
                        .opacity(1)
                } else {
                    Image(userPrefs.backgroundDarkImageName)
                        .resizable(resizingMode: .tile)
                }
            }
            if userPrefs.backgroundImage == -1 {
                AnyView(userPrefs.customBackgroundImageView)
            }
        }.clipped()
    }
}
