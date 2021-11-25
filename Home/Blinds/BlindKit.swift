//
//  BlindKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.06.21.
//

import Foundation

class BlindKit{
    func setBlind(blind: Blind){
        var queries = [URLQueryItem]()
        
        queries.append(URLQueryItem(name: "position", value: "\(blind.position.description)"))

        
        queries.append(URLQueryItem(name: "id", value: blind.id))
    
        
        let requestURL = Updater().getRequestURL(directory: directories.blind, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "No response from sever.")
        }
    }
}
