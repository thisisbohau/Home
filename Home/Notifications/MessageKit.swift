//
//  MessageKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 18.07.21.
//

import Foundation

struct Notification: Identifiable, Codable{
    var id: Int
    var title: String
    var message: String
    var icon: String
    var priority: Bool
}

class MessageKit{
    
}
