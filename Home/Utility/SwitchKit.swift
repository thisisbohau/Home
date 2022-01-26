//
//  SwitchKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import Foundation

class SwitchKit{
    func toggle(id: Int){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: id.description))
            queries.append(URLQueryItem(name: "mode", value: "toggle"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.switchKit, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    func set(id: Int, newValue: Bool){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: id.description))
            queries.append(URLQueryItem(name: "mode", value: "switchBool"))
            queries.append(URLQueryItem(name: "value", value: newValue.description))
                           
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.switchKit, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    func setInt(id: Int, newValue: Int){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: id.description))
            queries.append(URLQueryItem(name: "mode", value: "switchInt"))
            queries.append(URLQueryItem(name: "value", value: newValue.description))
                           
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.switchKit, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func setString(id: Int, newValue: String){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: id.description))
            queries.append(URLQueryItem(name: "mode", value: "switchString"))
            queries.append(URLQueryItem(name: "value", value: newValue))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.switchKit, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
}
