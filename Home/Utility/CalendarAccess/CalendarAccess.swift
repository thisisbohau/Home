//
//  CalendarAccess.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.10.21.
//

import Foundation
import EventKit

class CalendarKit: NSObject, ObservableObject{
    let eventStore = EKEventStore()
    @Published var todayEvents: [EKEvent] = [EKEvent]()
    @Published var calendars: [EKCalendar] = [EKCalendar]()
    
    
    override init(){
        super.init()
        getPermissions()
        
    }
    
    func getPermissions(){
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    self.fetchCalendars()
                    self.fetchEvents()
                    
                }
            }
        }
    }
    
    func fetchCalendars(){
        calendars = eventStore.calendars(for: .event)
    }
    func fetchEvents(){
        let calendar = String(data: Keychain.load(key: "EventCalendar") ?? Data(), encoding: .utf8) ?? ""
        guard let first = calendars.first(where: {$0.calendarIdentifier == calendar}) else{
//            fatalError("No calendar found")
            return
        }
        //get events from today
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: Date()) ?? Date()
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [first])
        let events = eventStore.events(matching: predicate)
//        todayEvents.removeAll()
        
//        if todayEvents.isEmpty{
        todayEvents = events
//        }
        
    }
}
