//
//  SystemUtility.swift
//  Home
//
//  Created by David Bohaumilitzky on 29.12.21.
//

import Foundation

class SystemUtility{
    /// Converts the given unix String into a  formatted `Date` object
    /// - Parameter unix: Unix timestamp as string
    /// - Returns: the converted date as a String
    /// - Important: If the string can't be converted due to invalid characters, the current date will be returned
    func unixToDate(unix: String) -> String{
        let unix = Double(unix) ?? 0
        let converted =  Date(timeIntervalSince1970: unix)
        
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(converted){
            formatter.dateStyle = .none
        }else{
            formatter.dateStyle = .short
        }
        formatter.timeStyle = .short
        
        return formatter.string(from: converted)
    }
}
