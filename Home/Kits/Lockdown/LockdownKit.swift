//
//  LockdownKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.08.21.
//

import Foundation

class LockdownKit{
    func activateLockdown(){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "mode", value: "activate"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.lockdown, queries: queries)
        }
//
//        let requestURL = Updater().getRequestURL(directory: directories.lockdown, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func deactivateLockdown(){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "mode", value: "deactivate"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.lockdown, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.lockdown, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
}
