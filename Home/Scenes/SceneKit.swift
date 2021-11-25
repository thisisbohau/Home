//
//  SceneKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 01.07.21.
//

import Foundation
import SwiftUI
//import FirebaseDatabase

func getLocalWeekdayFromSwiftDate() -> Int{
    let day = Calendar.current.component(.weekday, from: Date())
    
    switch day{
    case 1:
        return 7
    case 2:
        return 1
    case 3:
        return 2
    case 4:
        return 3
    case 5:
        return 4
    case 6:
         return 5
    case 7:
        return 6
    default:
        return 0
    }
}

struct Schedule: Identifiable, Codable{
    var id: Int
    var time: String
}
struct SceneAutomation: Identifiable, Codable{
    var id: Int
    var name: String
    var lights: [Light]
    var blinds: [Blind]
    var tado: [TempDevice]
    var active: Bool
    var schedule: [Schedule]?
    var room: Int?
    var icon: String?
}
struct Icon: Identifiable{
    var id: String
    var color: Color
}


class SceneKit: ObservableObject{
    @Published var settingScene: Bool = false
    
    var sceneIcons: [Icon] = [
        Icon(id: "sun.max.fill", color: .yellow), Icon(id: "moon.fill", color: .indigo), Icon(id: "suit.heart.fill", color: .pink), Icon(id: "bed.double.fill", color: .indigo), Icon(id: "fork.knife", color: .orange), Icon(id: "car.fill", color: .teal), Icon(id: "drop.fill", color: .blue), Icon(id: "exclamationmark.triangle.fill", color: .red)
    ]
    func createScene(scene: SceneAutomation){
        var queries = [URLQueryItem]()
        do{
            let data = try JSONEncoder().encodeJSONObject(scene)
            queries.append(URLQueryItem(name: "data", value: data))
            queries.append(URLQueryItem(name: "action", value: "create"))
                           
            let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
            Updater().makeActionRequest(url: requestURL){response in
                print(String(data: response, encoding: .utf8) ?? "")
            }
        }catch{
            return
        }
    }
    func editScene(scene: SceneAutomation){
        var queries = [URLQueryItem]()
        do{
            let data = try JSONEncoder().encodeJSONObject(scene)
            queries.append(URLQueryItem(name: "data", value: data))
            queries.append(URLQueryItem(name: "action", value: "edit"))
                           
            let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
            Updater().makeActionRequest(url: requestURL){response in
                print(String(data: response, encoding: .utf8) ?? "")
            }
        }catch{
            return
        }
    }
    
    func deleteScene(scene: SceneAutomation){
        var queries = [URLQueryItem]()
        do{
            let data = try JSONEncoder().encodeJSONObject(scene)
            queries.append(URLQueryItem(name: "data", value: data))
            queries.append(URLQueryItem(name: "action", value: "delete"))
                           
            let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
            Updater().makeActionRequest(url: requestURL){response in
                print(String(data: response, encoding: .utf8) ?? "")
            }
        }catch{
            return
        }
    }
    
    func setScene(scene: SceneAutomation){
        withAnimation(.linear, {settingScene = true})
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "run"))
        queries.append(URLQueryItem(name: "id", value: scene.id.description))
        let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                withAnimation(.linear, {self.settingScene = false})
            })
        }
    }
    
    func roomOff(room: Room){
        withAnimation(.linear, {settingScene = true})
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "roomOff"))
        queries.append(URLQueryItem(name: "id", value: room.id.description))
        let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                withAnimation(.linear, {self.settingScene = false})
            })
        }
    }
    
    func floorOff(floor: Int, completion: @escaping(Bool) -> Void){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "floorOff"))
        queries.append(URLQueryItem(name: "floor", value: floor.description))
        let requestURL = Updater().getRequestURL(directory: directories.scene, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            if String(data: response, encoding: .utf8) ?? "" == "true"{
                completion(true)
            }else{
                completion(false)
            }
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func getRunTimeToday(scene: SceneAutomation) -> String{
        let index = getLocalWeekdayFromSwiftDate()
//        print("index: \(index)")
        guard let unix = scene.schedule?.first(where: {$0.id == index})?.time else{
            return ""
        }
        
        return IrrigationKit().getLocalTimeFromUnix(unix: unix)
        
    }
    func getScheduledScenes(scenes: [SceneAutomation]) -> [SceneAutomation]{
        var matches: [SceneAutomation] = [SceneAutomation]()
        let index = getLocalWeekdayFromSwiftDate()
        for scene in scenes{
            if scene.schedule?.contains(where: {$0.id == index}) ?? false{
                let times = scene.schedule
                let unixs = times?.compactMap({Date(timeIntervalSince1970: Double($0.time) ?? 0)})
                if (unixs?.contains(where: {$0 < Date()})) ?? false{
                    matches.append(scene)
                }
            }
            
        }
        return matches
    }

    
    func getDay(id: Int) -> String{
        switch id{
        case 1:
            return "Monday"
        case 2:
            return "Tuesday"
        case 3:
            return "Wednesday"
        case 4:
            return "Thursday"
        case 5:
            return "Friday"
        case 6:
            return "Saturday"
        case 7:
            return "Sunday"
        default:
            return ""
        }
    }
    func getShortDayDescription(id: Int) -> String{
        switch id{
        case 1:
            return "Mon"
        case 2:
            return "Tue"
        case 3:
            return "Wed"
        case 4:
            return "Thu"
        case 5:
            return "Fri"
        case 6:
            return "Sat"
        case 7:
            return "Sun"
        default:
            return ""
        }
    }
}
