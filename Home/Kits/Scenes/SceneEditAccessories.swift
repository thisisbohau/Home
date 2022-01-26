//
//  SceneEditAccessories.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI

struct SceneEditAccessories: View {
    @EnvironmentObject var updater: UpdateManager
    @Binding var scene: SceneAutomation
    @Binding var step: Int
    
    @State var selectedLight: Light = Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    @State var editLight: Bool = false
    
    @State var selectedBlind: Blind = Blind(id: "", name: "", position: 0, moving: false)
    @State var editBlind: Bool = false
    
    @State var selectedTado: TempDevice = TempDevice(id: "", isAC: false, name: "", manualMode: false, active: false, openWindow: false, temp: 0, setTemp: 0, humidity: 0, performance: 0)
    @State var editTado: Bool = false
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func editLight(light: Light){
        selectedLight = light
        editLight = true
    }
    func editBlind(blind: Blind){
        selectedBlind = blind
        editBlind = true
    }
    func editTado(tado: TempDevice){
        selectedTado = tado
        editTado = true
    }
    
    func update(){
        var lights = updater.status.rooms.flatMap({$0.lights})
        var blinds = updater.status.rooms.flatMap({$0.blinds})
        var tado = updater.status.rooms.flatMap({$0.tempDevices})
        
        lights.removeAll(where: {scene.lights.compactMap({$0.id}).contains($0.id) == false})
        blinds.removeAll(where: {scene.blinds.compactMap({$0.id}).contains($0.id) == false})
        tado.removeAll(where: {scene.tado.compactMap({$0.id}).contains($0.id) == false})
        
        scene.lights = lights
        scene.blinds = blinds
        scene.tado = tado
        print("Updated \(scene.lights.debugDescription)")
    }
    var body: some View {
            ScrollView{
                VStack(alignment: .leading){
                    Text("These settings cannot be changed after the scene has been created")
                        .foregroundStyle(.primary)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading){
                        Text("\(scene.lights.count) LIGHTS")
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                            ForEach(scene.lights){light in
                                DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {editLight(light: light)}, onTap: {})
                            }
                        }
                    } .padding(.bottom)
                    
                    VStack(alignment: .leading){
                        Text("\(scene.blinds.count) BLINDS")
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                            ForEach(scene.blinds){blind in
                                DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))% Open", name: blind.name, active: blind.position != 0, offStatus: "Closed", onLongPress: {editBlind(blind: blind)}, onTap: {})
                                .id(UUID())
                            }
                        }
                    } .padding(.bottom)
                    
                    VStack(alignment: .leading){
                        Text("\(scene.tado.count) ACs")
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                            ForEach(scene.tado){tado in
                                DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(format: "%.1f", tado.setTemp) )°C", name: tado.name, active: true, offStatus: "Off", onLongPress: {editTado(tado: tado)}, onTap: {})
                                .id(UUID())
                            }
                        }
                    } .padding(.bottom)
                }
                .sheet(isPresented: $editLight){
                    LightControl(light: $selectedLight)
                }
                .sheet(isPresented: $editBlind){
                   BlindControl(blind: $selectedBlind)
                }
                .sheet(isPresented: $editTado){
                    TadoControl(device: $selectedTado)
                }
        }
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
    }
}

//struct SceneEditAccessories_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneEditAccessories()
//    }
//}
