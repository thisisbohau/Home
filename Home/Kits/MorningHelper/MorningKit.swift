//
//  MorningKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.09.21.
//

import Foundation
import Combine
import MapKit

struct LocationDestination: Identifiable, Codable{
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
}
class MorningKit: ObservableObject{
    
//    func startUpdating(){
////        calculateRoute()
//        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.calculateRoute), userInfo: nil, repeats: true)
//
//    }
    func calculateRoute(destination: LocationDestination, completion: @escaping(MKRoute) -> Void){
        let region = LocationControl().getHomeGeofence().center
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude))
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
        
        getDirections(p1: p1, p2: p2){route in
            print("Route updated. Expected travel time: \(route.expectedTravelTime)sec")
                completion(route)
                
                
        }
    
    }
    
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func stringToDate(date: String) -> Date {
//         let dateFormatter = DateFormatter()
//         dateFormatter.dateFormat = "HH:mm"
//         dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//         let date = dateFormatter.date(from: date) ?? Date()
            let double = Double(date) ?? 0
        
         return Date(timeIntervalSince1970: double)
    }
    func dateToString(date: Date) -> String{
//         let dateFormatter = DateFormatter()
//         dateFormatter.dateFormat = "HH:mm"
//         dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//         let date = dateFormatter.string(from: date)
        let string = String(date.timeIntervalSince1970)
         return string
    }
    
    func setRoutine(destination: LocationDestination, arrivalTime: Date, wakeUpTime: Date) async{
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "setRoutine"))
        queries.append(URLQueryItem(name: "wakeUpTime", value: dateToString(date: wakeUpTime)))
        queries.append(URLQueryItem(name: "arrivingTime", value: dateToString(date: arrivalTime)))
        queries.append(URLQueryItem(name: "destination", value: destination.id.description))
        
        let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.morning, queries: queries)
//        let requestURL = Updater().getRequestURL(directory: directories.morning, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func addLocation(location: LocationDestination){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "addLocation"))
            queries.append(URLQueryItem(name: "name", value: location.name))
            queries.append(URLQueryItem(name: "lat", value: String(location.latitude)))
            queries.append(URLQueryItem(name: "lon", value: String(location.longitude)))
        
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.morning, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.morning, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func getTimeToDeparture(morning: Morning, secondsToArrival: Int) -> (Int, Int){
        let arrivalComp = Calendar.current.dateComponents([.hour, .minute, .second], from: stringToDate(date: morning.arrivalTime))
        let referenceArrival = Calendar.current.date(bySettingHour: arrivalComp.hour ?? 0, minute: arrivalComp.minute ?? 0, second: arrivalComp.second ?? 0, of: Date())
        
        
        let leaveAt = Calendar.current.date(byAdding: .second, value: (secondsToArrival * -1), to: referenceArrival ?? Date()) ?? Date()
        
        let timeComponents = Calendar.current.dateComponents([.minute, .second], from: Date(), to: leaveAt)
        return (timeComponents.minute ?? 0, timeComponents.second ?? 0)
    }
    
    
    func getDirections(p1: MKPlacemark, p2: MKPlacemark, completion: @escaping(MKRoute) -> Void){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)

        directions.calculate { response, error in
            guard let route = response?.routes.first else {
//                fatalError("No route found")
                return}
            completion(route)
        }
    }
}
