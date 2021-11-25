//
//  httpRequest.swift
//  Home
//
//  Created by David Bohaumilitzky on 23.04.21.
//

import Foundation
import UIKit
import Network

enum directories: String{
    case sentry = "sentry"
    case scene = "sceneKit"
    case light = "lightKit"
    case blind = "blindKit"
    case irrigation = "irrigationKit"
    case tado = "tadoKit"
    case irrigationDeveloper = "irrigationDeveloper"
    case irrigationStatus = "irrigationStatus"
    case switchKit = "switchKit"
    case nukiKit = "nukiKit"
    case mowerKit = "mowerKit"
    case geoKit = "geoKit"
    case lockdown = "lockdown"
    case morning = "morning"
    case garage = "garage"
    case lightAnalyzer = "lightAnalyzer"
}

class Updater: ObservableObject{
    static let shared = Updater()
    @Published var lastUpdated = Date()
    @Published var error: Bool = false
    @Published var started: Bool = false
    @Published var errorDescription: String = ""
    @Published var errorCode: String = ""
    @Published var status: Home = Home(rooms: [Room](), irrigation: irrigationSystem(controlValveActive: false, zones: [irrigationZone](), pumpStatus: false, refillActive: false, active: false, secondsRemaining: 0, irrigationDuration: 0, fault: false, schedule: [TimeSlot](), secondarySchedule: [TimeSlot](), mode: 0, paused: false), mower: Mower(nextStart: "", mode: 0, status: 0, battery: 0, manual: false, schedulePaused: false, error: ""), pool: Pool(temp: 0.0, pH: 0.0, aCl: 0.0, pumpActive: false), weather: Weather(currentTemp: 0, low: 0, hight: 0, humidity: 0, condition: 0, rainCurrent: 0, rainToday: 0, lastUpdate: "", rain: false, heavyRain: false, weatherAdaption: Switch(id: 0, state: false, name: "", description: "")), geofence: Geofence(home: false, people: [Person]()), power: Power(systemMode: 0, powerOutage: nil, powerSplit: PowerSplit(grid: 0, solar: 0, battery: 0, combinedUsage: 0), solar: SolarSplit(system1: 0, system2: 0, combinedProduction: 0, dailyProduction: 0, batteryCharging: 0, homeUsage: 0, gridFeed: 0), metrics: PowerMetrics(usageToday: 0, solarProductionToday: 0, autarkie: 0, batteryBackupMinutes: 0), batteryState: 0), scenes: [SceneAutomation](), catchUp: CatchUp(state: false, r: 0, g: 0, b: 0, brightness: 0, mode: ""), nuki: Nuki(id: 0, state: false, battery: 0, door: 0), garage: GarageDoor(state: false, latch: Blind(id: "", name: "", position: 0, moving: false), openedAt: ""), notifications: [Notification](), lockdown: Lockdown(triggered: false, recommenced: false, reason: "", triggeredAt: ""), sentry: Sentry(active: false, alarmState: false, sentryTriggered: false, triggeredOn: "", motionInRooms: [0], triggeredRoom: 0), laundry: [LaundryDevice](), morning: Morning(destinations: [LocationDestination](), wakeUpTime: "", arrivalTime: "", nextDestinationId: 0, showBedtime: false, showMorning: false), dogMode: DogMode(active: false, analyzing: false, state: 0))
    
    var timerLoop = Timer()
    func startUpdateLoop(){
        timerLoop = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateRequests), userInfo: nil, repeats: true)
    }
    @objc func updateRequests(){
        if String(data: Keychain.load(key: "HomeAdress") ?? Data(), encoding: .utf8) ?? "" == ""{
            print("no sever set")
            self.error = true
            self.errorDescription = "Enter a valid sever address. Go to Settings -> \"Update Credentials\" and complete setting up a connection."
            self.errorCode = "Setup required"
        }else{
            if NetworkStatus.shared.isOn{
                updateStatus()
            }else{
                print("device offline")
                self.error = true
                self.errorDescription = "You Device appears to be offline"
                self.errorCode = "Network Error"
            }
        }
    }
    func updateStatus(){

                makeRequest(url: getStatusURL()){response, responseError in
                    
                    guard let data = response else{
                        print("No response from sever...")
                        DispatchQueue.main.async {
                            self.error = true
                            self.errorDescription = "No Response from sever. The sever might be offline or inactive.\n(Code: \(responseError?.localizedDescription ?? "")"
                        }
                        return
                    }
                   
                    let decoder = JSONDecoder()
                    do{
//                        String(data: data as! Data, encoding: String.Encoding.utf8)
        //                print(String(data: data, encoding: .utf8))
                        let StringData = String(data: data, encoding: .utf8)?.data(using: .utf8)
                        let Status = try decoder.decode(Home.self, from: StringData ?? Data())
                        
//                        print(String(data: StringData!, encoding: .utf8))
        //                let user = try! decoder.decode(Home.self, from: StringData)
        //                let array = user
        //                print(array.description)
        //                guard let Status =  array.first else{
        //                    print("NO ARRAY GIVEN \(array)")
        //                    return
        //                }
        //                print(array.rooms)
                        DispatchQueue.main.async { [self] in
        //                    print(Status)
                            
                            //sort rooms by favorites
                            let favorites = RoomKit().getFavorites()
                            var rooms = Status.rooms
                            for room in rooms{
                                if favorites.contains(where: {$0 == Int(room.id)}){
                                    rooms.removeAll(where: {$0.id == room.id})
                                    rooms.insert(room, at: 0)
                                }
                            }
                            var sortedStatus = Status
                            sortedStatus.rooms = rooms
                            status = sortedStatus
                            
                            lastUpdated = Date()
                            error = false
                            started = true
        //                    print(array)
                        }
                        
                    }
                    catch DecodingError.keyNotFound(let key, let context) {
                        Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                        DispatchQueue.main.async {
                            self.error = true
                            self.errorDescription = "Developer intervention required. Missing Key in response: \(key)"
                            self.errorCode = "Communication Error"
                        }
                    }catch DecodingError.valueNotFound(let type, let context) {
                        Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                        DispatchQueue.main.async {
                            self.error = true
                            self.errorDescription = "Developer intervention required. Missing Type in response: \(type)"
                            self.errorCode = "Communication Error"
                        }
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        DispatchQueue.main.async {
                            self.error = true
                            self.errorDescription = "Developer intervention required. Type mismatch in response: \(type)"
                            self.errorCode = "Communication Error"
                        }
                    } catch DecodingError.dataCorrupted(let context) {
                        Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                        DispatchQueue.main.async {
                            self.error = true
                            self.errorDescription = "Developer intervention required. Response not readable"
                            self.errorCode = "Communication Error"
                            print(String(data: response ?? Data(), encoding: .utf8) ?? "")
                        }
                    }catch{
                        print("Unresolved error.")
                        self.error = true
                        self.errorDescription = "An unexpected error occurred."
                        self.errorCode = "Unknown Error"
                    }

        }
    }
    
    
    func getRequestURL(directory: directories, queries: [URLQueryItem]) -> URL{
        let urlSec = String(data: Keychain.load(key: "HomeAdress") ?? Data(), encoding: .utf8) ?? ""
        
        var components = URLComponents()
        components.path = "/hook/home/"
        components.port = 80
        components.host = urlSec
        components.scheme = "http"
        
        components.queryItems = queries
        components.path.append(directory.rawValue)
//        print(components.url?.debugDescription ?? "")
        let url = components.url!
        return url
    }
    
    func getStatusURL() -> URL{
        let urlSec = String(data: Keychain.load(key: "HomeAdress") ?? Data(), encoding: .utf8) ?? ""
        var components = URLComponents()
        components.path = "/hook/home/status/"
        components.port = 80
        components.host = urlSec
        components.scheme = "http"
        
//        components.queryItems = queries
//        components.path.append()
//        print(components.url?.debugDescription ?? "")
        let url = components.url!
        return url
    }
    
    func makeRequest(url: URL, completion: @escaping(Data?, Error?) -> Void){
        if UIApplication.shared.applicationState == .active{
            let password = String(data: Keychain.load(key: "HomePassword") ?? Data(), encoding: .utf8) ?? ""
            var request = URLRequest(url: url)
    //        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
            //KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw
            request.httpBody = String("user=Home&password=\(password)").data(using: .utf8)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if let error = error{
                    print(error.localizedDescription)
                }
                completion(data, error)
            }
            task.resume()
        }
    }
    
    func makeActionRequest(url: URL, completion: @escaping(Data) -> Void){
        makeRequest(url: url){response, responseError in
            guard let data = response else{
                return
            }
           completion(data)
        }
    }
    
    func printHomeStruct(){
        let encoder = JSONEncoder()
        do{
            
            let data = try encoder.encode(WindowSensor(id: 0, name: "", state: false, lastUpdate: ""))
            print("Home structure template.....\n")
            print(String(data: data, encoding: .utf8) ?? "")
            print("\n.....eof")
        }catch{
            print("home struct couldn't be converted into template. aborting.")
            return
        }
    }

    
    
}
//
//
//class ServerData: ObservableObject{
//    static let shared = ServerData()
//    @Published var url: URL = URL(string: "https://www.apple.com")!
//    @Published var statusURL: URL = URL(string: "https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/home/status")!
//    @Published var fetchedData: Data = Data()
//    @Published var statusData: Data = Data()
//
//    var timerLoop = Timer()
//    func startTimer(){
//        timerLoop = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateRequests), userInfo: nil, repeats: true)
//    }
//    @objc func updateRequests(){
//        makeRequest(url: statusURL){response, error in
//            guard let data = response else{
//                return
//            }
//            DispatchQueue.main.async {
//                self.statusData = data
//            }
//        }
//    }
//
//    func makeActionRequest(url: URL){
//        makeRequest(url: url){response in
//            guard let data = response else{
//                return
//            }
//            DispatchQueue.main.async {
//                self.fetchedData = data
//            }
//        }
//    }
//
//    func getRequestURL(directory: directories, queries: [URLQueryItem]) -> URL{
//        var components = URLComponents()
//        components.path = "/hook/home/"
//        components.port = 80
//        components.host = "6494d8d930c7fe15329867e22f929180.ipmagic.de"
//        components.scheme = "http"
//
//        components.queryItems = queries
//        components.path.append(directory.rawValue)
////        print(components.url?.debugDescription ?? "")
//        let url = components.url!
//        return url
//    }
//
//
//    func getStatusURL(directory: directories, queries: [URLQueryItem]) -> URL{
//        var components = URLComponents()
//        components.path = "/hook/home/status/"
//        components.port = 80
//        components.host = "6494d8d930c7fe15329867e22f929180.ipmagic.de"
//        components.scheme = "http"
//
//        components.queryItems = queries
//        components.path.append(directory.rawValue)
////        print(components.url?.debugDescription ?? "")
//        let url = components.url!
//        return url
//    }
//
//    func makeRequest(url: URL, completion: @escaping(Data?, Error?) -> Void){
//        var request = URLRequest(url: url)
////        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
//        request.httpBody = String("user=Home&password=KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw").data(using: .utf8)
//        request.httpMethod = "POST"
//        let task = URLSession.shared.dataTask(with: request){data, response, error in
//            if let error = error{
//                print(error.localizedDescription)
//            }
////            print(error)
////            print(String(data: data ?? Data(), encoding: .utf8))
////            print("Response size: \(data ?? Data())")
//            completion(data, error)
//        }
//        task.resume()
//    }
//}
//
