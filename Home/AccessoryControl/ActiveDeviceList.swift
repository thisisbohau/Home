//
//  ActiveDeviceList.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import SwiftUI
import Firebase
struct ActiveDeviceList: View {
    @EnvironmentObject var updater: Updater
    @State var activeLights: [Light] = [Light]()
    @State var openBlinds: [Blind] = [Blind]()
    @State var manualDevices: [TempDevice] = [TempDevice]()
    
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
    
    func setup(){
        let rooms = updater.status.rooms
        
        let lights = rooms.flatMap({$0.lights})
        activeLights = lights.filter({$0.state})
        
        let blinds = rooms.flatMap({$0.blinds})
        openBlinds = blinds
        
        let tado = rooms.flatMap({$0.tempDevices})
        manualDevices = tado.filter({$0.manualMode == true})
    }
    
    var body: some View{
        NavigationView{
  
            
        main
            .padding([.leading, .trailing, .bottom])
            .navigationTitle("Accessories")
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
    }
    var main: some View {
        ScrollView{
            VStack(alignment: .leading){
                VStack(alignment: .leading){
                    Text("\(activeLights.count) LIGHTS")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                        ForEach(activeLights){light in
                            DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {editLight(light: light)}, onTap: {})
                        }
                    }
                } .padding(.bottom)
                
                VStack(alignment: .leading){
                    Text("\(openBlinds.count) BLINDS")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                        ForEach(openBlinds){blind in
                            DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))% Open", name: blind.name, active: blind.position != 0, offStatus: "Closed", onLongPress: {editBlind(blind: blind)}, onTap: {})
                            .id(UUID())
                        }
                    }
                } .padding(.bottom)
                
                
                VStack(alignment: .leading){
                    Text("\(String(updater.status.rooms.flatMap({$0.windows}).filter({$0.state == true}).count)) WINDOWS")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                        ForEach(updater.status.rooms.flatMap({$0.windows}).filter({$0.state == true})){window in
                            DeviceControl(type: .Window, status: window.state ? "Open" : "Closed", name: window.name, active: window.state, offStatus: "Closed", onLongPress: {}, onTap: {})
                            .id(UUID())
                        }
                    }
                } .padding(.bottom)
                
                VStack(alignment: .leading){
                    Text("\(manualDevices.count) ACs")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                        ForEach(manualDevices){tado in
                            DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(format: "%.1f", tado.setTemp) )°", name: tado.name, active: true, offStatus: "Off", onLongPress: {editTado(tado: tado)}, onTap: {})
                            .id(UUID())
                        }
                    }
                } .padding(.bottom)
        }.onAppear(perform: setup)
        .onChange(of: updater.lastUpdated, perform: {value in setup()})
    }
    }
}

struct ActiveDeviceList_Previews: PreviewProvider {
    static var previews: some View {
        ActiveDeviceList()
    }
}
