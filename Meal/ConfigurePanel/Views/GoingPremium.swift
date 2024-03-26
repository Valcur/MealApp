//
//  GoingPremium.swift
//  Meal
//
//  Created by Loic D on 07/03/2024.
//

import SwiftUI

struct GoingPremium: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    
    var body: some View {
        if configurePanelVM.paymentProcessing {
            ZStack {
                Text(NSLocalizedString("collaboration.premium.processing", comment: "collaboration.premium.processing"))
                    .headLine()
                    .frame(maxWidth: .infinity)
            }.frame(height: 100)
        } else {
            SubscribePanel()
        }
    }
    
    struct SubscribePanel: View {
        @EnvironmentObject var userPrefs: VisualUserPrefs
        @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
        @State var showingBuyInfo = false
        
        var body: some View {
            VStack(spacing: 20) {
                Text(NSLocalizedString("collaboration.premium.description", comment: "collaboration.premium.description"))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .headLine()

                
                HStack {
                    VStack {
                        Text(NSLocalizedString("collaboration.premium.subscribe.description", comment: "collaboration.premium.subscribe.description"))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .headLine()
     
                        HStack {
                            Button(action: {
                                showingBuyInfo = true
                            }, label: {
                                ButtonLabel(title: "\(IAPManager.shared.price(forProduct: IAPManager.getSubscriptionId()) ?? "0.99")\("per_month".translate())", style: .secondary)
                            })
                            Button(action: {
                                showingBuyInfo = true
                            }, label: {
                                ButtonLabel(title: "\(IAPManager.shared.price(forProduct: IAPManager.getLifetimeId()) ?? "0.99")\("forever")", style: .secondary)
                            })
                        }
                    }
                    Spacer()
                    VStack {
                        Text(NSLocalizedString("collaboration.premium.restore.description", comment: "collaboration.premium.restore.description"))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .headLine()
                        Button(action: {
                            configurePanelVM.restore()
                        }, label: {
                            ButtonLabel(title: "collaboration.premium.restore.title", style: .secondary)
                        })
                    }
                }

                 HStack(spacing: 0) {
                     Text("premium_viewOur".translate())
                         .foregroundColor(.white)
                     
                     Link("premium_policy".translate(),
                           destination: URL(string: "http://www.burning-beard.com/privacy-policy")!).foregroundColor(.blue)
                     
                     Text(", ")
                         .foregroundColor(.white)
                     
                     Link("EULA",
                           destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!).foregroundColor(.blue)
                 }

            }.roundedCornerRectangle(color: userPrefs.accentColor)
                .alert(isPresented: $showingBuyInfo) {
                    Alert(
                        title: Text("premium_info_title".translate()),
                        message: Text("premium_info_content".translate()),
                        primaryButton: .destructive(
                            Text("cancel".translate()),
                            action: {showingBuyInfo = false}
                        ),
                        secondaryButton: .default(
                            Text("continue".translate()),
                            action: {
                                configurePanelVM.buy()
                            }
                        )
                    )
                }
        }
    }
}
