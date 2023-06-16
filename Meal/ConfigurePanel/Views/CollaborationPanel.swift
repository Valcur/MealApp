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
    @State var keyUsed = "earreret"
    @State var useSharedCalendar = false
    @State var shareYourCalendar = false
    @State var errorMessage = ""
    var userUUID: String {
        configurePanelVM.cloudKitController.userUUID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30)  {
            
            /*------------------------ INTRO ------------------------*/
            
            Text(NSLocalizedString("Partagez votre code avec votre famille ou entrez celui d'un autre membre pour travailler sur le même planning (seul la personne qui partage son code doit avoir un compte payant)", comment: "options_calendar_title"))
                .headLine()
            
            /*------------------------ REJOINDRE ------------------------*/
            
            Text(NSLocalizedString("Rejoindre un espace", comment: "options_calendar_title"))
                .title()
            
            if shareYourCalendar {
                Text(NSLocalizedString("Vous ne pouvez pas rejoindre un espace alors que vous partagez le votre", comment: "options_calendar_title"))
                    .headLine()
            } else {
                
                Text(NSLocalizedString("Entrez le code d'un membre de votre famille (n'oubliez pas d'également activer le switch)", comment: "options_calendar_title"))
                    .headLine()
                
                HStack {
                    TextField("", text: $keyUsed)
                        .roundedCornerRectangle(cornerRadius: 5)
                    
                    Button(action: {
                        keyUsed = UIPasteboard.general.string ?? ""
                    }, label: {
                        ButtonLabel(title: "Paste", isCompact: true)
                    })
                }
                
                HStack {
                    Text("Utiliser le calendrier lié au code ci-dessus")
                        .headLine()
                    Spacer()
                    Toggle("", isOn: $useSharedCalendar.animation())
                        .labelsHidden()
                }
            }
            
            /*------------------------ PARTAGER ------------------------*/
            
            Text(NSLocalizedString("Partagez votre espace", comment: "options_calendar_title"))
                .title()
            
            if configurePanelVM.isPremium {
                if useSharedCalendar {
                    Text(NSLocalizedString("Supprimez le code de votre famille pour créer votre propre espace", comment: "options_calendar_title"))
                        .headLine()
                } else {
                    HStack {
                        Text("Partagez votre calendrier")
                            .headLine()
                        Spacer()
                        Toggle("", isOn: $shareYourCalendar.animation())
                            .labelsHidden()
                    }
                    
                    Text(NSLocalizedString("Partagez ce code avec votre famille.", comment: "options_calendar_title"))
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
                            ButtonLabel(title: "Copy", isCompact: true)
                        })
                    }
                }
            } else {
                SubscribePanel()
            }
            Spacer()
        }.safeAreaScrollableSheetVStackWithStickyButton(button: AnyView(
            VStack {
                Text(errorMessage)
                    .headLine()
                    .foregroundColor(.red)
                
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
        .navigationTitle(NSLocalizedString("Collaboration", comment: "options_calendar_title"))
    }
    
    func applyChanges() {
        errorMessage = NSLocalizedString("Veuillez patienter ...", comment: "options_calendar_title")
        
        if keyUsed.count > 0 && useSharedCalendar {
            configurePanelVM.cloudKitController.isKeyValid(keyUsed, completion: { keyValid in
                if keyValid {
                    savePreferences()
                    errorMessage = NSLocalizedString("Fuck", comment: "options_calendar_title")
                } else {
                    errorMessage = NSLocalizedString("Clé non valide", comment: "options_calendar_title")
                }
            })
        } else if shareYourCalendar {
            configurePanelVM.cloudKitController.createWeekPlanningRecordIfNeeded(completion: { success in
                if success {
                    savePreferences()
                    configurePanelVM.planningPanelVM!.saveWeek()
                } else {
                    errorMessage = "Error, try again"
                }
            })
        } else {
            savePreferences()
        }
    }
    
    func savePreferences() {
        configurePanelVM.cloudKitController.updateUserPreferences(useShared: useSharedCalendar, sharedKey: keyUsed, isSharing: shareYourCalendar)
        errorMessage = ""
    }
    
    struct SubscribePanel: View {
        @EnvironmentObject var configurePanelVM: ConfigurePanelViewModel
        var body: some View {
            VStack(spacing: 20) {
                Text(NSLocalizedString("Seul les utilisateurs payant peuvent partager leur espace (les membres de votre famille avec qui vous partagez votre code n'ont pas besoin de payer)", comment: "options_calendar_title"))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .headLine()

                
                HStack {
                    VStack {
                        Text(NSLocalizedString("Subscribe", comment: "options_calendar_title"))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .headLine()
     
                        Button(action: {
                            configurePanelVM.isPremium = true
                        }, label: {
                            ButtonLabel(title: "0.99$/month", style: .secondary)
                        })
                    }
                    Spacer()
                    VStack {
                        Text(NSLocalizedString("Already premium ?", comment: "options_calendar_title"))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .headLine()
                        Button(action: {
                            configurePanelVM.isPremium = true
                        }, label: {
                            ButtonLabel(title: "Restore", style: .secondary)
                        })
                    }
                }
            }.roundedCornerRectangle(color: Color.accentColor)
        }
    }
}

