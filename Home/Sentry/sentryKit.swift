//
//  sentryKit.swift
//  sentryKit
//
//  Created by David Bohaumilitzky on 22.08.21.
//

import Foundation

class SentryKit{
    func resetSentry(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "reset"))
                       
        let requestURL = Updater().getRequestURL(directory: directories.sentry, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    
    func turnOffSentry(){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "off"))
                       
        let requestURL = Updater().getRequestURL(directory: directories.sentry, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
}
