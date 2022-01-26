//
//  SceneList.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import SwiftUI

struct SceneList: View {
    @EnvironmentObject var updater: UpdateManager
    @EnvironmentObject var sceneKit: SceneKit
    
    
    @State var showDeleteAlert: Bool = false
    @State var sceneList: [SceneList] = [SceneList]()
    @State var createScene: Bool = false
    @State var selectedScene: SceneAutomation = SceneAutomation(id: 0, name: "", lights: [Light](), blinds: [Blind](), tado: [TempDevice](), active: false, schedule: nil, room: nil, icon: nil)
    @State var editScene: Bool = false
    
    func edit(scene: SceneAutomation){
        selectedScene = scene
        editScene = true
    }
    func delete(scene: SceneAutomation){
        selectedScene = scene
        showDeleteAlert.toggle()
    }
    struct SceneList: Identifiable{
        var id: UUID
        var room: Room
        var scenes: [SceneAutomation]
    }
    
    func setScene(scene: SceneAutomation) {
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
        VStack{
            VStack(alignment: .leading){
                Text("Automations")
                    .font(.title.bold())
                ForEach(updater.status.scenes.filter({$0.schedule?.count ?? 0 > 0})){scene in
                    SceneControl(scene: scene, onTap: {setScene(scene: scene)})
                        .contextMenu(menuItems: {
                            Button(action: {edit(scene: scene)}){Text("Edit")}
                            Button(action: {delete(scene: scene)}){Text("Delete").foregroundColor(.pink)}
                        })
                }
            }
            
            VStack(alignment: .leading){
                Text("Scenes")
                    .font(.title.bold())
                ForEach(updater.status.scenes.filter({$0.schedule?.count ?? 0 == 0})){scene in
                    SceneControl(scene: scene, onTap: {setScene(scene: scene)})
                        .contextMenu(menuItems: {
                            Button(action: {edit(scene: scene)}){Text("Edit")}
                            Button(action: {delete(scene: scene)}){Text("Delete").foregroundColor(.pink)}
                        })
                }
            }
        }
        .alert("Delete Scene?\n This action cannot be undone", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {SceneKit().deleteScene(scene: selectedScene)}
        }

//        ForEach(sceneList){room in
//            VStack(alignment: .leading){
//                Text(room.room.name.uppercased())
//                    .font(.title3.bold())
//                    .foregroundStyle(.secondary)
//
//                ScrollView(.horizontal, showsIndicators: false){
//                    HStack{
//                        ForEach(room.scenes){scene in
//                            SceneControl(scene: scene, onTap: {setScene(scene: scene)})
//                                .contextMenu(menuItems: {
//                                    Button(action: {edit(scene: scene)}){Text("Edit")}
//                                    Button(action: {delete(scene: scene)}){Text("Delete").foregroundColor(.pink)}
//                                })
//
//                                .padding(.trailing, 5)
//                        }
//                    }
//                }
//            }.padding(.bottom)
//                .alert("Delete Scene?\n This action cannot be undone", isPresented: $showDeleteAlert) {
//                    Button("Cancel", role: .cancel) {}
//                    Button("Delete", role: .destructive) {SceneKit().deleteScene(scene: selectedScene)}
//                        }
//        }
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color("background").ignoresSafeArea()
                ScrollView{
                    list
                }.padding()
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
    }
}

struct SceneList_Previews: PreviewProvider {
    static var previews: some View {
        SceneList()
    }
}
