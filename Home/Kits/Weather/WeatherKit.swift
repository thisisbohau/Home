//
//  WeatherKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.06.21.
//

import Foundation
import SwiftUI

class WeatherKit{
    
    func getWeatherColors(condition: Int) -> [Color]{
        switch condition{
        case 1:
            //clear day
            return [.teal, .orange]
        case 2:
            //clear night
            return [.teal, .blue]
        case 3:
            //cloud day
            return [.teal, .blue]
        case 4:
            //cloud night
            return [.teal, .blue]
        case 5:
            //rain
            return [.teal, .blue]
        case 6:
            //thunder
            return [.teal, .blue]
        case 7:
            //snow
            return [.teal, .blue]
        default:
            return [.teal, .blue]
        }
    }
    func getWeatherColor(condition: Int) -> Color{
        switch condition{
        case 1:
            //clear day
            return .orange
        case 2:
            //clear night
            return .teal
        case 3:
            //cloud day
            return .teal
        case 4:
            //cloud night
            return .cyan
        case 5:
            //rain
            return .teal
        case 6:
            //thunder
            return Color.cyan
        case 7:
            //snow
            return .white
        default:
            return .teal
        }
    }
    func getWeatherIcon(condition: Int) -> String{
        switch condition{
        case 1:
            //clear day
            return "sun.max"
        case 2:
            //clear night
            return "moon.stars"
        case 3:
            //cloud day
            return "cloud.sun"
        case 4:
            //cloud night
            return "cloud.moon"
        case 5:
            //rain
            return "cloud.rain"
        case 6:
            //thunder
            return "cloud.bolt"
        case 7:
            //snow
            return "cloud.snow"
        default:
            return "cloud.snow"
        }
    }
    
    func getWeatherDescription(condition: Int) -> String{
        switch condition{
        case 1:
            //clear day
            return "Sunny"
        case 2:
            //clear night
            return "Clear"
        case 3:
            //cloud day
            return "Overcast"
        case 4:
            //cloud night
            return "Cloudy"
        case 5:
            //rain
            return "Rain"
        case 6:
            //thunder
            return "Thunderstorm"
        case 7:
            //snow
            return "Snowy"
        default:
            return ""
        }
    }
}
