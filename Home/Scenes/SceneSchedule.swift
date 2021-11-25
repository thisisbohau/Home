//
//  SceneSchedule.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI


struct SceneSchedule: View {
    @Binding var scene: SceneAutomation
    @Binding var step: Int
    @State var useSchedule: Bool = false
    @State var daily: Bool = false
    @State var dailyTime: Date = Date()
    
    @State var editTime: Bool = false
    @State var selectedDay: Int = 0
    @State var selectedTime: Date = Date()
    @State var scheduleSet: [Schedule] = [Schedule]()
    
    func setup(){
        let unix = String(dailyTime.timeIntervalSince1970)
        scheduleSet.removeAll()
        for day in 1...7{
            scheduleSet.append(Schedule(id: day, time: unix))
        }
    }
    func setDaily(){
        if daily{
            let unix = String(dailyTime.timeIntervalSince1970)
            scene.schedule?.removeAll()
            for day in 1...7{
                scene.schedule?.append(Schedule(id: day, time: unix))
            }
        }
    }
    func setTime(){
        print("setting time")
        
        let unix = String(selectedTime.timeIntervalSince1970)
        guard let index = scene.schedule?.firstIndex(where: {$0.id == selectedDay})else{return}
        scene.schedule?[index] = Schedule(id: selectedDay, time: unix)
        
    }
    func addSlot(id: Int){
        if !(scene.schedule?.contains(where: {$0.id == id}) ?? false){
            scene.schedule?.append(Schedule(id: id, time: String(Date().timeIntervalSince1970)))
        }
    }
    func removeSlot(id: Int){
        scene.schedule?.removeAll(where: {$0.id == id})
        editTime = false
    }
        
    func editTime(id: Int){
        selectedDay = id
        editTime = true
    }
    func setupWeek(){
        scene.schedule?.removeAll()
        for day in 1...7{
            scene.schedule?.append(Schedule(id: day, time: ""))
        }
    }
    var body: some View {
        Form{
            Section(header: Text("Schedule"), footer: Text("If active the Scene will run on set times.")){
                Toggle("Use Schedule", isOn: $useSchedule)
            }
            
            if useSchedule{
                Section{
                    Toggle("Repeat daily", isOn: $daily)
                    if daily{
                        HStack{
                            DatePicker("", selection: $dailyTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .font(.title.bold())
                                
                            Spacer()
                        }
                    }
                }.onAppear(perform: setupWeek)
                
                if !daily{
                    Section{
                        ForEach(scene.schedule?.sorted(by: {$1.id > $0.id}) ?? [Schedule]()){slot in
                            Button(action: {editTime(id: slot.id)}){
                                HStack{
                            
                                    Text(SceneKit().getDay(id: slot.id))
                                    Spacer()
                                    Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                    
                                }
                            }
                        }
                     
                    }
                    Section{
                        Menu(content: {
                            ForEach(scheduleSet){slot in
                                if !(scene.schedule?.contains(where: {$0.id == slot.id}) ?? false){
                                    Button(action: {addSlot(id: slot.id)}){
                                        Text(SceneKit().getDay(id: slot.id))
                                    }
                                }
                            }
                        }, label: {
                            HStack{
                                Text("Add Day")
                                Spacer()
                            }
                        })
                    }
                }
            }
        }
        .sheet(isPresented: $editTime, onDismiss: {setTime()}){
            VStack{
                HStack{
                    Spacer()
                    Text(SceneKit().getDay(id: selectedDay))
                        .font(.largeTitle.bold())
                    Spacer()
                }.padding()
                Spacer()
                HStack{
                    Spacer()
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .font(.title.bold())
                    Spacer()
                }
                Spacer()
                Button(action: {removeSlot(id: selectedDay)}){
                    HStack{
                        Spacer()
                        Text("Remove")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                }.buttonStyle(RectangleBorderButtonStyle(color: Color.red))
                Button(action: {editTime = false}){
                    HStack{
                        Spacer()
                        Text("Done")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
                
            }.padding()
        }
        .onAppear(perform: setup)
        .onChange(of: dailyTime, perform: {value in setDaily()})
        .onChange(of: daily, perform: {value in if !value{setupWeek()}})
        .onChange(of: useSchedule, perform: {value in
            if !value{
            scene.schedule?.removeAll()
        }})
        
    }
}


