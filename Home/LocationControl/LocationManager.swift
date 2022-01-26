//
//  LocationManager.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.12.21.
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
        //initial setup for location monitoring
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestLocation()
       
        
        startMonitoringHomeGeofence()
        let monitoredRegions = locationManager.monitoredRegions
        print("Monitored Regions: \(monitoredRegions.description)")
        print(" | Location Monitoring setup complete")
    }
    
    func updateLocation(){
        
        locationManager.requestLocation()
    }
    /// Uses the stored geofencing coordinates along with the set precision.
    func startMonitoringHomeGeofence(){
        let region = LocationControl().getHomeGeofence()
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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Device has left the Home Geofence")
        LocationControl().pushHomeStatus(isHome: false)
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Location updates have resumed, updating Location")
        
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Location updates have been paused by the system, pushing last known location and status")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Device has entered the Home Geofence")
        LocationControl().pushHomeStatus(isHome: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside{
            LocationControl().pushHomeStatus(isHome: true)
        }else if state == .outside{
            LocationControl().pushHomeStatus(isHome: false)
        }
        print("Home Status updated. Current State: \(state == .inside ? "HOME" : "AWAY")")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { [self] in
        
        print("New Location available.")
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
        
        //push new location to sever
            LocationControl().pushLocation(location: location)
            locationManager.requestState(for: LocationControl().getHomeGeofence())
        }
    }

}

class LocationControl{
    /// Sets the given coordinate as the new Home location.
    /// - Parameters:
    ///   - coordinate: 'Center' of the Home location
    ///   - radius: radius of the invisible border around the location
    func setHomeGeofence(coordinate: CLLocationCoordinate2D, radius: Double){
        NSUbiquitousKeyValueStore.default.set(coordinate.longitude, forKey: "HomeLongitude")
        NSUbiquitousKeyValueStore.default.set(coordinate.latitude, forKey: "HomeLatitude")
        NSUbiquitousKeyValueStore.default.set(radius, forKey: "MonitoringRadius")
        NSUbiquitousKeyValueStore.default.synchronize()
        print("New Home Location set: \(coordinate)")
    }
    
    func getHomeGeofence() -> CLCircularRegion{
        let longitude = NSUbiquitousKeyValueStore.default.double(forKey: "HomeLongitude")
        let latitude = NSUbiquitousKeyValueStore.default.double(forKey: "HomeLatitude")
        let radius = NSUbiquitousKeyValueStore.default.double(forKey: "MonitoringRadius")
        
        return CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: CLLocationDistance(radius), identifier: "HomeGeofence")
    }
    
    func getPresenceVerbos(devices: [Device], current: Device) -> String{
        var homeDevices = devices.filter({$0.home})
        if homeDevices.count > 0{
            guard let first = homeDevices.first else{
                return "No one is Home"
            }
            if homeDevices.count == 1 && first.id == current.id{
                return "You are Home"
            }else if homeDevices.count == 1 && first.id != current.id{
                return "\(first.name) is Home"
            }else{
                var string = ""
                if homeDevices.contains(where: {$0.id == current.id}){
                    homeDevices.removeAll(where: {$0.id == current.id})
                    if homeDevices.count == 1{
                        string = "You and "
                        let str =   homeDevices.compactMap({$0.name}).joined(separator: ", ")
                        string.append(str)
                    }else{
                        string = "You, "
                        var arr = homeDevices.compactMap({$0.name})
                        let last = arr.popLast()
                        let str =  arr.joined(separator: ", ") + " and " + last!
                        string.append(str)
                    }
                }else{
                    if homeDevices.count > 1{
                        var arr = homeDevices.compactMap({$0.name})
                        let last = arr.popLast()
                        let str =  arr.joined(separator: ", ") + " and " + last!
                        string.append(str)
                    }else{
                        let str =  homeDevices.compactMap({$0.name}).joined(separator: ", ")
                        string.append(str)
                    }
                }
                    
                return "\(string) are Home"
            }
        }else{
            return "No one is Home"
        }
    }
    
    func pushLocation(location: CLLocation){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "update"))
            queries.append(URLQueryItem(name: "deviceToken", value: AccessKit().getDeviceToken()))
            queries.append(URLQueryItem(name: "accessToken", value: AccessKit().getAccessKey()))
            queries.append(URLQueryItem(name: "speed", value: location.speed.description))
            queries.append(URLQueryItem(name: "lat", value: location.coordinate.latitude.description))
            queries.append(URLQueryItem(name: "lon", value: location.coordinate.longitude.description))
            queries.append(URLQueryItem(name: "updateMode", value: "locationUpdate"))
            
            let _ = try await RequestManager().makeAccessRequest(queries: queries)
        }
    }
    func pushHomeStatus(isHome: Bool){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "update"))
            queries.append(URLQueryItem(name: "deviceToken", value: AccessKit().getDeviceToken()))
            queries.append(URLQueryItem(name: "accessToken", value: AccessKit().getAccessKey()))
            queries.append(URLQueryItem(name: "home", value: isHome.description))
            queries.append(URLQueryItem(name: "updateMode", value: "homeStatus"))
            
            let _ = try await RequestManager().makeAccessRequest(queries: queries)
            
        }
    }
    
}
