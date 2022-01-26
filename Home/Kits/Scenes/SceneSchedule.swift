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
    @State var daily: Bool = true
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
        selectedTime = dailyTime
        scene.schedule?.removeAll()
        for day in 1...7{
            scene.schedule?.append(Schedule(id: day, time: String(dailyTime.timeIntervalSince1970)))
        }
    }
    
    var main: some View{
        VStack{
            Button(action: {useSchedule.toggle()}){
            HStack{
                Spacer()
                VStack{
                    Image(systemName: "deskclock")
                        .font(.largeTitle)
                        .foregroundColor(useSchedule ? .accentColor : Color("secondary"))
                    Text("Use Schedule")
                        .font(.title3.bold())
                        .padding(.top)
                        .foregroundColor(useSchedule ? .accentColor : Color("secondary"))
                    
                }.padding()
                    .padding([.top, .bottom], 30)
                Spacer()
            }.background(Color(useSchedule ? "fill" : "secondaryFill")).cornerRadius(20)
                    
        }
            Text("Automatically adapt your devices based on a schedule you set. You can change the schedule anytime in the scene settings.")
                .foregroundStyle(.secondary)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            if useSchedule{
                
                    VStack{
                        Button(action: {daily = true}){
                            HStack{
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(!daily ? .secondary : .orange)
                                Text("Repeat daily")
                                    .font(.headline.bold())
                                Spacer()
                            }.disabled(!daily)
                        }
                        if daily{
                            Text("At:")
                            DatePicker("", selection: $dailyTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .font(.title.bold())
                                
                        }
                        
                    }
                    .padding()
                    .background(Color("fill"))
                    .cornerRadius(15)
                    .foregroundColor(.primary)
                   
               
                
                
                    VStack{
                        Button(action: {daily = false}){
                        HStack{
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.accentColor)
                            Text("Weekly schedule")
                                .font(.headline.bold())
                            Spacer()
                        }.disabled(daily)
                        }
                        if !daily{
                            ForEach(scene.schedule?.sorted(by: {$1.id > $0.id}) ?? [Schedule]()){slot in
                                Button(action: {editTime(id: slot.id)}){
                                    HStack{
                                        
                                        Text(SceneKit().getDay(id: slot.id))
                                            .bold()
                                        Spacer()
                                        Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                            .foregroundColor(.secondary)
                                            .font(.callout)
                                        
                                        
                                    }
                                    .padding()
                                    .background(Color("secondaryFill"))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color("fill"))
                    .cornerRadius(15)
                    .foregroundColor(.primary)
                   
                
                
                
            }
            Spacer()
        }
        .padding()
        .padding(.bottom, 150)
        
    }
    var body: some View {
        main

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
                        .font(.largeTitle.bold())
                    Spacer()
                }
                Spacer()
                Button(action: {removeSlot(id: selectedDay)}){
                    HStack{
                        Spacer()
                        Text("Remove From Schedule")
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
                .background(Color("background").ignoresSafeArea())
        }
//        }
        .onAppear(perform: setup)
        .onChange(of: dailyTime, perform: {value in setDaily()})
        .onChange(of: daily, perform: {value in if !value{setupWeek()}})
        .onChange(of: useSchedule, perform: {value in
            if !value{
            scene.schedule?.removeAll()
        }})
        
    }
}


