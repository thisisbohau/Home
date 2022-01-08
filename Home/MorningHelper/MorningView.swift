//
//  MorningView.swift
//  Home
//
//  Created by David Bohaumilitzky on 29.09.21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  typealias UIViewType = MKMapView
    @StateObject var locationManager = LocationManager()
  @Binding var directions: [String]
    @Binding var ad: [String]
  
    @Binding var destination: LocationDestination
    @Binding var sToA: Int
    @State var region = LocationControl().getHomeGeofence().center
  
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
  
    func makeUIView(context: Context) -> MKMapView {
      print("DESTINATION: \(destination)")
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    
    let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: self.region.latitude, longitude: self.region.longitude),
      span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    mapView.setRegion(region, animated: true)
      
    
    
      let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.region.latitude, longitude: self.region.longitude))
      let P1 = MKPointAnnotation()
      P1.title = "You"
      P1.coordinate = CLLocationCoordinate2D(latitude: self.region.latitude, longitude: self.region.longitude)
      
      let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
      let P2 = MKPointAnnotation()
      P2.title = destination.name
    
      
      P2.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
      
//        let test = MKAnnotationView(annotation: P2, reuseIdentifier: "kjdkjdk")
//        test.annotation = P2
//        test.image = UIImage(named: "homeIcon")
//
    
        MorningKit().getDirections(p1: p1, p2: p2){route in
            mapView.showsBuildings = true
            mapView.addAnnotations([P1, P2])
            
            mapView.showsTraffic = true
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(
            route.polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
            animated: true)
            sToA = Int(route.expectedTravelTime)
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            self.ad = route.advisoryNotices
    }
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
//      makeUIView(context: context)
  }
  
  class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .systemBlue
      renderer.lineWidth = 5
      return renderer
    }
  }
}


struct MorningView: View {
    var proxy: CGSize
    @ObservedObject var calendar = CalendarKit()
    @EnvironmentObject var morning: MorningKit
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var updater: UpdateManager
    @State private var directions: [String] = []
    @State var ad: [String] = []
    @State private var showDirections = false
    @State var showSettings: Bool = false
    
    @State var destination: LocationDestination = LocationDestination(id: 0, name: "", latitude: 0, longitude: 0)
    @State var timeLeft: String = ""
    @State var onTime: Bool = false
    @State var secondsToArrival: Int = 0
    @State var travelTime: String = ""
    @State var arrivalTime: Date = Date()
    @State var leaveAt: Date = Date()
    
    @State var leave: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    func updateRoute(){
        MorningKit().calculateRoute(destination: destination){route in
            secondsToArrival = Int(route.expectedTravelTime)
        }
    }
    func update(){
        
        destination = updater.status.morning.destinations.first(where: {$0.id == updater.status.morning.nextDestinationId}) ?? destination
        
        
        let left = MorningKit().getTimeToDeparture(morning: updater.status.morning, secondsToArrival: secondsToArrival)
        timeLeft = String(format: "%02d:%02d",  left.0, left.1)
        
        
        travelTime = "\(String(secondsToArrival/60))minutes"
        
        //time to leave to arrive on time
        leaveAt = Calendar.current.date(byAdding: .second, value: (secondsToArrival * -1), to: MorningKit().stringToDate(date: updater.status.morning.arrivalTime)) ?? Date()
        
        //if departure time is in the past, calculate new arrival

        if left.1 < 0{
            onTime = false
            let newTravel = Calendar.current.date(byAdding: .second, value: secondsToArrival, to: Date()) ?? Date()
            let newArrivalMinutes = Calendar.current.date(byAdding: .minute, value: left.0 * -1, to: newTravel) ?? Date()
            guard let newArrival = Calendar.current.date(byAdding: .second, value: left.1 * -1, to: newArrivalMinutes)else{return}
            arrivalTime = newArrival
        }else{
            onTime = true
            arrivalTime = MorningKit().stringToDate(date: updater.status.morning.arrivalTime)
        }
        
 

    }
//    var Directions: some View {
//      VStack {
//        Button(action: {
//          self.showDirections.toggle()
//        }, label: {
//          Text("Show directions")
//        })
//        .disabled(directions.isEmpty)
//        .padding()
//      }.sheet(isPresented: $showDirections, content: {
//        VStack(spacing: 0) {
//          Text("Directions")
//            .font(.largeTitle)
//            .bold()
//            .padding()
//          Divider().background(Color.blue)
//          List(0..<self.ad.count, id: \.self) { i in
//            Text(self.ad[i]).padding()
//          }
//        }
//      })
//    }
    
    var leaveToggle: some View{
        HStack{
            Button(action: {leave.toggle()}){
                HStack{
                    Spacer()
                    Text("Leave now")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleBorderButtonStyle(color: Color("secondary")))
            Spacer()
        }
    }
    
    var leaveButton: some View{
        Button(action: {}){
            Text("Change Destination")
        }
    }
    
    var counter: some View{
        VStack(alignment: .leading){
            HStack{
                Text(onTime ? "ON TIME" : "LEAVE NOW")
                Image(systemName: "circle.fill")
                    .font(.caption)
                Text(MorningKit().formatDate(date: leaveAt))
            }
            .font(.title3.bold())
            .foregroundStyle(.secondary)
            
                
            Text(timeLeft)
                .font(.system(size: 80).bold())
            Text("Time To Departure")
                .foregroundStyle(.secondary)
        }.animation(.easeInOut, value: timeLeft)
    }
    
    var estimatedTimes: some View{
        VStack(alignment: .leading){
            Text(destination.name)
                .bold()
                .padding(.bottom)
            Text(MorningKit().formatDate(date: arrivalTime))
                .font(.title.bold())
                .foregroundStyle(.primary)
            Text("Estimated Arrival")
                .foregroundStyle(.secondary)
            
            Text(travelTime)
                .font(.title.bold())
                .foregroundStyle(.primary)
            Text("Travel Time")
                .foregroundStyle(.secondary)
        }
    }
    var directionOverview: some View{
        HStack(alignment: .bottom){

            Spacer()
       
        }.padding(.top)
    }
    
    var mainIpad: some View{
        HStack{
            MapView(directions: $directions, ad: $ad, destination: $destination, sToA: $secondsToArrival)
                .frame(width: proxy.width*0.9/2, height: proxy.width*0.9/2)
                .cornerRadius(15)
            
            VStack(alignment: .leading){
                HStack{
                    counter
                    Spacer()
                    estimatedTimes
                }.padding([.top])
                leaveToggle
                CalendarList()
                Spacer()
                
            }
        }.padding()
    }
    
    var mainIPhone: some View{
        VStack{
            HStack{
                counter
                Spacer()
            }.padding([.top, .leading])
            MapView(directions: $directions, ad: $ad, destination: $destination, sToA: $secondsToArrival)
                .frame(width: proxy.width*0.9, height: proxy.width*0.9)
                .cornerRadius(15)
            
            HStack{
                estimatedTimes
                Spacer()
            }.padding([.leading])
            leaveToggle
                .padding([.leading, .trailing, .bottom])
            CalendarList()
        }
    }
    var body: some View{
        VStack{
            
            if destination.id != 0 && locationManager.lastLocation?.coordinate.latitude != 0{
                if currentDeviceIsPhone(){
                    mainIPhone
                }else{
                    mainIpad
                }
                    
                   
            }
        }
        .padding(.bottom)
        .onAppear(perform: update)
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
            .onReceive(timer) { time in
                    updateRoute()
                print("Calculating Route")
            }
            .sheet(isPresented: $leave){
                LeaveStart()
            }
    }
    var main: some View {
//        VStack{
//        GeometryReader{proxy in
//            VStack{
//            HStack{
//                Spacer()
                VStack{
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    Text("Good Morning")
                        .font(.largeTitle.bold())
                    Text("Good morning sunshine. Take a look at your morning summary:")
                        .foregroundStyle(.secondary)
                    
                    HStack{
                        Spacer()
                        
//                        Spacer()
                        VStack{
                            directionOverview
                            leaveToggle
                            Spacer()
                        }
                        
                            .padding()
                            .frame(height: proxy.width*0.9/2)
                            
                        
                        Spacer()
                    }.padding()
                    
//                    Button(action: {showSettings.toggle()}){
//                        Text("Settings")
//                    }
                    
                }
//                .sheet(isPresented: $showSettings){
////                    AddDestination()
//                    WakeUpSettings()
//                }
                
                
//                Spacer()
//            }
//                Spacer()
//        }
//        }
        }
//    }
}

//struct MorningView_Previews: PreviewProvider {
//    static var previews: some View {
//        MorningView()
//.previewInterfaceOrientation(.portraitUpsideDown)
//    }
//}
