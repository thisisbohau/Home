//
//  LocationSettings.swift
//  Home
//
//  Created by David Bohaumilitzky on 28.12.21.
//

import SwiftUI
import MapKit
import UIKit

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

struct LocationSettings: View {
    @EnvironmentObject var updater: UpdateManager
    @StateObject var locationManager = LocationManager()
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1, longitude: 1), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
    @State var homeGeofence: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10, longitude: 10)
    @State var regionCircle: CGFloat = 30
    @State var rect: MKMapRect = MKMapRect(x: 0, y: 0, width: 200, height: 200)
    
    func setNewHomeCoordinates(){
        LocationControl().setHomeGeofence(coordinate: locationManager.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 10, longitude: 10), radius: 300)
        setup()
    }
    func setup(){
        DispatchQueue.main.async {
            homeGeofence = LocationControl().getHomeGeofence().center
            region.center = locationManager.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
    }
    var body: some View {
        VStack{
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [homeGeofence]){
                MapAnnotation(coordinate: $0){
                    
                    Image("homeIcon").foregroundColor(.white)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().foregroundColor(Color("fill")))
                }
                
            }
        }
        .overlay{
            VStack{
                HStack{
                    Text("Geofence")
                        .font(.title.bold())
                        .padding()
                    Spacer()
                }
                Spacer()
                Button(action: setNewHomeCoordinates){
                    HStack{
                        Spacer()
                        Text("Set location as Home")
                        Spacer()
                    }.padding().background(.regularMaterial)
                }
            }
        }
        .onChange(of: locationManager.lastLocation, perform: {_ in setup()})
        .onAppear(perform: setup)
//        .ignoresSafeArea()
//        .frame(width: 500, height: 500, alignment: .center)
    }
}

struct LocationSettings_Previews: PreviewProvider {
    static var previews: some View {
        LocationSettings()
    }
}
