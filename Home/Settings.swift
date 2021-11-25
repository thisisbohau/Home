//
//  Settings.swift
//  Home
//
//  Created by David Bohaumilitzky on 20.06.21.
//

import SwiftUI
import CoreLocation
struct Settings: View {
    @StateObject var location = LocationManager()

    @State var monitoringRadius: CGFloat = 200
    @EnvironmentObject var updater: Updater
    
    @State var roomTag: Bool = false
    
    func setLockdownScene(id: Int){
        SwitchKit().setInt(id: 18747, newValue: id)
    }
    var body: some View {
        NavigationView{
            Form{
                GeofenceSettings()
                Section(header: Text("Room Tags"), footer: Text("Quickly access room specific controls by holding your device near the light switch")){
                    Button(action: {
                        roomTag.toggle()
                    }){
                        Text("Program Tag")
                    }

                }
                Section(header: Text("Lockdown Scene"), footer: Text("This scene will run anytime lockdown is activated. Blinds will be closed automatically on activation.")){
                    Menu(content: {
                        ForEach(updater.status.scenes){scene in
                            Button(action: {setLockdownScene(id: scene.id)}){
                                Text(scene.name)
                            }
                        }
                    }, label: {
                        Text("Select Scene")
                    })
                }
                
//                Section("Geofence"){
                
                Credentials()
                CalendarSettings()
                Section("JSON Response templates"){
                    Button(action: Updater().printHomeStruct){
                        Text("Print structure Template")
                    }
                }
//                    Picker("Monitoring Radius", selection: $monitoringRadius){
//                        Text("200m").tag(200)
//                        Text("300m").tag(300)
//                        Text("500m").tag(500)
//                        Text("1000m").tag(1000)
//                    }
                    
//                    Button(action: {
//                        GeoKit().setHomeCoordinates(location: location.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 200, longitude: 200), radius: Double(monitoringRadius))
//                        location.startMonitoring()
//                    }){
//                        Text("Set current location as Home")
//                            .padding()
//                    }
//                    Button(action: {GeoKit().pushHomeStatus(status: true)}){
//                        Text("Test Entry")
//                            .padding()
//                            .foregroundColor(.orange)
//                    }
//                    Button(action: {GeoKit().pushHomeStatus(status: false)}){
//                        Text("Test Exit")
//                            .padding()
//                            .foregroundColor(.orange)
//                    }
//                    Button(action: {GeoKit().pushLocationUnchecked(location: location.lastLocation!)}){
//                        Text("Push currentLocation")
//                            .padding()
//                            .foregroundColor(.orange)
//                    }
//                }
                


                .sheet(isPresented: $roomTag){
                    RoomTagSetup()
                }
            }.navigationTitle("Settings")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
