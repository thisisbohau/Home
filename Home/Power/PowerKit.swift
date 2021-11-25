//
//  PowerKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 17.06.21.
//

import Foundation

struct PowerMetrics: Codable{
    var usageToday: Int
    var solarProductionToday: Int
    var autarkie: Int
    var batteryBackupMinutes: Int
}
struct PowerOutage: Codable{
    var outage: Bool
    var message: String
    var minutesRemaining: Int
    var kwRemaining: Int
}
struct PowerSplit: Codable{
    var grid: Int
    var solar: Int
    var battery: Int
    var combinedUsage: Int
}
struct SolarSplit: Codable{
    var system1: Int
    var system2: Int
    var combinedProduction: Int
    var dailyProduction: Int
    var batteryCharging: Int
    var homeUsage: Int
    var gridFeed: Int
}

class PowerKit{
    func getBatteryChargingState(usage: Int) -> Bool{
        if usage > 0{
            //charging
            return true
        }else{
            //discharging
            return false
            
        }
    }
    
    func formatUsageNoSuffix(value: Int) -> String{
        if value < 0{
            if value < 1000{
                let format: Double  = Double(value * -1) / Double(1000)
                return "\(String(format: "%.1f", format))"
            }else{
                return "\(value) W"
            }
        }else{
            let format: Double  = Double(value) / Double(1000)
            return "\(String(format: "%.1f", format))"
        }
    }
    
    func formatUsage(value: Int) -> String{
        if value < 0{
            if value < 1000{
                let format: Double  = Double(value * -1) / Double(1000)
//                print(format.description)
                
                return "\(String(format: "%.1f", format.rounded(.up))) kW"
            }else{
                return "\(value) W"
            }
        }else{
            if value > 1000{
                let format: Double  = Double(value) / Double(1000)
//                print(format.description)
                
                return "\(String(format: "%.1f", format.rounded(.up))) kW"
            }else{
                return "\(value) W"
            }
        }
    
//        return ""
    }
}
