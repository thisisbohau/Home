//
//  CalendarList.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.10.21.
//

import SwiftUI

struct CalendarList: View {
    @ObservedObject var calendar = CalendarKit()
    
    var body: some View {
        
        VStack{
            HStack{
                Text("Upcoming")
                    .font(.title.bold())
                Spacer()
            }
            ScrollView{
            ForEach(calendar.todayEvents, id: \.self){event in
                calendarEntry(entry: event)
            }
            }
        }.padding()
    }
}

struct CalendarList_Previews: PreviewProvider {
    static var previews: some View {
        CalendarList()
    }
}
