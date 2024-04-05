//
//  WhatsNew.swift
//  Meal
//
//  Created by Loic D on 21/03/2023.
//

import SwiftUI

struct WhatsNewView: View {
    @ObservedObject var whatsNew = WhatsNewController()
    var body: some View {
        ZStack {
            
        }.sheet(isPresented: $whatsNew.showWhatsNew) {
            WhatsNewPanel()
        }
    }
    
    struct WhatsNewPanel: View {
        @Environment(\.presentationMode) var presentationMode
        let showPreviousVersion = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text(NSLocalizedString("whatsNew_title", comment: "whatsNew_title"))
                    .largeTitle(style: .secondary)
                
                Text(NSLocalizedString("whatsNew_content", comment: "whatsNew_content"))
                    .headLine()
                
                Image("WhatsNew")
                    .resizable()
                    .scaledToFill()
                
                if showPreviousVersion {
                    Text(NSLocalizedString("whatsNew_old_title", comment: "whatsNew_title"))
                        .largeTitle(style: .secondary)
                    
                    Text(NSLocalizedString("whatsNew_old_content", comment: "whatsNew_content"))
                        .headLine()
                }
                
                Spacer().padding(.bottom, 180)
            }.scrollableSheetVStackWithStickyButton(button: AnyView(
                VStack {
                    Text(NSLocalizedString("whatsNew_rateUs_title", comment: "whatsNew_rateUs_title"))
                        .title()
                    
                    Text(NSLocalizedString("whatsNew_rateUs_content", comment: "whatsNew_rateUs_content"))
                        .headLine()
                    
                    HStack {
                        Button(action: {
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "1661197013") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }, label: {
                            ButtonLabel(title: "whatsNew_rateUs_button")
                        })
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            ButtonLabel(title: "whatsNew_rateUs_noThanks", style: .secondary)
                        })
                    }
                }
            ))
        }
    }
    
    class WhatsNewController: ObservableObject {
        private let updateDate = "18/04/2024"
        @Published var showWhatsNew: Bool
        
        init() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            let newUpdateDate = dateFormatter.date(from: updateDate) ?? Date()
            
            let key = "LastUpdateDate"
            let userDefaults = UserDefaults.standard
            
            var lastValue = userDefaults.value(forKey: key) as? Date ?? Date()
            lastValue = lastValue.addingTimeInterval(1)
            print("Last update date \(lastValue) vs new update date \(newUpdateDate)")
            
            if lastValue < newUpdateDate {
                showWhatsNew = true
                userDefaults.set(newUpdateDate, forKey: key)
            } else {
                showWhatsNew = false
            }
        }
    }
}
