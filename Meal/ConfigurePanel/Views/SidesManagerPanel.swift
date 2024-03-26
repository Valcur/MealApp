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
    //@State var customSides: [Side] = []
    @ObservedObject var customSides = CustomSidesObject()
    
    class CustomSidesObject: ObservableObject {
        @Published var sides: [Side] = []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40)  {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("sides-manager.custom.title".translate())
                        .subTitle()
                    
                    Spacer()
                    
                    if customSides.sides.count <= 30 {
                        Button(action: {
                            if customSides.sides.count <= 30 {
                                customSides.sides.insert(Side(name: "", id: UUID().uuidString), at: 0)
                            }
                        }, label: {
                            ButtonLabel(title: "+", isCompact: true)
                        })
                    }
                }
                
                ForEach(customSides.sides) { side in
                    if let i = customSides.sides.firstIndex(of: side) {
                        CustomSide(sideIndex: i, customSides: $customSides.sides)
                            .id(side.id)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("sides-manager.reset.title".translate())
                    .subTitle()
                HStack {
                    Text("sides-manager.reset.content".translate()).padding(.trailing, 20)
                    Spacer()
                    Button(action: {
                        customSides.sides = Side.defaultSides
                    }, label: {
                        ButtonLabel(title: "reset", isCompact: true)
                    })
                }
            }
        }
        .safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            Button(action: {
                mealsListPanelVM.saveSides(customSides.sides)
            }, label: {
                ButtonLabel(title: "confirmChangesButton")
            })
        ))
        .navigationTitle("sides-manager.title".translate())
        .onAppear() {
            customSides.sides = mealsListPanelVM.sides
        }
    }
    
    struct CustomSide: View {
        let sideIndex: Int
        @Binding var customSides: [Side]
        @State var sideName: String = ""
        
        @State var showImagePicker: Bool = false
        @State private var inputImage: UIImage?
        
        var body: some View {
            if sideIndex < customSides.count {
                HStack(spacing: 20) {
                    if let side = customSides[sideIndex] {
                        if side.isDefaultSide {
                            Image(side.imageName)
                               .resizable()
                               .frame(width: 40, height: 40)
                        } else {
                            if let sideImage = side.customImage {
                                Image(uiImage: sideImage.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            } else {
                                Text(side.imageName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TextColor"))
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                        if !side.isDefaultSide {
                            Button(action: {
                                showImagePicker = true
                            }, label: {
                                Image(systemName: "photo")
                                    .font(.headline)
                                    .foregroundColor(Color("TextColor"))
                                    .textFieldBackground(hPadding: 25, style: .primary)
                            }).frame(width: 60)
                                .onChange(of: inputImage) { _ in
                                    guard let inputImage = inputImage else { return }
                                    customSides[sideIndex].updateImage(inputImage)
                                }
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(image: $inputImage).preferredColorScheme(.dark)
                                        .ignoresSafeArea()
                                }
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

/*
 360 personnes
 180 fr 8eme arrondissement
 
 manager
 3 dev ios 3 android
 1 designer
 
 interraction de
 
 */
