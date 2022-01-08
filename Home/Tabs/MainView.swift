//
//  MainView.swift
//  Home
//
//  Created by David Bohaumilitzky on 20.09.21.
//

import SwiftUI


struct OverviewDivider: View{
    var title: String
    var icon: String
    
    var body: some View{
        HStack{
            Image(icon)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color("secondaryFill"), Color("background"))
            Text(title)
                .bold()
                .foregroundColor(Color("primary"))
            Spacer()
        }.font(.title)
    }
}

struct MainStatusItem: View{
    var icon: String
    var isSystem: Bool
    var title: String
    var color: Color
    
    var body: some View{
        if isSystem{
            HStack{
                Image(systemName: icon)
                    .symbolRenderingMode(color == .clear ? .multicolor : .none)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(title)
                    .lineLimit(1)
//                    .fixedSize()
                    .font(.callout)
            }.padding(.bottom, 1)
        }else{
            HStack{
                Image(icon)
                    .symbolRenderingMode(color == .clear ? .multicolor : .none)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(title)
                    .lineLimit(1)
//                    .fixedSize()
                    .font(.callout)
            }.padding(.bottom, 1)
        }
    }
    
}
struct MainView: View {
    @State var leave: Bool = false
    @EnvironmentObject var updater: UpdateManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKit: SceneKit
    @ObservedObject var roomTagScanner = RoomTagKit()
//    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var notifications: Bool = false
    @State var showErrorPage: Bool = false
    @State var showPowerPage: Bool = false
    @State var showSentry: Bool = false
    @State var showIrrigation: Bool = false
    @State var showNight: Bool = false
    @State var showDogMode: Bool = false
    
    @State var roomDetected: Bool = false
    @State var detectedRoomId: Int = 0
    @State var room: Room = Room(id: 0, name: "", floor: 0, lights: [Light](), blinds: [Blind](), tempDevices: [TempDevice](), type: RoomType(icon: "", color: ""), occupied: false, lastOccupied: "", openWindow: false, windows: [WindowSensor]())
    
    func openSentry(){
        Biometrics().authenticate(){result in
            if result{
                showSentry = true
            }
        }
    }
    func parseTag(url: URL){
        print("URL received: \(url.description)")
        guard let components = URLComponents(string: url.absoluteString) else{
            print("URL components not found")
            return}
        
        if components.path == "/roomTag/"{
            guard let roomId = components.queryItems?.first(where: {$0.name == "room"})else{
                print("URL: room not found")
                return}
            
            print("URL opening room")
            roomDetected = true
            appState.showRoomSelector = true
            detectedRoomId = Int(roomId.value ?? "") ?? 0
            
            
            print("Room Tag scan complete\(detectedRoomId)")
        }
    }
    
    var catchArea: some View{
        
        VStack(alignment: .leading){
            if updater.currentDevice.role == 1{
                MainStatusItem(icon: "hourglass", isSystem: true, title: "You are a Visitor", color: .accentColor)
            }
            Button(action: {}){
                MainStatusItem(icon: "homeIcon", isSystem: false, title: LocationControl().getPresenceVerbos(devices: updater.status.devices, current: updater.currentDevice), color: .accentColor)
            }
            if updater.error{
                Button(action: {showErrorPage.toggle()}){
                    MainStatusItem(icon: "exclamationmark.icloud", isSystem: true, title: "No Server Connection", color: .pink)
                }
            }
            if (updater.status.power.powerOutage?.outage ?? false){
                Button(action: {showPowerPage.toggle()}){
                    MainStatusItem(icon: "exclamationmark.circle", isSystem: true, title: "Power Grid Failure", color: .yellow)
                }
            }
            if updater.status.dogMode.active{
                Button(action: {showDogMode.toggle()}){
                    MainStatusItem(icon: "pawprint", isSystem: true, title: "Dog Mode active", color: .orange)
                }
            }
            
            if updater.status.sentry.active{
                if !updater.status.sentry.alarmState && !updater.status.sentry.sentryTriggered{
                    Button(action: openSentry){
                        MainStatusItem(icon: "sentry", isSystem: false, title: "Sentry active", color: .clear)
                    }
                }
//                MainStatusItem(icon: "shield.righthalf.filled", isSystem: true, title: "Protected by Home", color: Color("secondary"))
            }
            
            if updater.status.sentry.sentryTriggered{
                Button(action: openSentry){
                    MainStatusItem(icon: "sentry", isSystem: false, title: "The Alarm has been triggered", color: .clear)
                }
            }else if updater.status.sentry.alarmState{
                Button(action: openSentry){
                    MainStatusItem(icon: "sentry", isSystem: false, title: "Sentry has triggered the Alarm State", color: .clear)
                }
            }
            
            if !updater.status.notifications.isEmpty{
                Button(action: {notifications.toggle()}){
                    MainStatusItem(icon: "circle.fill", isSystem: true, title: "\(updater.status.notifications.count) new Notification\(updater.status.notifications.count != 1 ? "s" : "")", color: Color("secondary"))
                }
            }
            
            if updater.status.morning.showBedtime{
                Button(action: {showNight.toggle()}){
                    MainStatusItem(icon: "moon.fill", isSystem: true, title: "Bedtime Routine", color: .indigo)
                }
            }else if updater.status.morning.nextDestinationId != 0{
                Button(action: {showNight.toggle()}){
                    MainStatusItem(icon: "sunrise.fill", isSystem: true, title: "Morning Routine set", color: Color("secondary"))
                }
            }
            
            HStack{
                Spacer()
            }
        }.foregroundColor(Color("secondary"))
    }
    var body: some View {
        GeometryReader{proxy in
            ZStack{
                Color("background")
                    .ignoresSafeArea()
                VStack{
                    ScrollView{
                        VStack{
                            HStack(alignment: .top){
                                VStack(alignment: .leading){
                                    Text(AccessKit().getWelcomeDisplay(currentUser: updater.currentDevice))
                                        .font(.largeTitle.bold())
                                        .foregroundColor(Color("primary"))
//                                        .padding(.bottom, 2)
                                        .animation(.linear, value: updater.lastUpdated)
                                    
                                    
                                    Spacer()
                                }.padding([.leading, .top])
                                Spacer()
                                Button(action: {leave.toggle()}){
                                    Text("Leave")
                                        .font(.title3)
                                        .padding(sizeOptimizer(iPhoneSize: 10, iPadSize: 15))
                                        .padding([.leading, .trailing], sizeOptimizer(iPhoneSize: 7, iPadSize: 10))
                                        .foregroundColor(Color("secondary"))
                                        .background(Color("fill"))
                                        .cornerRadius(30)
                                        .padding([.trailing, .top])
                                }
                            }
                            catchArea
                                .padding(.leading)
                                .animation(.linear, value: updater.lastUpdated)
                            VStack{
                                if updater.status.morning.showMorning{
                                    MorningView(proxy: proxy.size)
                                        .environmentObject(MorningKit())
                                }else{
                                    
                                    HomeModel()
                                        .frame(width: proxy.size.width * sizeOptimizer(iPhoneSize: 1, iPadSize: 0.7))
                                        .offset(y: sizeOptimizer(iPhoneSize: 0, iPadSize: -140))
                                }
                                
                            }
                            .simultaneousGesture(DragGesture(minimumDistance: 10)
                                                    .onChanged({value in
                                if value.translation.height > 0 {
                                    //down
                                    withAnimation{
                                        appState.showRoomSelector = true
                                    }
                                }
                            })
                            )
                            
                            if currentDeviceIsPhone(){
                                ScrollView(.horizontal, showsIndicators: false){
                                    AccessoryOverview()
                                        .padding([.leading])
                                }
                                .offset(y: updater.status.morning.showMorning ? 0 : -30)
                            }else{
                                HStack{
                                    Spacer()
                                    
                                    AccessoryOverview()
                                    Spacer()
                                }
                                .offset(y: updater.status.morning.showMorning ? 0 : -140)
                            }
                            Spacer()
                            VStack(alignment: .leading){
                                Todos()
                                OverviewDivider(title: "Power", icon: "gridIcon")
                                PowerOverview(screenWidth: proxy.size.width)
                                
                                OverviewDivider(title: "Weather", icon: "weather")
                                WeatherOverview(weather: $updater.status.weather)
                                
                                OverviewDivider(title: "Laundry", icon: "laundry")
                                LaundryOverview()
                                Button(action: {showIrrigation.toggle()}){
                                    OverviewDivider(title: "Irrigation", icon: "irrigation")
                                }
                                IrrigationOverview(showDetail: $showIrrigation)
                            }.padding()
                        }
                        
                    }
                }
                if appState.showRoomSelector{
                    VStack{
                        RoomSnapper()
                    }
                    .transition(.move(edge: .top))
                }
                
            }
            .onOpenURL(perform: {url in
                parseTag(url: url)
                guard let room = updater.status.rooms.first(where: {$0.id == detectedRoomId})else{
                    return
                }
                self.room = room
                appState.activeRoom = room
            })
            .onChange(of: updater.lastUpdated, perform: {_ in
                if roomDetected{
                    guard let room = updater.status.rooms.first(where: {$0.id == detectedRoomId})else{
                        guard let Room = updater.status.rooms.first else{return}
                        appState.activeRoom = Room
                        return
                    }
                    self.room = room
                    appState.activeRoom = room
                    roomDetected = false
                }else if appState.activeRoom.id == 0{
                    guard let Room = updater.status.rooms.first else{return}
                    appState.activeRoom = Room
                }
            })
            .sheet(isPresented: $showDogMode){
                DogModeOverview()
            }
            .sheet(isPresented: $showIrrigation){
                IrrigationView()
            }
            .sheet(isPresented: $leave){
                LeaveStart()
            }
            .sheet(isPresented: $showNight){
                WakeUpSetup(active: $showNight)
                
            }
            .sheet(isPresented: $notifications){
                NotificationList()
                    .background(Color.clear)
            }
            .sheet(isPresented: $showErrorPage){
                ErrorView()
            }
            .sheet(isPresented: $showPowerPage){
                PowerDetail()
            }
            .sheet(isPresented: $showSentry){
                SentryView()
            }
        }
    }
}
