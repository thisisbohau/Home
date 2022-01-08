//
//  NukiKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import Foundation

class NukiKit{
    func toggleLock(lock: Nuki, newState: Bool){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: lock.id.description))
            queries.append(URLQueryItem(name: "action", value: "toggle"))
            queries.append(URLQueryItem(name: "state", value: newState.description))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.nukiKit, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.nukiKit, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func lockNGo(lock: Nuki){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: lock.id.description))
            queries.append(URLQueryItem(name: "action", value: "lockNGo"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.nukiKit, queries: queries)
        }
//            let requestURL = Updater().getRequestURL(directory: directories.nukiKit, queries: queries)
//            Updater().makeActionRequest(url: requestURL){response in
//                print(String(data: response, encoding: .utf8) ?? "")
//            }
    }
}
