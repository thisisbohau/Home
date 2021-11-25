//
//  SceneList.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import SwiftUI

struct SceneList: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var sceneKit: SceneKit
    
    @State var sceneList: [SceneList] = [SceneList]()
    @State var createScene: Bool = false
//    @State var running: Bool = false
    @State var selectedScene: SceneAutomation = SceneAutomation(id: 0, name: "", lights: [Light](), blinds: [Blind](), tado: [TempDevice](), active: false, schedule: nil, room: nil, icon: nil)
    @State var editScene: Bool = false
    
    func edit(scene: SceneAutomation){
        selectedScene = scene
        editScene = true
    }
    struct SceneList: Identifiable{
        var id: UUID
        var room: Room
        var scenes: [SceneAutomation]
    }
    
    func setScene(scene: SceneAutomation){
//        withAnimation(.linear, {running = true})
        sceneKit.setScene(scene: scene)
            
        
    }
    
    func setup(){
        var Scenes = [SceneList]()
        let rooms = updater.status.rooms
        let scenes = updater.status.scenes
        
        for room in rooms{
            let matching = scenes.filter({$0.room == room.id})
            if !matching.isEmpty{
                Scenes.append(SceneList(id: UUID(), room: room, scenes: matching))
            }
           
        }
        let noRoom = scenes.filter({$0.room == nil})
        if !noRoom.isEmpty{
            Scenes.insert(SceneList(id: UUID(), room: Room(id: 0, name: "Universial", floor: 0, lights: [Light](), blinds: [Blind](), tempDevices: [TempDevice](), type: RoomType(icon: "", color: ""), occupied: false, lastOccupied: "", openWindow: false, windows: [WindowSensor]()), scenes: noRoom), at: 0)
        }
        if Scenes.compactMap({$0.id}) != sceneList.compactMap({$0.id}){
            sceneList = Scenes
        }
       
    }
    
    var list: some View{
        ForEach(sceneList){room in
            VStack(alignment: .leading){
                Text(room.room.name.uppercased())
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
            
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(room.scenes){scene in
                            SceneControl(scene: scene, onTap: {setScene(scene: scene)})
                                .contextMenu(menuItems: {
                                    Button(action: {edit(scene: scene)}){Text("Edit")}
                                })
//                            QuickActionControl(title: scene.name, description: "", icon: scene.icon ?? "heart.fill", color: .indigo, onLongPress: {edit(scene: scene)}, onTap: {setScene(scene: scene)}, time: "")
                                .padding(.trailing, 5)
                        }
                    }
                }
            }.padding(.bottom)
        }
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color("background").ignoresSafeArea()
                ScrollView{
//                    Button(action: {
//                        withAnimation(.linear){
//                            running.toggle()
//                        }
//                        
//                        
//                    }){
//                        Text("Run")
//                    }
                    list
                }.padding()
//                if running{
//                    VStack{
//                        Spacer()
//                        HStack{
//                            Spacer()
//                        }
//                    }.background(.ultraThinMaterial).opacity(0.3).ignoresSafeArea()
//                    VStack{
//                        Spacer()
//                        VStack{
//                            HStack{
//                                Spacer()
//                                Text("Setting Scene")
//                                    .font(.largeTitle.bold())
//                                    .padding(.top)
//                                    .foregroundStyle(.primary)
//                                    .colorScheme(.light)
//                                Spacer()
//
//                            }.padding()
//                            Spacer()
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                                .font(.largeTitle)
//                                .foregroundColor(.secondary)
//                                .scaleEffect(1.5)
//                                .colorScheme(.light)
//                            Spacer()
//                            Text("Home is adjusting devices.")
//                                .bold()
//                                .foregroundStyle(.secondary)
//                                .padding()
//                                .padding(.bottom)
//                                .colorScheme(.light)
//                        }
//                        .ignoresSafeArea()
//                        .aspectRatio(1, contentMode: .fit)
//                        .background(.white)
//                        .cornerRadius(35)
//                        .padding(5)
//
//                    }.transition(.move(edge: .bottom))
//                }
                
            }
            .fullScreenCover(isPresented: $createScene){
                NewScene(active: $createScene)
            }
            .fullScreenCover(isPresented: $editScene){
                SceneEditScene(active: $editScene, scene: $selectedScene)
            }
            .navigationBarItems(trailing:
                Button(action: {createScene.toggle()}){
                    Text("New")
                    .bold()
                }
            )
            .navigationTitle("Scenes")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setup)
//        .onChange(of: updater.lastUpdated, perform: {value in setup()})
 

    }
}

struct SceneList_Previews: PreviewProvider {
    static var previews: some View {
        SceneList()
    }
}
