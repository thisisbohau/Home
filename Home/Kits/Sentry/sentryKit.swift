//
//  sentryKit.swift
//  sentryKit
//
//  Created by David Bohaumilitzky on 22.08.21.
//

import Foundation

class SentryKit{
    func resetSentry(){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "reset"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.sentry, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.sentry, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
    
    func turnOffSentry(){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "off"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.sentry, queries: queries)
        }
//        let requestURL = Updater().getRequestURL(directory: directories.sentry, queries: queries)
//        Updater().makeActionRequest(url: requestURL){response in
//            print(String(data: response, encoding: .utf8) ?? "")
//        }
    }
}
