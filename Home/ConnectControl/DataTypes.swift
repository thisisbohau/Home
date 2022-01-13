//
//  deviceLists.swift
//  Home
//
//  Created by David Bohaumilitzky on 23.04.21.
//

import Foundation
import CloudKit

struct Session: Identifiable, Codable{
    var id: String
    var name: String
    var deviceToken: String
    var date: String
    var role: Int
}
enum RecordTypes: String{
    case light = "Light"
    case zone = "Zone"
}

struct Morning: Codable{
    var destinations: [LocationDestination]
    var wakeUpTime: String
    var arrivalTime: String
    var nextDestinationId: Int
    var showBedtime: Bool
    var showMorning: Bool
}

struct DogMode: Codable{
    var active: Bool
    var analyzing: Bool
    var state: Int
}
struct Switch: Identifiable, Codable{
    var id: Int
    var state: Bool
    var name: String
    var description: String
}
struct CatchUp: Codable{
    var state: Bool
    var r: Float
    var g: Float
    var b: Float
    var brightness: Float
    var mode: String
}
struct WindowSensor: Identifiable, Codable{
    var id: Int
    var name: String
    var state: Bool
    var lastUpdate: String
}
struct Nuki: Codable{
    var id: Int
    var state: Bool
    var battery: Int
    var door: Int
}
struct GarageDoor: Codable{
    var state: Bool
    var latch: Blind
    var openedAt: String
}

struct Power: Codable{
    var systemMode: Int
    var powerOutage: PowerOutage?
    var powerSplit: PowerSplit
    var solar: SolarSplit
    var metrics: PowerMetrics
    var batteryState: Int
}
struct Light: Identifiable, Codable{
    var id: String
    var name: String
    var isHue: Bool
    var isDimmable: Bool
    var reachable: Bool
    var type: String
    var hue: Float
    var saturation: Float
    var brightness: Float
    var state: Bool
    var parts: [Light]?
}
struct Blind: Identifiable, Codable{
    var id: String
    var name: String
    var position: Int
    var moving: Bool
}
struct TempDevice: Identifiable, Codable{
    var id: String
    var isAC: Bool
    var name: String
    var manualMode: Bool
    var active: Bool
    var openWindow: Bool
    var temp: Float
    var setTemp: Float
    var humidity: Float
    var performance: Int
}

struct Room: Identifiable, Codable{
    var id: Int
    var name: String
    var floor: Int
    var lights: [Light]
    var blinds: [Blind]
    var tempDevices: [TempDevice]
    var type: RoomType
    var occupied: Bool
    var lastOccupied: String
    var openWindow: Bool
    var windows: [WindowSensor]
}
struct Mower: Codable{
    var nextStart: String
    var mode: Int
    var status: Int
    var battery: Int
    var manual: Bool
    var schedulePaused: Bool
    var error: String
}
struct Pool: Codable{
    var temp: Float
    var pH: Float
    var aCl: Float
    var pumpActive: Bool
}
struct Weather: Codable{
    var currentTemp: Float
    var low: Float
    var hight: Float
    var humidity: Float
    var condition: Int
    var rainCurrent: Float
    var rainToday: Float
    var lastUpdate: String
    var rain: Bool
    var heavyRain: Bool
    var weatherAdaption: Switch
}

struct Device: Identifiable, Codable{
    var id: String
    var role: Int
    var home: Bool
    var name: String
    var lat: Float
    var lon: Float
    var speed: Float
    var fcmToken: String
    var lastHome: String
}
struct Lockdown: Codable{
    var triggered: Bool
    var recommenced: Bool
    var reason: String
    var triggeredAt: String
}
struct Geofence: Codable{
    var home: Bool
    var people: [Device]
}
struct LaundryDevice: Codable, Identifiable{
    var id: Int
    var name: String
    var activeCycle: Bool
    var powerUsage: Int
    var consumptionToday: Float
    var cycleStarted: String
    var cyclesToday: Int
    var cycleEnded: Bool
    var cycleEndedOn: String
}
struct Sentry: Codable{
    var active: Bool
    var alarmState: Bool
    var sentryTriggered: Bool
    var triggeredOn: String
    var motionInRooms: [Int]
    var triggeredRoom: Int
    
}
struct Home: Codable{
    var rooms: [Room]
    var irrigation: irrigationSystem
    var mower: Mower
    var pool: Pool
    var weather: Weather
    var devices: [Device]
    var power: Power
    var scenes: [SceneAutomation]
    var catchUp: CatchUp
    var nuki: Nuki
    var garage: GarageDoor
    var notifications: [Notification]
    var lockdown: Lockdown
    var sentry: Sentry
    var laundry: [LaundryDevice]
    var morning: Morning
    var dogMode: DogMode
}

struct RoomType: Codable{
    var icon: String
    var color: String
}

struct DishwasherOption: Codable, Identifiable{
    var id: Int
    var name: String
    var available: Bool
}
struct DishwasherProgram: Codable, Identifiable{
    var id: Int
    var name: String
}
struct Dishwasher: Codable{
    var power: Bool
    var doorState: Bool
    var event: String?
    var operationState: String
    var timeRemaining: Int
    var activeProgram: String
    var availablePrograms: [DishwasherProgram]
    var availableOptions: [DishwasherOption]
    var programProgress: Int
    var startTime: String
}
