//
//  GeofenceSettings.swift
//  Home
//
//  Created by David Bohaumilitzky on 29.07.21.
//

import SwiftUI
import MapKit

//struct GeofenceSettings: View {
//    @StateObject var locationManager = LocationManager()
//    
//    @State var location = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 2, longitude: 2), latitudinalMeters: 0.0002, longitudinalMeters: 0.0002)
//    @State var newGeofence: Bool = false
//    @State var radius: Int = 200
//    @State var mode = MapUserTrackingMode.follow
//    
//    func setGeoFence(radius: Int){
//        guard let currentLocation = locationManager.lastLocation else{return}
//        
//        GeoKit().setHomeCoordinates(location: currentLocation.coordinate, radius: Double(radius))
//    }
//    func setup(){
//        
//        location.center = locationManager.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 2, longitude: 2)
//        location.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//    }
//    
//    var newGeo: some View{
//        GeometryReader{proxy in
//            ZStack{
////                Map(coordinateRegion: $location, showsUserLocation: true)
//                Map(coordinateRegion: $location, interactionModes: .all, showsUserLocation: true, userTrackingMode: $mode)
////                    .frame(height: 300)
//                    .frame(width: sizeOptimizer(iPhoneSize: proxy.size.width, iPadSize: proxy.size.width), height: sizeOptimizer(iPhoneSize: proxy.size.height, iPadSize: proxy.size.height))
//                    .ignoresSafeArea(.all)
//                    .onAppear(perform: setup)
//             
//                VStack{
//                    Spacer()
//                    HStack{
//                        Stepper("Radius", value: $radius, step: 100)
//                        Spacer()
//                        Button(action: {setGeoFence(radius: radius)}){
//                            Text("Set")
//                                .padding(8)
//                                .padding([.leading, .trailing], 10)
//                                .background(Color("background"))
//                                .cornerRadius(30)
//                                .foregroundColor(Color("secondary"))
//                        }
//                    }
//                    .padding()
//                    .background(.regularMaterial)
//                }
//                
//                VStack{
//                    HStack{
//                        Button(action: {newGeofence.toggle()}){
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.title)
//                                .foregroundColor(.secondary)
//                                
//                        }
//                        Spacer()
//                        Text("\(radius)m")
//                            .font(.title.bold())
//                    }.padding()
//                    Spacer()
//                }
//            }
//            
//        }
//    }
//    var body: some View {
//        Section(header: Text("Geofence"), footer: Text("Home uses your location to control automations, notifications and other features. We may use your location even when the app is not running.")){
//            Map(coordinateRegion: $location, showsUserLocation: true)
//                .scaledToFit()
//                .frame(maxHeight: 500)
//                .ignoresSafeArea()
//                .cornerRadius(13)
//                .onAppear(perform: setup)
//                .onChange(of: locationManager.lastLocation, perform: {_ in setup()})
//            Button(action: {newGeofence.toggle()}){
//                Text("Update Geofence")
//            }
//            
//            Menu("Advanced", content: {
//                Button(action: {GeoKit().pushLocationUnchecked(location: locationManager.lastLocation ?? CLLocation(latitude: 0, longitude: 0))}){
//                    Text("Push Location")
//                }
//            })
//            
//        }
//        .sheet(isPresented: $newGeofence){
//            newGeo
//        }
//    }
//}

struct GeofenceSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeofenceSettings()
    }
}
