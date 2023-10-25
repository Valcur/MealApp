//
//  SidesManagerPanel.swift
//  Meal
//
//  Created by Loic D on 05/09/2023.
//

import SwiftUI

struct SidesManagerPanel: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    //@State var selectedSides: [Side] = Side.defaultSides
    @State var customSides: [Side] = []
    var body: some View {
        VStack(alignment: .leading, spacing: 40)  {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("sides-manager.custom.title".translate())
                        .subTitle()
                    
                    Spacer()
                    
                    if customSides.count <= 30 {
                        Button(action: {
                            if customSides.count <= 30 {
                                customSides.insert(Side(name: "", id: UUID().uuidString), at: 0)
                            }
                        }, label: {
                            ButtonLabel(title: "+", isCompact: true)
                        })
                    }
                }
                
                ForEach(0..<customSides.count, id:\.self) { i in
                    CustomSide(sideIndex: i, customSides: $customSides)
                        .id(customSides[i].id)
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("sides-manager.reset.title".translate())
                    .subTitle()
                HStack {
                    Text("sides-manager.reset.content".translate()).padding(.trailing, 20)
                    Spacer()
                    Button(action: {
                        customSides = Side.defaultSides
                    }, label: {
                        ButtonLabel(title: "reset", isCompact: true)
                    })
                }
            }
        }
        .safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                mealsListPanelVM.saveSides(customSides)
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
        ))
        .navigationTitle("sides-manager.title".translate())
        .onAppear() {
            customSides = mealsListPanelVM.sides
        }
    }
    
    struct CustomSide: View {
        let sideIndex: Int
        @Binding var customSides: [Side]
        @State var sideName: String = ""
        var body: some View {
            if sideIndex < customSides.count {
                HStack(spacing: 20) {
                    if let side = customSides[sideIndex] {
                        if side.isDefaultSide {
                            Image(side.imageName)
                               .resizable()
                               .frame(width: 40, height: 40)
                        } else {
                            Text(side.imageName)
                               .font(.title2)
                               .fontWeight(.bold)
                               .foregroundColor(Color("TextColor"))
                               .frame(width: 40, height: 40)
                        }
                        
                        ZStack {
                            TextField("sides-manager.custom.placeholder".translate(), text: $sideName)
                                .allowsHitTesting(!side.isDefaultSide)
                                .frame(maxWidth: .infinity)
                                .textFieldBackground(style: side.isDefaultSide ? .secondary : .primary)
                                .onAppear() {
                                    if sideIndex < customSides.count {
                                        sideName = customSides[sideIndex].name
                                    }
                                }
                                .onChange(of: sideName) { _ in
                                    sideName = String(sideName.prefix(20))
                                    customSides[sideIndex].updateName(sideName)
                                }
                        }
                        
                        Button(action: {
                            customSides.remove(at: sideIndex)
                        }, label: {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                        })
                    }
                }
            }
        }
    }
}
