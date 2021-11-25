//
//  SwitchKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import Foundation

class SwitchKit{
    func toggle(id: Int){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "id", value: id.description))
        queries.append(URLQueryItem(name: "mode", value: "toggle"))
                       
        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func set(id: Int, newValue: Bool){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "id", value: id.description))
        queries.append(URLQueryItem(name: "mode", value: "switchBool"))
        queries.append(URLQueryItem(name: "value", value: newValue.description))
                       
        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func setInt(id: Int, newValue: Int){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "id", value: id.description))
        queries.append(URLQueryItem(name: "mode", value: "switchInt"))
        queries.append(URLQueryItem(name: "value", value: newValue.description))
                       
        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    
    func setString(id: Int, newValue: String){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "id", value: id.description))
        queries.append(URLQueryItem(name: "mode", value: "switchString"))
        queries.append(URLQueryItem(name: "value", value: newValue))
                       
        let requestURL = Updater().getRequestURL(directory: directories.switchKit, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    
}
