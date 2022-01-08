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
    
    func fetchLight(light: Light) async -> Light {
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "status"))
        queries.append(URLQueryItem(name: "id", value: light.id))
        
        let response = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.light, queries: queries)
        
        let StringData = response?.data(using: .utf8)
        let decoder = JSONDecoder()
        do{
            let Light = try decoder.decode(Light.self, from: StringData ?? Data())
            print("new status\(Light)")
            return Light
            
        }catch{
            print("error while decoding light status onDemand\(error.localizedDescription)")
            print(String(data: StringData ?? Data(), encoding: .utf8) ?? "")
            return light
        }
    }
    
    /// Changes the Color of the given instance.
    /// - Parameter light: a modifiable light instance
    /// - Important This method must only be used for lights that are color changeable.  For adapting brightness use  `setBrightness`
    /// - Warning: Calling this method repeatedly can result in a serious backlog. Always check before if a update is required.
    func setColor(light: Light){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "setColor"))
            queries.append(URLQueryItem(name: "type", value: light.type))
            queries.append(URLQueryItem(name: "h", value: "\(light.hue.description)"))
            queries.append(URLQueryItem(name: "s", value: "\(light.saturation.description)"))
            queries.append(URLQueryItem(name: "b", value: "\(light.brightness.description)"))
            queries.append(URLQueryItem(name: "id", value: light.id))
            
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.light, queries: queries)
            
        }
    }
    
    /// Only changes the brightness parameter of the given instance for increased performance.
    /// - Parameter light: the light instance of type HUEC or MXCD.
    /// - Important Providing an instance that is not dimmable will have no effect can can result in unexpected behaviour.
    func setBrightness(light: Light){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "setBrightness"))
            queries.append(URLQueryItem(name: "type", value: light.type))
            queries.append(URLQueryItem(name: "b", value: "\(light.brightness.description)"))
            queries.append(URLQueryItem(name: "newState", value: String(light.state.description)))
            queries.append(URLQueryItem(name: "id", value: light.id))

            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.light, queries: queries)
        }
    }
    
    ///  This method will adapt all given  lights using the autoAdapt algorithm and return when all lights have been adapted
    /// - Parameter lights: An array containing all lights to be changed. If only one light should be modified, include an array with a single value.
    func autoAdaptLights(lights: [Light]) async{
        let lightString = lights.compactMap({$0.id}).joined(separator: ",")
        
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "autoAdapt"))
        queries.append(URLQueryItem(name: "lights", value: lightString))
        
        let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.light, queries: queries)
        
    }


}
