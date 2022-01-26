//
//  MowerOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 10.07.21.
//

import SwiftUI

struct MowerOverview: View {
@EnvironmentObject var updater: UpdateManager
    @State var scheduleTime: Date = Date()
    @State var showTimeSelector: Bool = false
    @State var manualTime: Int = 0
    @State var showManualStart: Bool = false
    
    func setTime(){
        MowerKit().changeSchedule(newStartTime: scheduleTime)
    }
    func manualStart(){
        MowerKit().manualStart(minutes: manualTime)
    }
    func returnToAuto(){
        MowerKit().returnToAuto()
    }
    func pauseSchedule(){
        MowerKit().skipSchedule()
    }
    func stopNow(){
        MowerKit().stopNow()
    }
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .top){
                Text(MowerKit().getMode(mode: updater.status.mower.mode))
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                Spacer()
                    HStack{
                        Text("\(updater.status.mower.battery)%")
                            .bold()
                        Image(systemName: "bolt.fill")
                    }
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            if Date(timeIntervalSince1970: Double(updater.status.mower.nextStart) ?? 0) > Date(){
                Text("Today \(IrrigationKit().getLocalTimeFromUnix(unix: updater.status.mower.nextStart))")
                    .foregroundStyle(.secondary)
            }else{
                Text("Tomorrow \(IrrigationKit().getLocalTimeFromUnix(unix: updater.status.mower.nextStart))")
                    .foregroundStyle(.secondary)
            }
            HStack{
                Spacer()
                Text(MowerKit().getStatus(status: updater.status.mower.status))
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                
                if updater.status.mower.status != 2{
                    
                        if updater.status.mower.status != 4{
                            Image(systemName: MowerKit().getStatusIcon(status: updater.status.mower.status))
                                .font(.largeTitle)
                                .foregroundStyle(.primary)
                        }else{
                            VStack{
                                Image(systemName: "battery.100.bolt")
                                    .renderingMode(.original)
                                    .font(.largeTitle)
                                Text("\(updater.status.mower.battery)%")
                                    .bold()
                                    .padding(10)
                            }
                        }
                        
                    
                }else{
                    HStack{
                        Spacer()
                        VStack{
                            if updater.status.mower.manual{
                                
                                Text("Double tap to stop and return to auto")
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .onTapGesture(count: 2, perform: {returnToAuto()})
                            }else{
                                
                                
                                Text("Double tap to stop now")
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .onTapGesture(count: 2, perform: {stopNow()})
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
                .padding().padding(.bottom, 10)
            if updater.status.mower.status != 2{
                Button(action: {showManualStart.toggle()}){
                    Text("Start manually")
                }
            }
        }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(13)
            .padding([.leading, .trailing])
            .contextMenu(menuItems: {
                Button(action: {showTimeSelector.toggle()}){
                    Text("Change Schedule")
                }
            })
            .sheet(isPresented: $showTimeSelector){
                VStack{
                    HStack{
                        Spacer()
                        Text("Schedule")
                            .font(.largeTitle.bold())
                        Spacer()
                    }.padding()
                    Spacer()
                    HStack{
                        Spacer()
                        DatePicker("Start time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                        Spacer()
                    }
                    Spacer()
                    Text("The mower will start every day at the set time. Weather adaption might skip, pause or reschedule the schedule if necessary")
                        .foregroundColor(.secondary)
                        .padding()
                    Button(action: setTime){
                        HStack{
                            Spacer()
                            Text("Done")
                                .font(.body.bold())
                            Spacer()
                        }
                        
                    }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
                }.padding()
            }
            .sheet(isPresented: $showManualStart){
                GeometryReader{proxy in
                    VStack{
                        HStack{
                            Spacer()
                            Text("Manual start")
                                .font(.largeTitle.bold())
                            Spacer()
                        }.padding()
                        Spacer()
                        CircularSlider(max: 180, size: proxy.size.width*0.7, value: $manualTime)
                            .overlay(
                                Text("\(manualTime.description) min")
                                    .font(.title.bold())
                                    .animation(.linear, value: manualTime)
                            )
                           
                        Spacer()
                        Text("After the set mowing time the mower will return home and resume the automatic schedule")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing])
                            .foregroundColor(.secondary)
                        
                        Button(action: manualStart){
                            HStack{
                                Spacer()
                                Text("Start mower")
                                    .font(.body.bold())
                                Spacer()
                            }
                        }
                        .buttonStyle(RectangleButtonStyle(color: Color.accentColor))
                    }.padding()
                }
            }
       
    }
}

//struct MowerOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        MowerOverview()
//    }
//}
