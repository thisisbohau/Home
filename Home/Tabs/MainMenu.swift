//
//  MainMenu.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.12.21.
//

import Foundation
import SwiftUI

struct MainMenu: View{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: UpdateManager
    @EnvironmentObject var sceneKit: SceneKit
    
    var body: some View{
        ZStack{
            VStack{
            if updater.showServerSetup{
                ServerSetup()
            }else if updater.showDeviceSetup{
                NewDeviceAccess(show: $updater.showDeviceSetup)
            }else{
                main
            }
        }
//            .onAppear(perform: {
//                print(AccessKit().getDeviceToken())
//                if AccessKit().getDeviceToken() != "   "{
//                    updater.showDeviceSetup = true
//                }
//            })
            
            
            if sceneKit.settingScene{
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                    }
                }.background(.ultraThinMaterial).opacity(0.3).ignoresSafeArea()
                VStack{
                    Spacer()
                    VStack{
                        HStack{
                            Spacer()
                            Text("Setting Scene")
                                .font(.largeTitle.bold())
                                .padding(.top)
                                .foregroundStyle(.primary)
                                .colorScheme(.light)
                            Spacer()

                        }.padding()
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .scaleEffect(1.5)
                            .colorScheme(.light)
                        Spacer()
                        Text("Home is adjusting devices.")
                            .bold()
                            .foregroundStyle(.secondary)
                            .padding()
                            .padding(.bottom)
                            .colorScheme(.light)
                    }
                    .ignoresSafeArea()
                    .aspectRatio(1, contentMode: .fit)
                    .background(.white)
                    .cornerRadius(35)
                    .padding(5)

                }.transition(.move(edge: .bottom))
            }
        }
    }
    var main: some View{
        TabView(selection: $appState.activeTab){
                MainView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(1)
                RoomView(room: $appState.activeRoom)
                    
                    .tabItem {
                        Label("Rooms", systemImage: "square.split.bottomrightquarter")
                    }
                    .tag(2)
                SceneList()
            
            
                    .tabItem {
                        Label("Scenes", systemImage: "camera.filters")
                    }
                    .tag(3)
                Settings()
                    
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.2")
                    }
                    .tag(4)

            }

    }
}
