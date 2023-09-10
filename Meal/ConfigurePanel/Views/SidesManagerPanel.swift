//
//  SidesManagerPanel.swift
//  Meal
//
//  Created by Loic D on 05/09/2023.
//

import SwiftUI

struct SidesManagerPanel: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    @State var selectedSides: [Side] = Side.defaultSides
    @State var customSides: [Side] = []
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            Text("Reset sides")
                .subTitle()
            HStack {
                Text("Reset")
                
                Button(action: {
                    customSides = Side.defaultSides
                }, label: {
                    ButtonLabel(title: "Reset")
                })
            }
            HStack {
                Text("Your sides")
                    .subTitle()
                
                Spacer()
                
                Button(action: {
                    customSides.append(Side(name: "", id: UUID().uuidString))
                }, label: {
                    ButtonLabel(title: "+", isCompact: true)
                })
            }
            ForEach(0..<customSides.count, id:\.self) { i in
                CustomSide(sideIndex: i, customSides: $customSides)
                    .id(customSides[i].id)
            }
        }.padding(20)
        .safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                mealsListPanelVM.saveSides(customSides)
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
        ))
        .navigationTitle("Sides")
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
                    if let imageName = customSides[sideIndex].imageName, imageName != "" {
                        Image(imageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                    } else {
                        Rectangle()
                            .opacity(0.00000001)
                            .frame(width: 40, height: 40)
                    }
                    TextField("PLACEHOLDER".translate(), text: $sideName)
                        .frame(maxWidth: .infinity)
                        .textFieldBackground()
                        .onAppear() {
                            if sideIndex < customSides.count {
                                sideName = customSides[sideIndex].name
                            }
                        }
                        .onChange(of: sideName) { _ in
                            customSides[sideIndex].updateName(sideName)
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
