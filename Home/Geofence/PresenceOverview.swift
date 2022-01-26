//
//  PresenceOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 01.08.21.
//

import SwiftUI
import MapKit

struct PresenceOverview: View {
    var proxy: CGSize
    @EnvironmentObject var updater: Updater
    @State var points: [Person] = [Person]()
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20, longitude: 20), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
    
    func getCoordinates(person: Person) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(person.lat), longitude: CLLocationDegrees(person.lon))
    }
    func setup(){
        guard let first = updater.status.geofence.people.first else{return}
        region.center = CLLocationCoordinate2D(latitude: CLLocationDegrees(first.lat), longitude: CLLocationDegrees(first.lon))
    }
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: false,  annotationItems: updater.status.geofence.people) {annotation in
                    MapAnnotation(coordinate: getCoordinates(person: annotation), content: {
//                        Text(annotation.lat.description)
                        Image(annotation.id)
                            .resizable()
                            .frame(width: 60, height: 60)
                        
                    })
                    
                }.frame(width: proxy.width*0.9, height: proxy.width*0.5,alignment: .center)
                    .cornerRadius(13)
                Spacer()
            }
        
                
        }
        
        .padding()
        .onAppear(perform: setup)
        .onChange(of: updater.lastUpdated, perform: {_ in setup()})
    }
}

//struct PresenceOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        PresenceOverview()
//    }
//}
