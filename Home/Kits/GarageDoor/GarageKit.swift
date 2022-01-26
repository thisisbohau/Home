//
//  GarageKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 05.01.22.
//

import Foundation

class GarageKit{
    func toggleGarage(garage: GarageDoor, newState: Bool){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "set"))
            queries.append(URLQueryItem(name: "newState", value: newState.description))

            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.garage, queries: queries)
        }
    }
    func forceShut(garage: GarageDoor){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "forceShut"))

            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.garage, queries: queries)
        }
    }
}
