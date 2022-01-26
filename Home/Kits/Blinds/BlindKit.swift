//
//  BlindKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.06.21.
//

import Foundation

class BlindKit{
    func setBlind(blind: Blind){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "set"))
            queries.append(URLQueryItem(name: "position", value: "\(blind.position.description)"))
            queries.append(URLQueryItem(name: "id", value: blind.id))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.blind, queries: queries)
        }
    }
    
    func closeFloor(floor: Int){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "closeFloor"))
            queries.append(URLQueryItem(name: "floor", value: String(floor)))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.blind, queries: queries)
        }
    }
    
    func openFloor(floor: Int){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "openFloor"))
            queries.append(URLQueryItem(name: "floor", value: String(floor)))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.blind, queries: queries)
        }
    }
    
    
}
