//
//  SceneSelectAccessories.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI

struct SceneSelectAccessories: View {
    @Binding var scene: SceneAutomation
    @Binding var step: Int
    @EnvironmentObject var updater: Updater
    @State var rooms: [Room] = [Room]()
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func setup(){
        rooms = updater.status.rooms
    }
    func toggleLight(light: Light){
        if scene.lights.contains(where: {$0.id == light.id}){
            //remove
            scene.lights.removeAll(where: {$0.id == light.id})
        }else{
            //add
            scene.lights.insert(light, at: 0)
        }
    }
    func toggleBlind(blind: Blind){
        if scene.blinds.contains(where: {$0.id == blind.id}){
            //remove
            scene.blinds.removeAll(where: {$0.id == blind.id})
        }else{
            //add
            scene.blinds.insert(blind, at: 0)
        }
    }
    func toggleTado(tado: TempDevice){
        if scene.tado.contains(where: {$0.id == tado.id}){
            //remove
            scene.tado.removeAll(where: {$0.id == tado.id})
        }else{
            //add
            scene.tado.insert(tado, at: 0)
        }
    }

    func tap(){
        print("tapped")
    }
    var accessories: some View{
        ForEach(rooms){room in
            VStack(alignment: .leading){
                Text(room.name.uppercased())
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
        
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(room.lights){light in
                        DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", selected: scene.lights.contains(where: {$0.id == light.id}), onLongPress: {toggleLight(light: light)}, onTap: {toggleLight(light: light)})
                    }
                    ForEach(room.blinds){blind in
                        DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))% Open", name: blind.name, active: blind.position != 0, offStatus: "Closed", selected: scene.blinds.contains(where: {$0.id == blind.id}), onLongPress: {toggleBlind(blind: blind)}, onTap: {toggleBlind(blind: blind)})
                        .id(UUID())
                    }
                    ForEach(room.tempDevices){tado in
                        DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(format: "%.1f", tado.setTemp) )°C", name: tado.name, active: true, offStatus: "Off", selected: scene.tado.contains(where: {$0.id == tado.id}), onLongPress: {toggleTado(tado: tado)}, onTap: {toggleTado(tado: tado)})
                        .id(UUID())
                    }
                }
            }.padding(.bottom)
        }
    }
    var body: some View{
        ScrollView{
            VStack{
                accessories
            }
        }
        .onAppear(perform: setup)
    }
}

//struct SceneSelectAccessories_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneSelectAccessories()
//    }
//}

