//
//  VStackBlock.swift
//  Meal
//
//  Created by Loic D on 05/04/2024.
//

import SwiftUI

struct VStackBlock<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20, content: content)
            .frame(maxWidth: .infinity)
            .roundedCornerRectangle(shadowRadius: 0)
            .padding(.horizontal, -5)
            .padding(.vertical, -5)
    }
}
