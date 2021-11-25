//
//  scheduleView.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.04.21.
//

import SwiftUI

struct IrrigationScheduleView: View {
    @Binding var active: Bool
    @Binding var status: irrigationSystem
    @State var totalTime: Int = 0
    @State var editSlot: Bool = false
    @State var selectedSlot: TimeSlot = TimeSlot(id: 0, minutes: 0, time: "")
    @State var startTime: Date = Date()
    @State var editTimeline: [TimeSlot] = [TimeSlot]()
    
    @State var editSecondarySlot: Bool = false
    @State var secondaryTotalTime: Int = 0
    @State var secondarySelectedSlot: TimeSlot = TimeSlot(id: 0, minutes: 0, time: "")
    @State var secondaryStartTime: Date = Date()
    @State var secondaryEditTimeLine: [TimeSlot] = [TimeSlot]()
    @State var secondarySlotIsActive: Bool = true
    @State var editSecondary: Bool = false
    
    func mirrorSlots(){
        let index = editTimeline.firstIndex(where: {$0.id == selectedSlot.id})
        editTimeline[index!] = selectedSlot
        totalTime = 0
        for slot in editTimeline{
            totalTime += slot.minutes
        }
    }
    func editSlot(slot: TimeSlot){
        DispatchQueue.main.async {
            self.selectedSlot = slot
            self.editSlot.toggle()
        }
    }
    func reschedule(){
        for slot in editTimeline{
            let index = editTimeline.firstIndex(where: {$0.id == slot.id}) ?? 0
            
            if editTimeline.first?.id == slot.id{
                //first in schedule
                editTimeline[0].time = String(startTime.timeIntervalSince1970)
                print("start time set: \(startTime)")
            }else{
                let previousIndex = editTimeline.firstIndex(where: {$0.id == slot.id}) ?? 1
                let startTime = Date(timeIntervalSince1970: Double(editTimeline[previousIndex-1].time) ?? 0)
                let previousEndTime = startTime.addingTimeInterval(Double(editTimeline[previousIndex-1].minutes*60))
                let newStartTime = previousEndTime.addingTimeInterval(60)
                editTimeline[index].time = String(newStartTime.timeIntervalSince1970)
            }
        }
        
        for scheduleSlot in editTimeline{
            IrrigationKit().modifySchedule(slot: scheduleSlot, name: status.zones.first(where: {$0.id == String(scheduleSlot.id)})?.name ?? "")
        }
    }
    func saveSlot(){
        reschedule()
        editSlot.toggle()
    }
    
    func mirrorSecondarySlots(){
        let index = secondaryEditTimeLine.firstIndex(where: {$0.id == secondarySelectedSlot.id})
        secondaryEditTimeLine[index!] = secondarySelectedSlot
        secondaryTotalTime = 0
        for slot in secondaryEditTimeLine{
            secondaryTotalTime += slot.minutes
        }
    }
    
    func getSecondaryName(id: Int) -> String{
        switch id{
        case 5:
            return status.zones.first(where: {$0.id == String(1)})?.name ?? ""
        case 6:
            return status.zones.first(where: {$0.id == String(2)})?.name ?? ""
        case 7:
            return status.zones.first(where: {$0.id == String(3)})?.name ?? ""
        case 8:
            return status.zones.first(where: {$0.id == String(4)})?.name ?? ""
        default:
            return ""
        }
    }
    func editSecondarySlot(slot: TimeSlot){
        DispatchQueue.main.async {
            self.secondarySelectedSlot = slot
            self.editSecondarySlot.toggle()
        }
    }
    func rescheduleSecondary(){
        for slot in secondaryEditTimeLine{
            let index = secondaryEditTimeLine.firstIndex(where: {$0.id == slot.id}) ?? 0
            
            if secondaryEditTimeLine.first?.id == slot.id{
                //first in schedule
                secondaryEditTimeLine[0].time = String(secondaryStartTime.timeIntervalSince1970)
                print("start time set: \(secondaryStartTime)")
            }else{
                let previousIndex = secondaryEditTimeLine.firstIndex(where: {$0.id == slot.id}) ?? 1
                let startTime = Date(timeIntervalSince1970: Double(secondaryEditTimeLine[previousIndex-1].time) ?? 0)
                let previousEndTime = startTime.addingTimeInterval(Double(secondaryEditTimeLine[previousIndex-1].minutes*60))
                let newStartTime = previousEndTime.addingTimeInterval(60)
                secondaryEditTimeLine[index].time = String(newStartTime.timeIntervalSince1970)
            }
        }
        
        for scheduleSlot in secondaryEditTimeLine{
            IrrigationKit().modifySchedule(slot: scheduleSlot, name: status.zones.first(where: {$0.id == String(scheduleSlot.id)})?.name ?? "")
        }
    }
    func saveSecondarySlot(){
        if !secondarySlotIsActive{
            secondarySelectedSlot.minutes = 0
        }
        rescheduleSecondary()
        editSecondarySlot.toggle()
    }
    
    func setup(){
        for slot in status.schedule{
            totalTime += slot.minutes
        }
        editTimeline = status.schedule
        
        for slot in status.secondarySchedule{
            secondaryTotalTime += slot.minutes
        }
        secondaryEditTimeLine = status.secondarySchedule
    }
    
    var secondaryTimeline: some View{
        GeometryReader{proxy in
        ScrollView{
            
                ZStack{
                    VStack{
                        ForEach(secondaryEditTimeLine){slot in
                            Button(action: {
                                editSecondarySlot(slot: slot)
                            }){
                                HStack(alignment: .center){
                                    VStack{
                                        Spacer()
                                    }
                                    .frame(width: 10)
                                    .background(Color.accentColor)
                                    .animation(.linear(duration: 0.7), value: status.secondarySchedule.description)
                                    .cornerRadius(30)
                                    
                                    VStack(alignment: .leading){
                                        Text(getSecondaryName(id: slot.id))
                                            .foregroundColor(.primary)
                                        
                                        if slot.minutes == 0{
                                            Text("Disabled")
                                                .foregroundColor(.secondary)
                                        }else{
                                            Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                            Text("\(String(slot.minutes)) min")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                    }.padding(.leading)
                                    Spacer()
                                }
                                .frame(height: CGFloat((proxy.size.height*0.90)/CGFloat(secondaryTotalTime) * CGFloat(slot.minutes)))
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom])
                                .padding(.trailing)
                            }
                        }
                    }
                }
//                    VStack{
//                        HStack{
//                            Spacer()
//                            Button(action: {active.toggle()}){
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.title)
//                                    .foregroundColor(.primary)
//                            }
//
//                        }.padding([.top, .trailing])
//                        Spacer()
//                    }
//                    VStack{
//                        HStack{
//                            Spacer()
//                            Text("Schedule")
//                                .font(.title)
//                                .bold()
//                            Spacer()
//                        }
//                        Spacer()
//                    }.padding()
                }
            }
            
            .sheet(isPresented: $editSecondarySlot){
                NavigationView{
                    VStack{
                        Form{
                            Section(header: Text("Secondary active"), footer: Text("Should this zone irrigate a second time?")){
                                Toggle("Active", isOn: $secondarySlotIsActive)
                            }
                            if secondarySlotIsActive{
                                Section(header: Text("Irrigation time"), footer: Text("Set the irrigation time for the zone.")){
                                    Picker("Irrigation time:", selection: $secondarySelectedSlot.minutes) {
                                        ForEach(0 ..< 61) {
                                            if $0 != 0{
                                                Text("\($0) minutes")
                                            }
                                        }
                                    }
                                }
                            }
#if !os (tvOS)
                            Section(header: Text("Start Time"), footer: Text("This is the start time for the first zone in the system. All other times will be scheduled automatically based on irrigation time.")){
                                DatePicker("Cycle start:", selection: $secondaryStartTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                            }
                            #endif
//                            Spacer()
                        }.padding(.top)
                        GeometryReader{proxy in
                            VStack{
                                HStack{
                                    Spacer()
                                    ForEach(secondaryEditTimeLine){slot in
                                        VStack(alignment: .center){
                                            Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                                .font(.headline.bold())
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                                .truncationMode(.tail)
                                                
                                            HStack{
                                                Spacer()
                                            }
                                            .frame(height: 10)
                                            .background(slot.id == secondarySelectedSlot.id ? Color.accentColor : Color.secondary)
                                            .animation(.linear(duration: 0.7), value: secondaryEditTimeLine.description)
                                            .cornerRadius(30)
                                            
                                            Text("\(String(slot.minutes)) min")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                                .truncationMode(.tail)
                                        }
                                        .frame(width: CGFloat((proxy.size.width*0.80)/CGFloat(secondaryTotalTime) * CGFloat( slot.id == secondarySelectedSlot.id ? secondarySelectedSlot.minutes : slot.minutes)))
                                        .padding([.leading, .trailing], 5)
                                    }
                                    Spacer()
                                }.padding(.top)
                                HStack{
                                    Spacer()
                                    Text("Changing this slot will reschedule all the other zones accordingly.")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }.padding()
                            }
                        }
                        
                        Spacer()
                        Button(action: saveSecondarySlot){
                            HStack{
                                Spacer()
                                Text("Save")
                                    .font(.body.bold())
                                Spacer()
                            }
                        }.buttonStyle(RectangleButtonStyle(color: Color.accentColor)).padding(10)
                    }.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.all))
                   .navigationTitle(getSecondaryName(id: secondarySelectedSlot.id))
                }
            }
        }


    var timeline: some View{
        GeometryReader{proxy in
            ScrollView{
            ZStack{
                VStack{
                    ForEach(editTimeline){slot in
                        Button(action: {
                            editSlot(slot: slot)
                        }){
                            HStack(alignment: .center){
                                VStack{
                                    Spacer()
                                }
                                .frame(width: 10)
                                .background(Color.accentColor)
                                .animation(.linear(duration: 0.7), value: editTimeline.description)
                                .cornerRadius(30)
                                
                                VStack(alignment: .leading){
                                    Text(String(status.zones.first(where: {$0.id == String(slot.id)})?.name ?? ""))
                                        .foregroundColor(.primary)
                                    Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                        .font(.title2.bold())
                                        .foregroundColor(.primary)
                                    Text("\(String(slot.minutes)) min")
                                        .foregroundColor(.secondary)
                                }.padding(.leading)
                                Spacer()
                            }
                            .frame(height: CGFloat((proxy.size.height*0.90)/CGFloat(totalTime) * CGFloat(slot.minutes)))
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 5)
                            .padding(.trailing)
                        }
                    }
                }
               
//                VStack{
//                    HStack{
//                        Spacer()
//                        Text("Schedule")
//                            .font(.title)
//                            .bold()
//                        Spacer()
//                    }
//                    Spacer()
//                }.padding()
            }
        }
        }
        .sheet(isPresented: $editSlot){
            NavigationView{
                VStack{
                    Form{
                        Section(header: Text("Irrigation time"), footer: Text("Set the irrigation time for the zone.")){
                            Picker("Irrigation time:", selection: $selectedSlot.minutes) {
                                ForEach(0 ..< 61) {
                                    if $0 != 0{
                                        Text("\($0) minutes")
                                    }
                                }
                            }
                        }
                        Section(header: Text("Start Time"), footer: Text("This is the start time for the first zone in the system. All other times will be scheduled automatically based on irrigation time.")){
                            DatePicker("Cycle start:", selection: $startTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                        }

                    }
                    GeometryReader{proxy in
                        VStack{
                            HStack{
                                Spacer()
                                ForEach(editTimeline){slot in
                                    VStack(alignment: .center){
                                        Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                            .font(.headline.bold())
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .truncationMode(.tail)
                                            
                                        HStack{
                                            Spacer()
                                        }
                                        .frame(height: 10)
                                        .background(slot.id == selectedSlot.id ? Color.accentColor : Color.secondary)
                                        .animation(.linear(duration: 0.7), value: editTimeline.description)
                                        .cornerRadius(30)
                                        
                                        Text("\(String(slot.minutes)) min")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                            .truncationMode(.tail)
                                    }
                                    .frame(width: CGFloat((proxy.size.width*0.80)/CGFloat(totalTime) * CGFloat( slot.id == selectedSlot.id ? selectedSlot.minutes : slot.minutes)))
                                    .padding([.leading, .trailing], 5)
                                }
                                Spacer()
                            }.padding(.top)
                            HStack{
                                Spacer()
                                Text("Changing this slot will reschedule all the other zones accordingly.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }.padding()
                        }
                    }
                    
                    Spacer()
                    Button(action: saveSlot){
                        HStack{
                            Spacer()
                            Text("Save")
                                .font(.body.bold())
                            Spacer()
                        }
                    }.buttonStyle(RectangleButtonStyle(color: Color.accentColor)).padding(10)
                }.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.all))
               .navigationTitle(String(status.zones.first(where: {$0.id == String(selectedSlot.id)})?.name ?? ""))
            }
        }
    }
    var body: some View {
        VStack{
            HStack{
                Text("Schedule")
                    .font(.title)
                    .bold()
                Spacer()
                    Button(action: {active.toggle()}){
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
            }.padding([.top, .leading, .trailing])
            Picker("schedule type", selection: $editSecondary){
                Text("Primary").tag(false)
                Text("Secondary").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            if editSecondary{
                secondaryTimeline
            }else{
                timeline
            }
        }
        .onChange(of: selectedSlot.minutes, perform: {value in mirrorSlots()})
        .onChange(of: secondarySelectedSlot.minutes, perform: {value in mirrorSecondarySlots()})
        .onAppear(perform: setup)
    }
}


//
//struct scheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleView()
//    }
//}
