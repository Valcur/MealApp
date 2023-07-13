//
//  PlanningPannel.swift
//  Meal
//
//  Created by Loic D on 08/12/2022.
//

import SwiftUI

struct PlanningPannel: View {
    @EnvironmentObject var planningPanelVM : PlanningPanelViewModel
    @ObservedObject var cloudKitController: CloudKitController
    @State private var showingAutoFillSheet = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                HStack {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                planningPanelVM.switchToThisWeek()
                            }, label: {
                                Text(WichWeekIsIt.thisWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .thisWeek ? .primary : .secondary, numberOfLine: 1)
                            })
                            Button(action: {
                                planningPanelVM.switchToNextWeek()
                            }, label: {
                                Text(WichWeekIsIt.nextWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .nextWeek ? .primary : .secondary, numberOfLine: 1)
                            })
                        }
                    } else {
                        HStack {
                            Button(action: {
                                planningPanelVM.switchToThisWeek()
                            }, label: {
                                Text(WichWeekIsIt.thisWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .thisWeek ? .primary : .secondary)
                            }).padding(.trailing, 40)
                            Button(action: {
                                planningPanelVM.switchToNextWeek()
                            }, label: {
                                Text(WichWeekIsIt.nextWeek.name())
                                    .largeTitle(style: planningPanelVM.selectedWeek == .nextWeek ? .primary : .secondary)
                            })
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        ZStack {
                            Image(systemName: "icloud.fill")
                                .resizable()
                                .frame(width: 50, height: 34)
                            
                            Image(systemName: "arrow.clockwise")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.systemBackground))
                        }.opacity(cloudKitController.cloudSyncStatus == .inProgress ? 1 : 0)

                        
                        Button(action: {
                            planningPanelVM.updateData()
                        }, label: {
                            ZStack {
                                Image(systemName: "exclamationmark.icloud.fill")
                                    .resizable()
                                    .frame(width: 50, height: 34)
                                
                                Text("Try again")
                                    .font(.caption)
                                    .offset(y: 25)
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
                
                WeekPlanOrganiser()
            }

        }.background(Color("BackgroundColor"))
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
