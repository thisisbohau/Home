////
////  irrigationPlanner.swift
////  Home
////
////  Created by David Bohaumilitzky on 29.04.21.
////
//
import Foundation


struct irrigationMode: Identifiable{
    var id: Int
    var description: String
}
struct irrigationZone: Identifiable, Codable{
    var id: String
    var name: String
    var active: Bool
}
struct irrigationSystem: Codable{
    var controlValveActive: Bool
    var zones: [irrigationZone]
    var pumpStatus: Bool
    var refillActive: Bool
    var active: Bool
    var secondsRemaining: Int
    var irrigationDuration: Int
    var fault: Bool
    var schedule: [TimeSlot]
    var secondarySchedule: [TimeSlot]
    var mode: Int
    var paused: Bool
}


extension JSONDecoder {
    func decode<T: Codable>(_ type: T, string: String) throws -> T {
        do{
            let data = try decode(T.self, from: string.data(using: .utf8)!)
            return data
        }catch{
            print(error.localizedDescription)
            return type
        }
    }
}

extension JSONEncoder {
    func encodeJSONObject<T: Encodable>(_ value: T) throws -> String {
        do {
            let data = try encode(value)
            let string = String(data: data, encoding: .utf8)!
            return string
        }catch{
            return ""
        }
    }
}

//class Irrigation: ObservableObject{
//    @Published var systemStatus: irrigationSystem = irrigationSystem(controlValveActive: false, zones: [irrigationZone](), pumpStatus: false, refillActive: false, active: false, secondsRemaining: 0, irrigationDuration: 0, fault: false, schedule: [TimeSlot](), secondarySchedule: [TimeSlot](), mode: 1, rain: false, paused: false)
//    @Published var statusModes: [irrigationMode] = [irrigationMode(id: 0, description: "error"), irrigationMode(id: 1, description: "Auto Mode"), irrigationMode(id: 2, description: "Paused"), irrigationMode(id: 3, description: "Rain"), irrigationMode(id: 4, description: "Manual Mode"), irrigationMode(id: 5, description: "Winter Mode")]
//    
////    func getStatus(data: Data) -> irrigationSystem{
//////        let decoder = JSONDecoder()
//////        do{
//////            let array = try decoder.decode([irrigationSystem](), string: String(data: data, encoding: .utf8)!)
//////            guard let status =  array.first else{
//////                return systemStatus
//////            }
//////            return status
//////        }catch{
//////            print("decoding failed.")
//////            return systemStatus
//////        }
////    }
//    
//    func panicMode(){
//        let action = URLQueryItem(name: "action", value: "panic")
//        let url = ServerData().getRequestURL(directory: directories.irrigation, queries: [action])
//        ServerData().makeRequest(url: url){data in
//            return
//        }
//    }
//    func pauseSchedule(){
//        let action = URLQueryItem(name: "action", value: "pauseSchedule")
//        let url = ServerData().getRequestURL(directory: directories.irrigation, queries: [action])
//        ServerData().makeRequest(url: url){data in
//            return
//        }
//    }
//    
//    func returnToAuto(){
//        let action = URLQueryItem(name: "action", value: "returnToAuto")
//        let url = ServerData().getRequestURL(directory: directories.irrigation, queries: [action])
//        ServerData().makeRequest(url: url){data in
//            return
//        }
//    }
//    
//    func startManualIrrigation(zone: irrigationZone, time: Int){
//        //start irrigation
//        let Action = URLQueryItem(name: "action", value: "manualIrrigation")
//        let Zone = URLQueryItem(name: "zone", value: String(zone.id))
//        let Time = URLQueryItem(name: "time", value: String(time))
//        let url = ServerData().getRequestURL(directory: directories.irrigation, queries: [Action, Zone, Time])
//        ServerData().makeRequest(url: url){data in
//#if !os (tvOS)
//            notifications().sendNotificationWithContent(id: "manual", inSeconds: time+5, title: "\(zone.name) finished", content: "Irrigation has ended.")
//            #endif
//            return
//        }
//    }
//    
//    func stopManualIrrigation(){
//        let action = URLQueryItem(name: "action", value: "stopManualIrrigation")
//        let url = ServerData().getRequestURL(directory: directories.irrigation, queries: [action])
//        ServerData().makeRequest(url: url){data in
//#if !os (tvOS)
//            notifications().invalidateNotificationForId(id: "manual")
//            #endif
//            return
//        }
//    }
//}
//
struct TimeSlot: Identifiable, Codable{
    var id: Int
    var minutes: Int
    var time: String
}

class IrrigationKit{
    @Published var statusModes: [irrigationMode] = [irrigationMode(id: 0, description: "error"), irrigationMode(id: 1, description: "Auto Mode"), irrigationMode(id: 2, description: "Paused"), irrigationMode(id: 3, description: "Rain"), irrigationMode(id: 4, description: "Manual Mode"), irrigationMode(id: 5, description: "Winter Mode")]
    
    func pauseSchedule(){
        let action = URLQueryItem(name: "action", value: "pauseSchedule")
        let url = Updater().getRequestURL(directory: directories.irrigation, queries: [action])
        Updater().makeRequest(url: url){data, error in
            return
        }
    }

    func returnToAuto(){
        let action = URLQueryItem(name: "action", value: "returnToAuto")
        let url = Updater().getRequestURL(directory: directories.irrigation, queries: [action])
        Updater().makeRequest(url: url){data, error in
            return
        }
    }
    
        func startManualIrrigation(zone: irrigationZone, time: Int){
            //start irrigation
            let Action = URLQueryItem(name: "action", value: "manualIrrigation")
            let Zone = URLQueryItem(name: "zone", value: String(zone.id))
            let Time = URLQueryItem(name: "time", value: String(time))
            let url = Updater().getRequestURL(directory: directories.irrigation, queries: [Action, Zone, Time])
            Updater().makeActionRequest(url: url, completion: {data in
                
            })
//            Updater().makeRequest(url: url){data, error in
//    #if !os (tvOS)
//                notifications().sendNotificationWithContent(id: "manual", inSeconds: time+5, title: "\(zone.name) finished", content: "Irrigation has ended.")
//                #endif
//                return
            
        }

        func stopManualIrrigation(){
            let action = URLQueryItem(name: "action", value: "stopManualIrrigation")
            let url = Updater().getRequestURL(directory: directories.irrigation, queries: [action])
            Updater().makeRequest(url: url){data, error in
    #if !os (tvOS)
//                notifications().invalidateNotificationForId(id: "manual")
                #endif
                return
            }
        }
    
    func getLocalTimeFromUnix(unix: String) -> String{
        let double = Double(unix) ?? 0
        let date = Date(timeIntervalSince1970: double)
        let format = DateFormatter()
         
        format.timeZone = .current
        format.timeStyle = .short
         
        let dateString = format.string(from: date)
        return dateString
    }
    func modifySchedule(slot: TimeSlot, name: String){
        let action = URLQueryItem(name: "action", value: "schedule")
        let zone = URLQueryItem(name: "zone", value: String(slot.id))
        let time = URLQueryItem(name: "unix", value: String(slot.time))
        let minutes = URLQueryItem(name: "minutes", value: String(slot.minutes))
        let url = Updater().getRequestURL(directory: directories.irrigation, queries: [action, zone, time, minutes])
        Updater().makeRequest(url: url){data, error in
            print(String("slot modified: \(String(data: data ?? Data(), encoding: .utf8))"))
#if !os (tvOS)

//            notifications().invalidateNotificationForId(id: "irrigation\(slot.id)")
//            notifications().scheduleNotification(id: "irrigation\(slot.id)", date: Date(timeIntervalSince1970: Double(slot.time)!), title: "\(name) now irrigating", body: "Run time: \(slot.minutes) minutes")
#endif
            return
            
        }
    }
    
    func getNextStart(irrigation: irrigationSystem) -> Date?{
        var startTimes = irrigation.schedule.map({Date(timeIntervalSince1970: Double($0.time)!)})
        let secondary = irrigation.secondarySchedule.map({Date(timeIntervalSince1970: Double($0.time)!)})
        
        startTimes.append(contentsOf: secondary)
        
        let cal = Calendar.current
        let nowComponents = cal.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: Date())
        let nowMinsIntoDay = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
        let datesWithMinsFromNow = startTimes.map { (date) -> (Date, Int) in
            let comp = cal.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: date)
            let minsFromNow = (comp.hour ?? 0) * 60 + (comp.minute ?? 0) - nowMinsIntoDay
            return (date, minsFromNow)
        }
        let datesLaterThanNow = datesWithMinsFromNow.filter { return $0.1 >= 0 }
        let sortedDates = datesLaterThanNow.sorted { $0.1 < $1.1 }
        let closest = sortedDates.first?.0 // closest should now be a `Date` object

        return closest
    }
    
    func getZoneName(id: Int, system: irrigationSystem) -> String{
        switch id{
        case 1:
            return system.zones.first(where: {$0.id == String(1)})?.name ?? ""
        case 2:
            return system.zones.first(where: {$0.id == String(2)})?.name ?? ""
        case 3:
            return system.zones.first(where: {$0.id == String(3)})?.name ?? ""
        case 4:
            return system.zones.first(where: {$0.id == String(4)})?.name ?? ""
        case 5:
            return system.zones.first(where: {$0.id == String(1)})?.name ?? ""
        case 6:
            return system.zones.first(where: {$0.id == String(2)})?.name ?? ""
        case 7:
            return system.zones.first(where: {$0.id == String(3)})?.name ?? ""
        case 8:
            return system.zones.first(where: {$0.id == String(4)})?.name ?? ""
        default:
            return ""
        }
    }
    
    func getModeDescription(system: irrigationSystem) -> String{
        switch system.mode{
        case 0:
            return "Home has detected an error condition. For your safety manual intervention has been disabled."
        case 1:
            return "Home is autonomously controlling irrigation, adapting to weather conditions as needed."
        case 2:
            return "The regular irrigation cycle has been paused manually. Home will return to normal operation after 24h."
        case 3:
            return "Rain has been detected. Home will resume normal operation once the weather improves."
        case 4:
            return "Manual override active. Safeties are not affected and Home will intervene when necessary."
        case 5:
            return "The system is in Winter Mode. Schedule and manual irrigation is disabled."
        default:
            return "Unknown status"
        }
    }
}
