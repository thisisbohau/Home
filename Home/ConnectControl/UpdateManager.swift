//
//  UpdateManager.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.12.21.
//

import Foundation
import UIKit
import Network


enum ActionDirectories: String{
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
    case dishwasher = "dishwasherKit"
}

class UpdateManager: ObservableObject{
    static let shared = UpdateManager()
    
    @Published var showServerSetup: Bool = false
    @Published var showDeviceSetup: Bool = false
    @Published var activeSession: Bool = false
    @Published var lastUpdated = Date()
    @Published var error: Bool = false
    @Published var started: Bool = false
    @Published var errorDescription: String = ""
    @Published var errorCode: String = ""
    @Published var errorCheck: Bool = false
    
    @Published var currentDevice: Device = Device(id: "", role: 0, home: false, name: "", lat: 0, lon: 0, speed: 0, fcmToken: "", lastHome: "")
    
    @Published var status: Home = Home(rooms: [Room](), irrigation: irrigationSystem(controlValveActive: false, zones: [irrigationZone](), pumpStatus: false, refillActive: false, active: false, secondsRemaining: 0, irrigationDuration: 0, fault: false, schedule: [TimeSlot](), secondarySchedule: [TimeSlot](), mode: 0, paused: false), mower: Mower(nextStart: "", mode: 0, status: 0, battery: 0, manual: false, schedulePaused: false, error: ""), pool: Pool(temp: 0.0, pH: 0.0, aCl: 0.0, pumpActive: false), weather: Weather(currentTemp: 0, low: 0, hight: 0, humidity: 0, condition: 0, rainCurrent: 0, rainToday: 0, lastUpdate: "", rain: false, heavyRain: false, weatherAdaption: Switch(id: 0, state: false, name: "", description: "")), devices: [Device](), power: Power(systemMode: 0, powerOutage: nil, powerSplit: PowerSplit(grid: 0, solar: 0, battery: 0, combinedUsage: 0), solar: SolarSplit(system1: 0, system2: 0, combinedProduction: 0, dailyProduction: 0, batteryCharging: 0, homeUsage: 0, gridFeed: 0), metrics: PowerMetrics(usageToday: 0, solarProductionToday: 0, autarkie: 0, batteryBackupMinutes: 0), batteryState: 0), scenes: [SceneAutomation](), catchUp: CatchUp(state: false, r: 0, g: 0, b: 0, brightness: 0, mode: ""), nuki: Nuki(id: 0, state: false, battery: 0, door: 0), garage: GarageDoor(state: false, latch: Blind(id: "", name: "", position: 0, moving: false), openedAt: ""), notifications: [Notification](), lockdown: Lockdown(triggered: false, recommenced: false, reason: "", triggeredAt: ""), sentry: Sentry(active: false, alarmState: false, sentryTriggered: false, triggeredOn: "", motionInRooms: [0], triggeredRoom: 0), laundry: [LaundryDevice](), morning: Morning(destinations: [LocationDestination](), wakeUpTime: "", arrivalTime: "", nextDestinationId: 0, showBedtime: false, showMorning: false), dogMode: DogMode(active: false, analyzing: false, state: 0), dishwasher: Dishwasher(power: false, doorState: false, event: nil, operationState: "", timeRemaining: 0, activeProgram: "", availablePrograms: [DishwasherProgram](), availableOptions: [DishwasherOption](), programProgress: 0, startTime: ""))
    
    var timerLoop = Timer()
    func startUpdateLoop(){
        printHomeStruct()
        timerLoop = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.configurationCheck), userInfo: nil, repeats: true)
    }
    
    @objc func configurationCheck(){
        if AccessKit().getServerAddress() == ""{
//            if errorCheck{
                self.showServerSetup = true
                self.error = true
                self.errorDescription = "No Server Address could be found. Set up a valid connection in settings."
//            }
        }else if !NetworkStatus.shared.isOn{
            if errorCheck{
                self.error = true
                self.errorDescription = "Please check internet connection and try again."
                self.errorCode = "Network Error"
            }
        }else{
            if !errorCheck{
                print("| UpdateManager started. Error check complete.")
            }
            errorCheck = true
            scheduledUpdate()
     
        }
    }
    func scheduledUpdate(){
        Task{
        do{
            let statusString = try await RequestManager().makeStatusRequest()
            if statusString == "No authenticated user was found."{
                DispatchQueue.main.async { [self] in
                self.showDeviceSetup = true
                }
                return
            }
            let decoder = JSONDecoder()
            let Status = try decoder.decode(Home.self, from: statusString.data(using: .utf8) ?? Data())
            DispatchQueue.main.async { [self] in
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
                showServerSetup = false
                
                guard let current = status.devices.first(where: {$0.id == AccessKit().getDeviceToken()})else {
                    showDeviceSetup = true
                    print("New Device found")
                    return
                }
                showDeviceSetup = false
                currentDevice = current
                
                if !activeSession{
                    AccessKit().sessionStart()
                    activeSession = true
                }
            }
        }catch{
            DispatchQueue.main.async {
                self.error = true
                self.errorDescription = error.localizedDescription
                self.errorCode = "Server Error"
            }
        }
        }
    }
    
//    @objc func updateRequests(){
//        if String(data: Keychain.load(key: "SeverAddress") ?? Data(), encoding: .utf8) ?? "" == ""{
//            print("no sever set")
//            self.showServerSetup = true
//            self.error = true
//            self.errorDescription = "Enter a valid sever address. Go to Settings -> \"Update Credentials\" and complete setting up a connection."
//            self.errorCode = "Setup required"
//        }else{
//            if NetworkStatus.shared.isOn{
//                updateStatus()
//            }else{
//                print("device offline")
//                self.error = true
//                self.errorDescription = "You Device appears to be offline"
//                self.errorCode = "Network Error"
//            }
//        }
//    }
//
//
//    func updateStatus(){
//
//                makeRequest(url: getStatusURL()){response, responseError in
//                    guard let data = response else{
//                        print("No response from sever...")
//                        DispatchQueue.main.async {
//                            self.error = true
//                            self.errorDescription = "No Response from sever. The sever might be offline or inactive.\n(Code: \(responseError?.localizedDescription ?? "")"
//                        }
//                        return
//                    }
//
//                    let decoder = JSONDecoder()
//                    do{
////                        String(data: data as! Data, encoding: String.Encoding.utf8)
//        //                print(String(data: data, encoding: .utf8))
//                        let StringData = String(data: data, encoding: .utf8)?.data(using: .utf8)
//                        let Status = try decoder.decode(Home.self, from: StringData ?? Data())
//
////                        print(String(data: StringData!, encoding: .utf8))
//        //                let user = try! decoder.decode(Home.self, from: StringData)
//        //                let array = user
//        //                print(array.description)
//        //                guard let Status =  array.first else{
//        //                    print("NO ARRAY GIVEN \(array)")
//        //                    return
//        //                }
//        //                print(array.rooms)
//                        DispatchQueue.main.async { [self] in
//        //                    print(Status)
//
//                            //sort rooms by favorites
//                            let favorites = RoomKit().getFavorites()
//                            var rooms = Status.rooms
//                            for room in rooms{
//                                if favorites.contains(where: {$0 == Int(room.id)}){
//                                    rooms.removeAll(where: {$0.id == room.id})
//                                    rooms.insert(room, at: 0)
//                                }
//                            }
//                            var sortedStatus = Status
//                            sortedStatus.rooms = rooms
//                            status = sortedStatus
//
//                            lastUpdated = Date()
//                            error = false
//                            started = true
//                            showServerSetup = false
//
//                            if !status.geofence.contains(where: {$0.id == AccessKit().getDeviceToken()}){
//                                showDeviceSetup = true
//                                print("New Device found")
//                            }else{
//                                showDeviceSetup = false
//                            }
//
//        //                    print(array)
//                        }
//
//                    }
//                    catch{
//                        DispatchQueue.main.async {
//                            if String(data: data, encoding: .utf8) == "No authenticated user was found."{
//                                self.showDeviceSetup = true
//                            }else{
//                                print("Unresolved error.")
//                                self.error = true
//                                self.errorDescription = "An unexpected error occurred."
//                                self.errorCode = "Unknown Error"
//                            }
//                        }
//
//                    }
//
//        }
//    }
//
    
//    func getRequestURL(directory: directories, queries: [URLQueryItem]) -> URL{
//        let urlSec = String(data: Keychain.load(key: "SeverAddress") ?? Data(), encoding: .utf8) ?? ""
//
//        var components = URLComponents()
//        components.path = "/hook/home/"
//        components.port = 80
//        components.host = urlSec
//        components.scheme = "http"
//
//        components.queryItems = queries
//        components.path.append(directory.rawValue)
////        print(components.url?.debugDescription ?? "")
//        let url = components.url!
//        return url
//    }
    
//    func getStatusURL() -> URL{
//        let urlSec = String(data: Keychain.load(key: "SeverAddress") ?? Data(), encoding: .utf8) ?? ""
//        var components = URLComponents()
//        components.path = "/hook/home/status/"
//        components.port = 80
//        components.host = urlSec
//        components.scheme = "http"
//
////        components.queryItems = queries
////        components.path.append()
////        print(components.url?.debugDescription ?? "")
//        let url = components.url!
//        return url
//    }
    
//    func makeRequest(url: URL, completion: @escaping(Data?, Error?) -> Void){
//        if UIApplication.shared.applicationState == .active{
//            let password = AccessKit().getAccessKey()
//            let user = AccessKit().getDeviceToken()
//            var request = URLRequest(url: url)
//    //        https://6494d8d930c7fe15329867e22f929180.ipmagic.de/hook/geofency
//            //KAsmAWNAokPQSHoDvkgMdqiJeXTX4kw
//            request.httpBody = String("user=\(user)&password=\(password)").data(using: .utf8)
//            request.httpMethod = "POST"
//            print("making request with content: \(request)")
//            let task = URLSession.shared.dataTask(with: request){data, response, error in
//                if let error = error{
//                    print(error.localizedDescription)
//                }
//
////                print(String(data: data ?? Data(), encoding: .utf8))
//                completion(data, error)
//            }
//            task.resume()
//        }
//    }
    
//    func makeActionRequest(url: URL, completion: @escaping(Data) -> Void){
//        makeRequest(url: url){response, responseError in
//            guard let data = response else{
//                return
//            }
//           completion(data)
//        }
//    }
    
    func printHomeStruct(){
        let encoder = JSONEncoder()
        do{
            let data = try encoder.encode(Dishwasher(power: false, doorState: false, event: "", operationState: "", timeRemaining: 0, activeProgram: "", availablePrograms: [DishwasherProgram(id: "", name: "")], availableOptions: [DishwasherOption(id: 0, name: "", available: false, state: false)], programProgress: 0, startTime: ""))
            print("Home structure template.....\n")
            print(String(data: data, encoding: .utf8) ?? "")
            print("\n.....eof")
        }catch{
            print("home struct couldn't be converted into template. aborting.")
            return
        }
    }    
}
