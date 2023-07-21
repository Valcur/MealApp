//
//  TopSearchBar.swift
//  Meal
//
//  Created by Loic D on 21/07/2023.
//

import SwiftUI

extension RecipesSearchPanel {
    private struct TopBarView: View {
        @EnvironmentObject var recipesSearchVM: RecipesSearchPanelViewModel
        @State private var searchText: String = ""
        var body: some View {
            VStack {
                VStack(spacing: 5) {
                    HStack {
                        TextField("Search recipe".translate(), text: $searchText)
                            .textFieldBackground(vPadding: 15, style: .secondary)
                            .shadowed()

                        Button(action: {
                            
                        }, label: {
                            ButtonLabel(title: "Search", isCompact: true)
                        })
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            Tag(tag: .vegan)
                            Tag(tag: .vegeterian)
                        }
                    }
                    
                    Text("\(recipesSearchVM.recipes.count) results for DDD")
                }
            }.padding(.top, 5)
        }
        
        private struct Tag: View {
            @EnvironmentObject var recipesSearchVM: RecipesSearchPanelViewModel
            let tag: SearchTag
            private var isSelected: Bool {
                recipesSearchVM.selectedSearchTags.contains(where: { $0 == tag })
            }
            var body: some View {
                Button(action: {
                    if isSelected {
                        recipesSearchVM.selectedSearchTags.removeAll(where: { $0 == tag })
                    } else {
                        recipesSearchVM.selectedSearchTags.append(tag)
                    }
                }, label: {
                    Text(tag.title())
                        .foregroundColor(isSelected ? Color("WhiteBackgroundColor") : Color("TextColor"))
                })
                .frame(height: 40)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.accentColor : Color("WhiteBackgroundColor"))
                .cornerRadius(50)
                .shadowed()
                .padding(5)
            }
        }
    }
}
