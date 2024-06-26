//
//  CollaborationPanel.swift
//  Meal
//
//  Created by Loic D on 12/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct CollaborationPanel: View {
    @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
    @State var keyUsed = "fail"
    @State var useSharedCalendar = false
    @State var shareYourCalendar = false
    @State var errorMessage = ""
    var userUUID: String {
        configurePanelVM.cloudKitController.userUUID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            
            /*------------------------ INTRO ------------------------*/
            
            Text(NSLocalizedString("collaboration.description", comment: "collaboration.description"))
                .headLine()
            
            /*------------------------ REJOINDRE ------------------------*/
            
            Text(NSLocalizedString("collaboration.useSharedPlanning.title", comment: "collaboration.useSharedPlanning.title"))
                .title()
            
            if shareYourCalendar {
                Text(NSLocalizedString("collaboration.useSharedPlanning.error", comment: "collaboration.useSharedPlanning.error"))
                    .headLine()
            } else {
                HStack {
                    Text("collaboration.useSharedPlanning.toggle")
                        .headLine()
                    Spacer()
                    Toggle("", isOn: $useSharedCalendar.animation())
                        .labelsHidden()
                }
                
                if useSharedCalendar {
                    Text(NSLocalizedString("collaboration.useSharedPlanning.codeDescription", comment: "collaboration.useSharedPlanning.codeDescription"))
                        .headLine()
                    
                    HStack {
                        if #available(iOS 16.0, *) {
                            TextField("", text: $keyUsed, axis: .vertical)
                                .roundedCornerRectangle(cornerRadius: 5)
                        } else {
                            TextField("", text: $keyUsed)
                                .roundedCornerRectangle(cornerRadius: 5)
                        }
                        
                        
                        Button(action: {
                            keyUsed = UIPasteboard.general.string ?? ""
                        }, label: {
                            ButtonLabel(title: "paste", isCompact: true)
                        })
                    }
                }
            }
            
            /*------------------------ PARTAGER ------------------------*/
            
            Text(NSLocalizedString("collaboration.shareYourPlanning.title", comment: "collaboration.shareYourPlanning.title"))
                .title()
            
            if configurePanelVM.isPremium {
                if useSharedCalendar {
                    Text(NSLocalizedString("collaboration.shareYourPlanning.error", comment: "collaboration.shareYourPlanning.error"))
                        .headLine()
                } else {
                    HStack {
                        Text(NSLocalizedString("collaboration.shareYourPlanning.toggle", comment: "collaboration.shareYourPlanning.toggle"))
                            .headLine()
                        Spacer()
                        Toggle("", isOn: $shareYourCalendar.animation())
                            .labelsHidden()
                    }
                    
                    if shareYourCalendar {
                        Text(NSLocalizedString("collaboration.shareYourPlanning.codeDescription", comment: "collaboration.shareYourPlanning.codeDescription"))
                            .headLine()
                        
                        HStack {
                            HStack {
                                Text(userUUID)
                                    .headLine()
                                Spacer()
                            }.roundedCornerRectangle(cornerRadius: 5)
                            
                            Button(action: {
                                UIPasteboard.general.setValue(userUUID,
                                                              forPasteboardType: UTType.plainText.identifier)
                            }, label: {
                                ButtonLabel(title: "copy", isCompact: true)
                            })
                        }
                    }
                }
            } else {
                GoingPremium()
            }
            Spacer()
        }.safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            VStack {
                if errorMessage != "" {
                    Text(errorMessage)
                        .headLine()
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    applyChanges()
                }, label: {
                    ButtonLabel(title: "confirmChangesButton")
                })
            }
        ))
        .onAppear() {
            useSharedCalendar = configurePanelVM.cloudKitController.useSharedPlanning
            shareYourCalendar = configurePanelVM.cloudKitController.shareYourPlanning
            keyUsed = configurePanelVM.cloudKitController.sharedPlanningUUID
        }
        .onChange(of: shareYourCalendar) { _ in
            if shareYourCalendar {
                useSharedCalendar = false
            }
        }
        .onChange(of: useSharedCalendar) { _ in
            if useSharedCalendar {
                shareYourCalendar = false
            }
        }
        .navigationTitle(NSLocalizedString("collaboration.title", comment: "collaboration.title"))
    }
    
    func applyChanges() {
        errorMessage = NSLocalizedString("collaboration.errorMessage.progress", comment: "collaboration.errorMessage.progress")
        
        if keyUsed.count > 0 && useSharedCalendar {
            configurePanelVM.cloudKitController.isKeyValid(keyUsed, completion: { keyValid in
                if keyValid {
                    savePreferences()
                    errorMessage = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        configurePanelVM.planningPanelVM!.updateData(forceUpdate: true)
                    })
                } else {
                    errorMessage = NSLocalizedString("collaboration.errorMessage.invalidKey", comment: "collaboration.errorMessage.invalidKey")
                }
            })
        } else if shareYourCalendar {
            configurePanelVM.cloudKitController.createWeekPlanningRecordIfNeeded(completion: { success in
                if success {
                    savePreferences()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        configurePanelVM.planningPanelVM!.saveBothWeeks()
                    })
                } else {
                    errorMessage = NSLocalizedString("collaboration.errorMessage.tryAgain", comment: "collaboration.errorMessage.tryAgain")
                }
            })
        } else if keyUsed.count == 0 && useSharedCalendar {
            errorMessage = "collaboration.errorMessage.invalidKey".translate()
        } else {
            savePreferences()
        }
    }
    
    func savePreferences() {
        configurePanelVM.cloudKitController.updateUserPreferences(useShared: useSharedCalendar, sharedKey: keyUsed, isSharing: shareYourCalendar)
        errorMessage = ""
    }
}

