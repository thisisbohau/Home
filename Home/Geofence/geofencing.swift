//
//  geofencing.swift
//  iOSHome
//
//  Created by David Bohaumilitzky on 27.07.21.
//

import Foundation
import CoreLocation
import Combine
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.startMonitoringSignificantLocationChanges()
//        locationManager.startUpdatingLocation()
        
        let region = GeoKit().getHomeGeofence()
        region.notifyOnExit = true
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
        print("Monitoring Geofence: \(region.description)")
        
    }
    
    func startMonitoring(){
//        let homeLat = NSUbiquitousKeyValueStore.default.double(forKey: "Lat")
//        let homeLon = NSUbiquitousKeyValueStore.default.doubltruee(forKey: "Lon")
//        let homeRadius = NSUbiquitousKeyValueStore.default.double(forKey: "Radius")
//        print("Monitoring data: Lat\(homeLat.description), Lon\(homeLon.description), radius\(homeRadius.description)")
//        let homeCoordinates = CLLocationCoordinate2D(latitude: homeLat, longitude: homeLon)
//        let monitoringRadius: Double = homeRadius
        let region = GeoKit().getHomeGeofence()
        
        region.notifyOnExit = true
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }

    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //device exited region
        print("pushing new status: false")
        GeoKit().pushHomeStatus(status: false)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //device entered region
        print("pushing new status: true")
        GeoKit().pushHomeStatus(status: true)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
        
        //push new location to sever
        GeoKit().pushLocation(location: location)
        
    }

}

class GeoKit{
    
    func setHomeCoordinates(location: CLLocationCoordinate2D, radius: Double){
        NSUbiquitousKeyValueStore.default.set(location.longitude, forKey: "Lon")
        NSUbiquitousKeyValueStore.default.set(location.latitude, forKey: "Lat")
        NSUbiquitousKeyValueStore.default.set(radius, forKey: "Radius")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func getHomeGeofence() -> CLCircularRegion{
        let homeLat = NSUbiquitousKeyValueStore.default.double(forKey: "Lat")
        let homeLon = NSUbiquitousKeyValueStore.default.double(forKey: "Lon")
        let homeRadius = NSUbiquitousKeyValueStore.default.double(forKey: "Radius")
        print("Monitoring data: Lat\(homeLat.description), Lon\(homeLon.description), radius\(homeRadius.description)")
        let homeCoordinates = CLLocationCoordinate2D(latitude: homeLat, longitude: homeLon)
        let monitoringRadius: Double = homeRadius
        return CLCircularRegion(center: homeCoordinates, radius: monitoringRadius, identifier: "Home")
    }
    func setLastKnownLocation(location: CLLocationCoordinate2D){
        UserDefaults.standard.set(Double(location.latitude), forKey: "lat")
        UserDefaults.standard.set(Double(location.longitude), forKey: "lon")
    }
    func getLastKnownLocation() -> CLLocationCoordinate2D{
        let lat = UserDefaults.standard.double(forKey: "lat")
        let lon = UserDefaults.standard.double(forKey: "lon")
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    func getRequestURL(queries: [URLQueryItem]) -> URL{
        var components = URLComponents()
        components.path = "/hook/home/geofence"
        components.port = 80
        components.host = "6494d8d930c7fe15329867e22f929180.ipmagic.de"
        components.scheme = "http"
        
        components.queryItems = queries
        let url = components.url!
        return url
    }
    
//    func makeRequest(url: URL, completion: @escaping(Data?, Error?) -> Void){
//        var request = URLRequest(url: url)
////        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
//        request.httpBody = String("user=Home&password=KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw").data(using: .utf8)
//        request.httpMethod = "POST"
//        let task = URLSession.shared.dataTask(with: request){data, response, error in
//            if let error = error{
//                print(error.localizedDescription)
//            }
//            completion(data, error)
//        }
//        task.resume()
//    }
    
    func pushHomeStatus(status: Bool){
        print("pushing home status to sever")
        //append the FCM token, this is the identifier for the device and the connected push notifications.
        let fcmToken = UIDevice.current.identifierForVendor!.uuidString
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "homeStatus"))
        queries.append(URLQueryItem(name: "device", value: fcmToken))
        queries.append(URLQueryItem(name: "name", value: UIDevice.current.name))
        queries.append(URLQueryItem(name: "home", value: status.description))
                       
        let requestURL = getRequestURL(queries: queries)
        var request = URLRequest(url: requestURL)
//        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
        request.httpBody = String("user=Home&password=KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw").data(using: .utf8)
        request.httpMethod = "POST"
        
        BackgroundSession.shared.start(request)

    }
    
    func pushLocationUnchecked(location: CLLocation){
        //check if the new location is in the region if the old one, if yes don't push the new location to the sever
//        let lastLocation = getLastKnownLocation()
//        let lastRegion = CLCircularRegion(center: lastLocation, radius: 15, identifier: "lastLocation")
//        if !lastRegion.contains(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)){
            setLastKnownLocation(location: location.coordinate)
            
            print("pushing location to sever, speed: \(location.speed), name\(UIDevice.current.name)")
            
            //check if the current location is inside the Home fence. This insures that the home status is always correct even if the user moves quickly inside and out the geofence
            let homeFence = getHomeGeofence()
            let isHome = homeFence.contains(location.coordinate)
            //append the FCM token, this is the identifier for the device and the connected push notifications.
            let fcmToken = UIDevice.current.identifierForVendor!.uuidString
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "locationUpdate"))
            queries.append(URLQueryItem(name: "device", value: fcmToken))
            queries.append(URLQueryItem(name: "name", value: UIDevice.current.name))
            queries.append(URLQueryItem(name: "speed", value: location.speed.description))
            queries.append(URLQueryItem(name: "home", value: isHome.description))
            queries.append(URLQueryItem(name: "lat", value: location.coordinate.latitude.description))
            queries.append(URLQueryItem(name: "lon", value: location.coordinate.longitude.description))
                           
            
            let requestURL = getRequestURL(queries: queries)
            var request = URLRequest(url: requestURL)
    //        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
            request.httpBody = String("user=Home&password=KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw").data(using: .utf8)
            request.httpMethod = "POST"
            
            BackgroundSession.shared.start(request)
//        }
    }
    func pushLocation(location: CLLocation){
        //check if the new location is in the region if the old one, if yes don't push the new location to the sever
//        let lastLocation = getLastKnownLocation()
//        let lastRegion = CLCircularRegion(center: lastLocation, radius: 15, identifier: "lastLocation")
//        if !lastRegion.contains(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)){
            setLastKnownLocation(location: location.coordinate)
            
            print("pushing location to sever, speed: \(location.speed), name\(UIDevice.current.name)")
            
            //check if the current location is inside the Home fence. This insures that the home status is always correct even if the user moves quickly inside and out the geofence
            let homeFence = getHomeGeofence()
            let isHome = homeFence.contains(location.coordinate)
            //append the FCM token, this is the identifier for the device and the connected push notifications.
            let fcmToken = UIDevice.current.identifierForVendor!.uuidString
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "locationUpdate"))
            queries.append(URLQueryItem(name: "device", value: fcmToken))
            queries.append(URLQueryItem(name: "name", value: UIDevice.current.name))
            queries.append(URLQueryItem(name: "speed", value: location.speed.description))
            queries.append(URLQueryItem(name: "home", value: isHome.description))
            queries.append(URLQueryItem(name: "lat", value: location.coordinate.latitude.description))
            queries.append(URLQueryItem(name: "lon", value: location.coordinate.longitude.description))
                           
            
            let requestURL = getRequestURL(queries: queries)
            var request = URLRequest(url: requestURL)
    //        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
            request.httpBody = String("user=Home&password=KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw").data(using: .utf8)
            request.httpMethod = "POST"
            
            BackgroundSession.shared.start(request)
//        }
    }
        
}

class BackgroundSession: NSObject {
    static let shared = BackgroundSession()
    
    static let identifier = "com.domain.app.bg"
    
    private var session: URLSession!

    #if !os(macOS)
    var savedCompletionHandler: (() -> Void)?
    #endif
    
    private override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundSession.identifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func start(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
//        session.dataTask(with: request, completionHandler: {data, response, error in
//
//        }).resume()
    }
}

extension BackgroundSession: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
    #endif
}

extension BackgroundSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // handle failure here
            print("\(error.localizedDescription)")
        }
    }
}

extension BackgroundSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let json = try JSONSerialization.jsonObject(with: data)
            
            print("\(json)")
            // do something with json
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}
