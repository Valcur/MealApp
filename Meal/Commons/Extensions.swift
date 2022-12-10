//
//  Extensions.swift
//  Meal
//
//  Created by Loic D on 07/12/2022.
//

import Foundation
import SwiftUI

extension View {
    func roundedCornerRectangle(padding: CGFloat = 15, cornerRadius: CGFloat = 10, shadowRadius: CGFloat = 5, margin: CGFloat = 5) -> some View {
        self
            .padding(padding)
            .cornerRadius(cornerRadius)
            .padding(margin)
            .background(Color.white.cornerRadius(cornerRadius).shadow(color: Color("ShadowColor"), radius: shadowRadius, y: shadowRadius / 2).padding(shadowRadius))
            
    }
}

extension Text {
    func largeTitle(style: TextStyle = .primary) -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
    }
    
    func title(style: TextStyle = .primary) -> some View {
        self
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
    }
    
    func subTitle(style: TextStyle = .primary) -> some View {
        self
            .font(.title3)
            .fontWeight(.regular)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
    }
    
    enum TextStyle {
        case primary
        case secondary
    }
}

struct ButtonLabel: View {
    let title: String
    var body: some View {
        ZStack {
            Color("AccentColor")
            Text(title)
                .foregroundColor(.white)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}
