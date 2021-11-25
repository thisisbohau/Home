//
//  ContentView.swift
//  Home
//
//  Created by David Bohaumilitzky on 23.04.21.
//

import SwiftUI

//class : ObservableObject{
//    @Published var result: String = ""
//    var timerLoop = Timer()
//
//    func startTimer(){
//        timerLoop = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getWebhook), userInfo: nil, repeats: true)
//    }
//
//    @objc func getWebhook(){
//        makeRequest(directory: directories.light, queries: [URLQueryItem(name: "id", value: "someID")])
//        let url = URL(string: "http://192.168.100.95:3777/hook/home/light?id=30934&status=true")!
//
//        let task = URLSession.shared.dataTask(with: url){data, response, error in
//            //print(data)
//            DispatchQueue.main.async {
//                self.result = String(data: data!, encoding: .utf8) ?? ""
//            }
//            if let error = error{
//                print(error.localizedDescription)
//            }
//
//        }
//        task.resume()
//    }
//}
class AppState: ObservableObject{
    @Published var activeRoom: Room = testRoom
    @Published var openRoom: Bool = false
    @Published var activeTab: Int = 1
    @Published var showRoomSelector: Bool = false
    
    func lightTagReceived(roomId: Int, rooms: [Room]){
        let room = rooms.first(where: {$0.id == roomId})
        openRoom = false
        activeRoom = room ?? Room(id: roomId, name: "Updating...", floor: 0, lights: [Light](), blinds: [Blind](), tempDevices: [TempDevice](), type: RoomType(icon: "", color: "ff9790"), occupied: false, lastOccupied: "", openWindow: false, windows: [WindowSensor]())
        openRoom = true
    }
    
}
//struct ContentView: View {
//    @StateObject var locationManager = LocationManager()
//    @EnvironmentObject var sceneKit: SceneKit
//    @EnvironmentObject var updater: Updater
//    @EnvironmentObject var appState: AppState
//    @StateObject var nfcReader = NFCReader()
//
//    func selectRoom(room: Room){
//        appState.activeRoom = room
//        appState.activeTab = 4
//    }
//    
//    var body: some View{
//        ZStack{
//        
//            if UIDevice.current.userInterfaceIdiom == .phone{
//                TabView(){
//                    HomeView()
//                        .tag(1)
//                        .tabItem {
//                            Label("Home", systemImage: "house.fill")
//                        }
//                    Rooms()
//                        .tag(2)
//                        .tabItem {
//                            Label("Rooms", systemImage: "square.split.bottomrightquarter")
//                        }
//                    SceneList()
//                        .tag(3)
//                        .tabItem {
//                            Label("Actions", systemImage: "camera.filters")
//                        }
//                    Settings()
//                        .tag(4)
//                        .tabItem {
//                            Label("Settings", systemImage: "gearshape.2")
//                        }
//
//                }
//                .onAppear(perform: {updater.startUpdateLoop()})
//                
//            }else{
//                NavigationView{
////                    HStack{
////                        NavigationLink(destination: RoomView(room: $appState.activeRoom), isActive: $appState.openRoom){
////                            EmptyView()
////                        }
////                    }
//                    ZStack{
//                        Color(uiColor: .systemBackground)
//                           
//                        ScrollView{
//    //                        Text(appState.activeTab.debugDescription).modifier(ListBoxItem())
//                               NavigationLink(destination: HomeView(), tag: 1, selection: $appState.activeTab){
//                                   HStack{
//                                       Label("Home", systemImage: "house.fill")
//                                           .foregroundStyle(.primary)
//    //                                       .foregroundColor(.white)
//    //                                       .foregroundColor(appState.activeTab == 1 ? .white : .clear)
//                                          
//                                       Spacer()
//                                   }
//                                   
//                               }.modifier(ListBoxItem(isSelected: appState.activeTab == 1))
//                               
//           
//                               NavigationLink(destination: SceneList(), tag: 2, selection: $appState.activeTab){
//                                   HStack{
//                                       Label("Actions", systemImage: "camera.filters")
//                                           .foregroundStyle(.primary)
//                                           
//                                       Spacer()
//                                   }
//                               }.modifier(ListBoxItem(isSelected: appState.activeTab == 2))
//                               NavigationLink(destination: Settings(), tag: 3, selection: $appState.activeTab){
//                                   HStack{
//                                       Label("Settings", systemImage: "gearshape.2")
//                                           .foregroundStyle(.primary)
//    //                                       .foregroundColor(.white)
//                                       Spacer()
//                                   }
//                               }.modifier(ListBoxItem(isSelected: appState.activeTab == 3))
//    //                           Divider()
//                               NavigationLink(destination: RoomView(room: $appState.activeRoom), tag: 4, selection: $appState.activeTab){
//                                   HStack{
//                                       Text("Rooms").font(.title.bold()).foregroundColor(.primary)
//                                       Spacer()
//                                   }.padding([.top, .leading])
//                               }
//                               ForEach(updater.status.rooms){room in
//           
//                                   Button(action: {selectRoom(room: room)}){
//                                       HStack{
//                                           Label(room.name, systemImage: room.type.icon)
//                                               .foregroundStyle(.primary)
//    //                                           .foregroundColor(.white)
//                                           Spacer()
//                                       }
//                                   }.modifier(ListBoxItem(isSelected: appState.activeRoom.id == room.id))
//                               }
//                               
//                           }.navigationTitle("Home")
//                   
//                    }
//                }
//                    .onAppear(perform: {updater.startUpdateLoop()})
//                    .sheet(isPresented: $appState.openRoom){
//                        RoomView(room: $appState.activeRoom)
//                    }
//            }
//            if sceneKit.settingScene{
//                VStack{
//                    Spacer()
//                    HStack{
//                        Spacer()
//                    }
//                }.background(.ultraThinMaterial).opacity(0.3).ignoresSafeArea()
//                VStack{
//                    Spacer()
//                    VStack{
//                        HStack{
//                            Spacer()
//                            Text("Setting Scene")
//                                .font(.largeTitle.bold())
//                                .padding(.top)
//                                .foregroundStyle(.primary)
//                                .colorScheme(.light)
//                            Spacer()
//                            
//                        }.padding()
//                        Spacer()
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .font(.largeTitle)
//                            .foregroundColor(.secondary)
//                            .scaleEffect(1.5)
//                            .colorScheme(.light)
//                        Spacer()
//                        Text("Home is adjusting devices.")
//                            .bold()
//                            .foregroundStyle(.secondary)
//                            .padding()
//                            .padding(.bottom)
//                            .colorScheme(.light)
//                    }
//                    .ignoresSafeArea()
//                    .aspectRatio(1, contentMode: .fit)
//                    .background(.white)
//                    .cornerRadius(35)
//                    .padding(5)
//                    
//                }.transition(.move(edge: .bottom))
//            }
////            Text(locationManager.lastLocation.debugDescription)
////            Text(locati xonManager.statusString)
////            Button(action: {nfcReader.startScanning()}){
////                Text("Scan RoomTag")
////            }
//        }
//        .sheet(isPresented: $appState.openRoom){
//            NavigationView{
////                Text("Room received")
//                RoomView(room: $appState.activeRoom)
//            }.navigationTitle(appState.activeRoom.name)
//                .navigationViewStyle(StackNavigationViewStyle())
//            
//        }
//    }
//    
//    
//
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
