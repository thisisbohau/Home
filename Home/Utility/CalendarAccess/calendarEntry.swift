//
//  calendarEntry.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.10.21.
//

import SwiftUI
import EventKit

struct calendarEntry: View {
    var entry: EKEvent
    
    
    var body: some View {
        HStack{
            Rectangle()
                .frame(width: 5)
                .foregroundColor(Color(entry.calendar.cgColor))
                .cornerRadius(30)
                .padding([.top, .bottom], 1)
            HStack{
                VStack(alignment: .leading){
                    Text(entry.title)
                        .foregroundStyle(.primary)
                    Text(entry.location ?? "")
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                   
                }
                Spacer()
            }
            .padding(10)
            .background(ZStack{
                Color(entry.calendar.cgColor)
                    .overlay(Material.regularMaterial)
            })
            .cornerRadius(7)
           
        }
//            .background()
            
  
    }
}

//struct calendarEntry_Previews: PreviewProvider {
//    static var previews: some View {
//        calendarEntry()
//    }
//}
