//
//  AccessoryOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import SwiftUI

struct AccessoryOverview: View {
    @EnvironmentObject var update: UpdateManager
    @State var activeLights: Int = 0
    @State var openBlinds: Int = 0
    @State var averageTemp: Float = 0.0
    
    @State var showWeatherAdaption: Bool = false
    @State var showDetail: Bool = false
    @State var showGarageControl: Bool = false
    @State var showNukiControl: Bool = false
    @State var showLightDetail: Bool = false
    @State var showBlindDetail: Bool = false
    @State var showTadoDetail: Bool = false
    @State var showLaundry: Bool = false
    
    func setup(){
        let rooms = update.status.rooms
        let lights = rooms.flatMap({$0.lights})
        activeLights = lights.filter({$0.state}).count
        
        let blinds = rooms.flatMap({$0.blinds})
        openBlinds = blinds.filter({$0.position > 90}).count
        
        let tado = rooms.flatMap({$0.tempDevices})
        averageTemp = Float(tado.compactMap({$0.temp}).reduce(0, +)/Float(tado.count))
    }

    var body: some View {
        HStack{
            StatusItem(active: update.status.nuki.state, onDescription: "Nuki\nUnlocked", offDescription: "Nuki\nLocked", icon: AnyView(
                Image(systemName: update.status.nuki.state ? "lock.open.fill" : "lock.fill")
                    .font(.title2).foregroundStyle(update.status.nuki.state ? .orange : .secondary)), onTap: {showNukiControl.toggle()}, useFill: true)
            StatusItem(active: activeLights != 0, onDescription: activeLights == 1 ? "\(activeLights) Light\nOn" : "\(activeLights) Lights\nOn", offDescription: "Lights\nOff", icon: getDeviceIcon(type: .LightBulbMono, state: activeLights != 0, accent: .yellow), onTap: {showLightDetail.toggle()}, useFill: true)
            
            StatusItem(active: openBlinds != 0, onDescription: openBlinds == 1 ? "\(openBlinds) Blinds\nOpen" : "\(openBlinds) Blind\nOpen", offDescription: "Blinds\nClosed", icon: getDeviceIcon(type: .Blind, state: openBlinds != 0, accent: .teal), onTap: {showBlindDetail.toggle()}, useFill: true)
            
            StatusItem(active: true, onDescription: "\(String(format: "%.1f", averageTemp))°C\n Average", offDescription: "\(String(format: "%.1f", averageTemp))°C\n Average", icon: AnyView(
                Text("\(Int(averageTemp.isNaN ? 0 : averageTemp).description)°")
                    .foregroundColor(TadoKit().getTempColor(temp: averageTemp))
            ), onTap: {showTadoDetail.toggle()}, useFill: true)
            
            StatusItem(active: true, onDescription: "Device\nSummary", offDescription: "Device\nSummary", icon: getDeviceIcon(type: .Summary, state: true, accent: .yellow), onTap: {showDetail.toggle()}, useFill: true)
            
            StatusItem(active: update.status.garage.state, onDescription: "Garage\nOpen", offDescription: "Garage\nClosed", icon: AnyView(
                Image(systemName: "rectangle")
                    .font(.title2)
                    .foregroundColor(update.status.garage.state ? .blue : .secondary)
            ), onTap: {showGarageControl.toggle()}, useFill: true)
            
            StatusItem(active: update.status.weather.weatherAdaption.state, onDescription: "Weather\nAdaption", offDescription: "Adaption\nOff", icon: AnyView(
                
                Image(systemName: WeatherKit().getWeatherIcon(condition: update.status.weather.condition))
                    .font(.title2)
                    .foregroundColor(update.status.weather.weatherAdaption.state ? .teal : .secondary)
            ), onTap: {showWeatherAdaption.toggle()}, useFill: true)
            
            
        }
        .padding(.leading, sizeOptimizer(iPhoneSize: 20, iPadSize: 0))
        .shadow(radius: 3)
        .onAppear(perform: setup)
        .onChange(of: update.lastUpdated, perform: {value in setup()})
        .sheet(isPresented: $showDetail){
            ActiveDeviceList()
        }
        .sheet(isPresented: $showLaundry){
            LaundryView()
        }
        .sheet(isPresented: $showTadoDetail){
            AccessoryDetailAvgTemp()
        }
        .sheet(isPresented: $showBlindDetail){
            AccessoryDetailBlinds()
        }
        .sheet(isPresented: $showLightDetail){
            AccessoryDetailLights()
        }
        .sheet(isPresented: $showWeatherAdaption){
            WeatherAdaption()
        }
        .sheet(isPresented: $showGarageControl){
            GarageControl()
        }
        .sheet(isPresented: $showNukiControl){
            NukiControl()
        }
    }
}

struct AccessoryOverview_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryOverview()
    }
}
