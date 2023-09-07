//
//  Side.swift
//  Meal
//
//  Created by Loic D on 23/01/2023.
//

import SwiftUI

struct Side: Codable, Equatable {
    var id: String
    var name: String
    var imageName: String
    
    init(key: String) {
        self.name = NSLocalizedString(key, comment: key)
        self.imageName = key
        self.id = "default-side-" + key
    }
    
    init(key: String, id: String) {
        self.name = NSLocalizedString(key, comment: key)
        self.imageName = ""
        self.id = id
    }
    
    static func ==(lhs: Side, rhs: Side) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func addSidesToMealName(_ mealName: String, sides: [Side]) -> String {
        var name = mealName
        if sides.count > 0 {
            name = "\(mealName) et"
            for i in 0..<sides.count {
                name = "\(name) \(sides[i].name)"
                if i != sides.count - 1 {
                    name = "\(name),"
                }
            }
        }
        return name
    }
    
    static func sidesNameDescription(_ sides: [Side]) -> String {
        guard sides.count > 0 else { return "" }
        var description = "\(NSLocalizedString("avec", comment: "avec")) \(sides[0].name)"
        for i in 1..<sides.count {
            if i == sides.count - 1 {
                description = "\(description) \(NSLocalizedString("et", comment: "et")) \(sides[i].name)"
            } else {
                description = "\(description), \(sides[i].name)"
            }
        }
        return description
    }
    
    static let defaultSides: [Side] = [
        Side(key: "pates"),
        Side(key: "riz"),
        Side(key: "semoule"),
        Side(key: "pomme-de-terre"),
        Side(key: "haricots-verts"),
        Side(key: "puree"),
        Side(key: "salade"),
        Side(key: "gnocchi"),
        Side(key: "legumes"),
        Side(key: "pois-chiche"),
        Side(key: "galette-patate"),
        Side(key: "polenta"),
        Side(key: "chou"),
        Side(key: "crudite"),
        Side(key: "taboule"),
        Side(key: "pomme-noisette"),
        Side(key: "flageolets")
    ].sorted(by: {$0.name < $1.name})
    
    static let sides: [Side] = [
        Side(key: "pates"),
        Side(key: "riz"),
        Side(key: "semoule"),
        Side(key: "pomme-de-terre"),
        Side(key: "haricots-verts"),
        Side(key: "puree"),
        Side(key: "salade"),
        Side(key: "gnocchi"),
        Side(key: "legumes"),
        Side(key: "pois-chiche"),
        Side(key: "galette-patate"),
        Side(key: "polenta"),
        Side(key: "chou"),
        Side(key: "crudite"),
        Side(key: "taboule"),
        Side(key: "pomme-noisette"),
        Side(key: "flageolets"),
        
        Side(key: "poivron"),
        Side(key: "avocat"),
        Side(key: "petit-pois"),
        Side(key: "carrotes"),
    ].sorted(by: {$0.name < $1.name})
}

struct SidePickerView: View {
    @EnvironmentObject var mealsListPanelVM: MealsListPanelViewModel
    let columns = [GridItem(.adaptive(minimum: 65))]
    @State var sides: [Side] = []
    @Binding var selectedSides: [Side]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<sides.count, id: \.self) { i in
                SideView(side: sides[i], selectedSides: $selectedSides)
            }
        }
        .onChange(of: selectedSides) { _ in
            // A REFAIRE PAS DANS UN ONCHANGE A L'OCCASION
            for side in selectedSides {
                if !sides.contains(where: { $0.name == side.name }) {
                    sides.append(side)
                }
            }
            sides = sides.sorted(by: {$0.name < $1.name})
        }
        .onAppear() {
            sides = mealsListPanelVM.sides
        }
    }
    
    struct SideView: View {
        let side: Side
        @Binding var selectedSides: [Side]
        var isSelected: Bool {
            selectedSides.contains(where: {side.id == $0.id})
        }
        
        var body: some View {
            Button(action: {
                if isSelected {
                    selectedSides.removeAll(where: {side.id == $0.id})
                } else {
                    selectedSides.append(side)
                }
            }, label: {
                VStack {
                    Image(side.imageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.vertical, 10)
                        .roundedCornerRectangle(padding: 10, color: isSelected ? .accentColor : Color("BackgroundColor"))
                    Text(side.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 35)
                        .offset(y: -10)
                }
            })
        }
    }
}
