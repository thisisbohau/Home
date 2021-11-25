//
//  LightKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 11.06.21.
//

import Foundation
import SwiftUI
import Combine

struct ColorPreset: Identifiable, Codable{
    var id: Int
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
//    var color: Color
}

class LightKit{
    func getPresets() -> [ColorPreset]{
        var presets: [ColorPreset] = [ColorPreset]()
        
        for id in 1...6{
            guard let preset = fetchPreset(id: id)else{
                let Preset = ColorPreset(id: id, hue: 0, saturation: 0, brightness: 0)
                savePreset(preset: Preset)
                continue
            }
            presets.append(preset)
        }
        return presets
    }
    func savePreset(preset: ColorPreset){
        
            let encoder = JSONEncoder()

                if let data = try? encoder.encode(preset) {
                    NSUbiquitousKeyValueStore.default.set(data, forKey: preset.id.description)
                }
            

        
    }
    func fetchPreset(id: Int) -> ColorPreset?{
        let decoder = JSONDecoder()
        if let object = try? decoder.decode(ColorPreset.self, from: NSUbiquitousKeyValueStore.default.data(forKey: id.description) ?? Data()) {
            return object
        }else{
            return nil
        }
    }
    func setLight(light: Light){
        var queries = [URLQueryItem]()
        
        queries.append(URLQueryItem(name: "type", value: light.type))
        queries.append(URLQueryItem(name: "h", value: "\(light.hue.description)"))
        queries.append(URLQueryItem(name: "s", value: "\(light.saturation.description)"))
        queries.append(URLQueryItem(name: "b", value: "\(light.brightness.description)"))
        queries.append(URLQueryItem(name: "newState", value: String(light.state.description)))
        queries.append(URLQueryItem(name: "id", value: light.id))

        let requestURL = Updater().getRequestURL(directory: directories.light, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    func toggleLight(light: Light){
        var queries = [URLQueryItem]()
        if light.isHue{
            queries.append(URLQueryItem(name: "type", value: "HUE"))
        }else{
            queries.append(URLQueryItem(name: "type", value: "MXC"))
        }
        queries.append(URLQueryItem(name: "id", value: light.id))
        var newState = light.state
        newState.toggle()
        queries.append(URLQueryItem(name: "newState", value: String(newState.description)))
        print(Updater().getRequestURL(directory: directories.light, queries: queries))
//        Updater().makeActionRequest(url: <#T##URL#>){response in
//
//        }
    }
}
