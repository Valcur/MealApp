//
//  PlanningPannel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import SwiftUI

struct PlanningPannel: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @ObservedObject var cloudKitController: CloudKitController
    @State private var showingAutoFillSheet = false
    
    // To show ... when saving to the cloud
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var savingToCloudProgressDots = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("WhiteBackgroundColor").frame(height: 80).offset(y: -40)
            VStack(spacing: 0) {
                HStack {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                planningPanelVM.switchToThisWeek()
                            }, label: {
                                Text(WichWeekIsIt.thisWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .thisWeek ? .primary : .secondary, numberOfLine: 1, accentColor: userPrefs.accentColor)
                            })
                            Button(action: {
                                planningPanelVM.switchToNextWeek()
                            }, label: {
                                Text(WichWeekIsIt.nextWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .nextWeek ? .primary : .secondary, numberOfLine: 1, accentColor: userPrefs.accentColor)
                            })
                        }
                    } else {
                        HStack {
                            Button(action: {
                                planningPanelVM.switchToThisWeek()
                            }, label: {
                                Text(WichWeekIsIt.thisWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .thisWeek ? .primary : .secondary, accentColor: userPrefs.accentColor)
                            }).padding(.trailing, 40)
                            Button(action: {
                                planningPanelVM.switchToNextWeek()
                            }, label: {
                                Text(WichWeekIsIt.nextWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .nextWeek ? .primary : .secondary, accentColor: userPrefs.accentColor)
                            })
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        ZStack {
                            Image(systemName: "icloud.fill")
                                .resizable()
                                .frame(width: 50, height: 34)
                            
                            Text(savingToCloudProgressDots)
                                .font(.headline)
                                .foregroundColor(Color(UIColor.systemBackground))
                                .onReceive(timer) { time in
                                    if savingToCloudProgressDots == ""  {
                                        savingToCloudProgressDots = "."
                                    } else if savingToCloudProgressDots == "."  {
                                        savingToCloudProgressDots = ".."
                                    } else if savingToCloudProgressDots == ".."  {
                                        savingToCloudProgressDots = "..."
                                    } else {
                                        savingToCloudProgressDots = ""
                                    }
                                }
                        }.opacity(cloudKitController.cloudSyncStatus == .inProgress ? 1 : 0)

                        
                        Button(action: {
                            planningPanelVM.updateData()
                        }, label: {
                            ZStack {
                                Image(systemName: "exclamationmark.icloud.fill")
                                    .resizable()
                                    .frame(width: 50, height: 34)
                                    .foregroundColor(userPrefs.accentColor)
                                
                                Text("tryAgain".translate())
                                    .font(.caption)
                                    .offset(y: 25)
                                    .foregroundColor(userPrefs.accentColor)
                            }
                        }).opacity(cloudKitController.cloudSyncStatus == .error ? 1 : 0)
                            
                    }.frame(width: 60, height: 40)

                    Button(action: {
                        showingAutoFillSheet = true
                    }, label: {
                        ButtonLabel(title: "autofill", isCompact: true)
                    })
                    .sheet(isPresented: $showingAutoFillSheet) {
                        AutoFillSheet()
                    }
                }.padding([.bottom, .horizontal], 20).background(Color("WhiteBackgroundColor").shadow(color: Color("ShadowColor"), radius: 4).mask(Rectangle().padding(.bottom, -20)))
                
                WeekPlanOrganiser().background(
                    VStack{
                        if userPrefs.backgroundImage != 0 {
                            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial)).frame(height: 70)
                        }
                        Spacer()
                    }
                )
            }
            
            // For new users when meals list is empty
            NewUserInfoBuble(text: "newUserBuble_myWeek", xOffset: 0, yOffset: 30, height: 250, arrowSide: .center, isVisible: planningPanelVM.mealsVM.isListEmpty)


        }//.background(Color("BackgroundColor"))
        .background(BackgroundImageView())
    }
}

struct PlanningPannel_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15, *) {
            PlanningPannel(cloudKitController: CloudKitController())
                .environmentObject(PlanningPanelViewModel(mealsVM: MealsListPanelViewModel(), configureVM: ConfigurePanelViewModel(cloudKitController: CloudKitController()), cloudKitController: CloudKitController()))
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        } else {
            PlanningPannel(cloudKitController: CloudKitController())
                .previewDevice(PreviewDevice(rawValue: "iPad Air (5th generation)"))
        }

    }
}
