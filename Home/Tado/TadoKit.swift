//
//  TadoKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 25.06.21.
//

import Foundation
import SwiftUI

class TadoKit{
    
    /// Checks if the current humidity is inside the recommended nominal range
    /// - Parameter tado: the device that should be checked
    /// - Returns: 0 -> below nominal, 1 -> inside range, 2 -> above nominal
    func humidityIsNominal(tado: TempDevice) -> Int{
        let humidity: Int = Int(tado.humidity)
        let range = 35...55
        if range.contains(humidity){
            return 1
        }else if humidity < range.lowerBound{
            return 0
        }else if humidity > range.upperBound{
            return 2
        }
        return 1
    }
    func getTempColor(temp: Float) -> Color{
        var color: Color = .green
        if 0.0...15.0 ~= (Double(temp)){
            //cold
            color = Color(uiColor: .systemMint)
        }else if 15.1...20.0 ~= (Double(temp)){
            color = Color(uiColor: .yellow)
        }else if 20.1...23.0 ~= (Double(temp)){
            color = Color(uiColor: .orange)
        }else{
            //hot
            color = Color(uiColor: .red)
        }
        return color
    }
    func setTemp(device: TempDevice){
        var queries = [URLQueryItem]()
 
        queries.append(URLQueryItem(name: "id", value: device.id))
        queries.append(URLQueryItem(name: "type", value: device.isAC ? "COOL" : "HEAT"))
        queries.append(URLQueryItem(name: "temp", value: device.setTemp.description))
        queries.append(URLQueryItem(name: "action", value: "temp"))
//        if device.isAC{
//            queries.append(URLQueryItem(name: "fanSpeed", value: device.))
//        }
//        var newState = light.state
//        newState.toggle()
        
        let requestURL = Updater().getRequestURL(directory: directories.tado, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    
    func backToAuto(device: TempDevice){
        var queries = [URLQueryItem]()
        
        queries.append(URLQueryItem(name: "id", value: device.id))
        queries.append(URLQueryItem(name: "type", value: device.isAC ? "COOL" : "HEAT"))
        queries.append(URLQueryItem(name: "action", value: "mode"))
        queries.append(URLQueryItem(name: "mode", value: "auto"))
        let requestURL = Updater().getRequestURL(directory: directories.tado, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
}
