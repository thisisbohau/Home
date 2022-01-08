//
//  CalendarSettings.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.10.21.
//

import SwiftUI
import EventKit

struct CalendarSettings: View {
    @ObservedObject var calendar = CalendarKit()
    @State var current: String = ""
    func setCalendar(calendar: EKCalendar){
        let _ = Keychain.save(key: "EventCalendar", data: String(calendar.calendarIdentifier).data(using: .utf8) ?? Data())
    }
    func update(){
        guard let calendar = self.calendar.calendars.first(where: {$0.calendarIdentifier == String(data:Keychain.load(key: "EventCalendar") ?? Data(), encoding: .utf8) ?? ""}) else{return}
        current = calendar.title
    }
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("Calendar")
                    .font(.title.bold())
                Spacer()
            }.padding(.top)
            
            Text(current)
                .foregroundStyle(.secondary)
            Menu(content: {
                ForEach(self.calendar.calendars, id: \.self){calendar in
                    Button(action: {setCalendar(calendar: calendar)}){
                        Text(calendar.title)
                    }
                }
            }, label: {
                Text("Set New")
                    .padding([.leading, .trailing], 13)
                    .padding([.top, .bottom], 7)
                    .background(Color.accentColor)
                    .foregroundColor(.black)
                    .cornerRadius(30)
                    .padding(.top, 10)
            })
            
            Text("The selected calendar will be used for your Morning Summary.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        
//        Section(header: Text("Calendar sync")){
//            VStack(alignment: .leading){
//                Text("Show events from:")
//                    .bold()
//                Text(current)
//                    .foregroundColor(.secondary)
//                    .font(.caption)
//
//                Menu("Set Calendar"){
//                    ForEach(self.calendar.calendars, id: \.self){calendar in
//                        Button(action: {setCalendar(calendar: calendar)}){
//                            Text(calendar.title)
//                        }
//                    }
//                }
//            }.padding(10)
//        }
        .onChange(of: calendar.calendars, perform: {_ in update()})
    }
}

struct CalendarSettings_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSettings()
    }
}
