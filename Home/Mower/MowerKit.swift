//
//  MowerKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 10.07.21.
//

import Foundation

class MowerKit{
    func getMode(mode: Int) -> String{
        switch mode{
        case 0:
            return "Auto"
        case 1:
            return "Manual Mode"

        default:
            return "Auto"
            
        }
    }
    func getModeDescription(mode: Int) -> String{
        switch mode{
        case 0:
            return "Auto"
        case 1:
            return "Manual Mode"
        default:
            return "Auto"
            
        }
    }
    
    func getStatus(status: Int) -> String{
        switch status{
        case 0:
            return "Updating"
        case 1:
            return "Parked"
        case 2:
            return "Mowing"
        case 3:
            return "Parking"
        case 4:
            return "Charging"
        case 5:
            return "Parking"
        case 7:
            return "Error"
        case 8:
            return "No loop"
        case 16:
            return "Off"
        case 17:
            return "Sleeping"
        default:
            return "Unknown"
            
        }
    }
    
    func getStatusIcon(status: Int) -> String{
        switch status{
        case 0:
            return "wifi"
        case 1:
            return "parkingsign.circle"
        case 2:
            return "play.fill"
        case 3:
            return "parkingsign.circle"
        case 4:
            return "Charging"
        case 5:
            return "parkingsign.circle"
        case 7:
            return "wifi.exclamationmark"
        case 8:
            return "wifi.exclamationmark"
        case 16:
            return "poweroff"
        case 17:
            return "powersleep"
        default:
            return "powersleep"
            
        }
    }
    func skipSchedule(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "skip"))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func changeSchedule(newStartTime: Date){
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: newStartTime)
        let startMinute = calendar.component(.minute, from: newStartTime)
        let endTime = calendar.date(byAdding: .hour, value: 2, to: newStartTime) ?? newStartTime
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "setSchedule"))
        queries.append(URLQueryItem(name: "startMin", value: String(startMinute)))
        queries.append(URLQueryItem(name: "startHour", value: String(startHour)))
        queries.append(URLQueryItem(name: "endMin", value: String(endMinute)))
        queries.append(URLQueryItem(name: "endHour", value: String(endHour)))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    
    func manualStart(minutes: Int){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "manualStart"))
        queries.append(URLQueryItem(name: "time", value: minutes.description))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func returnToAuto(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "returnToAuto"))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func stopNow(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "stop"))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func returnHome(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "park"))
        let requestURL = Updater().getRequestURL(directory: directories.mowerKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
}
