//
//  IrrigationRoom.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.06.21.
//

import SwiftUI

struct IrrigationOverview: View {
    @Binding var showDetail: Bool
    @EnvironmentObject var updater: UpdateManager
    @State var showZone: Bool = false
    @State var nextStart: TimeSlot? = nil
    @State var statusDescription: String = ""
    @State var selectedZone: irrigationZone = irrigationZone(id: "", name: "", active: false)
    @State var editSchedule: Bool = false
    @State var pauseScheduleConfirmation: Bool = false
    
    
    func changeSchedule(){
        Biometrics().authenticate(){state in
            if state{
                editSchedule.toggle()
            }
        }
    }
    func endManualMode(){
        IrrigationKit().stopManualIrrigation()
    }
    func pauseSchedule(){
        if updater.status.irrigation.mode == 2{
            //back to auto mode
            IrrigationKit().returnToAuto()
        }else{
            //pause schedule
            IrrigationKit().pauseSchedule()
        }
        
    }

    
    func selectZone(zone: irrigationZone){
        showZone.toggle()
        selectedZone = zone
    }
    
    func updateSchedule(){
        
        var startTimes = updater.status.irrigation.schedule.map({IrrigationKit().getLocalTimeFromUnix(unix: $0.time)})
        let secondary = updater.status.irrigation.secondarySchedule.map({IrrigationKit().getLocalTimeFromUnix(unix: $0.time)})
        
        startTimes.append(contentsOf: secondary)
        
//        startTimes.sorted()
        let date = IrrigationKit().getNextStart(irrigation: updater.status.irrigation)
//        let format = DateFormatter()
         
//        format.timeZone = .current
//        format.timeStyle = .short
         
//        let dateString = format.string(from: date)
//        nextStart = dateString
//        let unix = date.timeIntervalSince1970.description
//        print(updater.status.irrigation.schedule)
        guard let slot = updater.status.irrigation.schedule.first(where: {Date(timeIntervalSince1970: Double($0.time)!) == date})else{
            //second schedule
            let slot = updater.status.irrigation.secondarySchedule.first(where: {Date(timeIntervalSince1970: Double($0.time)!) == date})
            nextStart = slot
            return
        }
        nextStart = slot
        
        
    }
    
    var gaugeIcon: some View{
        VStack{
            TimerGauge(timeRemaining: updater.status.irrigation.secondsRemaining, startDuration: updater.status.irrigation.irrigationDuration, color: Color("secondary"), stroke: 5, font: .caption)
        }.frame(width: 50, height: 50)
    }
    
    var body: some View{

        ScrollView(.horizontal){
            HStack{
                if updater.status.irrigation.mode == 1 || updater.status.irrigation.mode == 4{
                    if updater.status.irrigation.active{
                        if updater.status.irrigation.zones.first(where: {$0.active == true}) != nil{
                            MainControl(icon: AnyView(
                                gaugeIcon
                            ), title: updater.status.irrigation.zones.first(where: {$0.active == true})!.name, caption: "Now Running")
                        }
                        if nextStart != nil{
                            MainControl(icon: AnyView(
                                Image(systemName: "calendar").font(.title)
                            ), title: "Next Up: \(IrrigationKit().getZoneName(id: nextStart!.id, system: updater.status.irrigation))", caption: String(IrrigationKit().getLocalTimeFromUnix(unix: nextStart!.time)))
                        }
                    }else{
                        if nextStart != nil{
                            MainControl(icon: AnyView(
                                Image(systemName: "calendar").font(.title)
                            ), title: "Next Start", caption: String(IrrigationKit().getLocalTimeFromUnix(unix: nextStart!.time)))
                        }else{
                            MainControl(icon: AnyView(
                                Image(systemName: "checkmark.circle").font(.title)
                            ), title: "All Done", caption: "System finished")
                        }
                    }
                }else{
                    Button(action: {showDetail.toggle()}){
                        MainControl(icon: AnyView(
                            Image(systemName: "exclamationmark.circle").font(.title)
                        ), title: IrrigationKit().statusModes[updater.status.irrigation.mode].description, caption: "Tap for more info")
                    }
                }

            }
        }.onAppear(perform: updateSchedule)
    }
    var activeControlArea: some View{
        HStack{
            Spacer()
                
            VStack{
                TimerGauge(timeRemaining: updater.status.irrigation.secondsRemaining, startDuration: updater.status.irrigation.irrigationDuration*60, color: .accentColor, stroke: 5, font: .headline)
                    .frame(width: 65, height: 65)
                    .background(CircularWaveProgressView(radius: 30, hideCircle: true))
                    .padding()
                Text(updater.status.irrigation.zones.first(where: {$0.active == true})?.name ?? "Updating")
                    .lineLimit(2)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            Text("Double tap\nto stop")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding()
            Spacer()
        }.padding().onTapGesture(count: 2, perform: {endManualMode()})
    }
    var activeIrrigation: some View{
        VStack{
            
            HStack{
                TimerGauge(timeRemaining: updater.status.irrigation.secondsRemaining, startDuration: updater.status.irrigation.irrigationDuration*60, color: .accentColor, stroke: 5, font: .headline)
                    .frame(width: 70, height: 70)
                    .padding(.trailing, 10)
                VStack(alignment: .leading){
                    Text(updater.status.irrigation.zones.first(where: {$0.active == true})?.name ?? "Getting Status")
                        .font(.largeTitle.bold())
                    if updater.status.irrigation.secondsRemaining != -1{
                        if updater.status.irrigation.secondsRemaining > 60{
                            let (_,m,s) = secondsToHoursMinutesSeconds(seconds: updater.status.irrigation.secondsRemaining)
                            Text("\(m) minutes \(s) seconds remaining")
                                .foregroundColor(.secondary)
                            
                        }else{
                            Text("\(updater.status.irrigation.secondsRemaining) seconds remaining")
                                .foregroundColor(.secondary)
                        }
                    }else{
                        Text("Starting system")
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
            }
            Spacer()
            if updater.status.irrigation.secondsRemaining != -1{
                CircularWaveProgressView(radius: 80)
            }else{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
           
                Text("Waiting for response")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(updater.status.irrigation.zones.contains(where: {$0.active == true}) ? "Irrigation will stop automatically" : "")
                .foregroundColor(.secondary)
                .font(.callout)
            Button(action: endManualMode){
                HStack{
                    Spacer()
                    Text("Stop")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))

        }.padding()
    }
    
    var main: some View {
        VStack(alignment: .leading){
            HStack(alignment: .top){
                Text(IrrigationKit().statusModes[updater.status.irrigation.mode].description)
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(updater.status.irrigation.active ? "ON" : "OFF")\(updater.status.irrigation.refillActive ? " | REFILLING" : "")")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.secondary)
            }
            
            if nextStart != nil{
                Text("Next: \(IrrigationKit().getZoneName(id: nextStart!.id, system: updater.status.irrigation)) \(IrrigationKit().getLocalTimeFromUnix(unix: nextStart!.time))")
                    .foregroundStyle(.secondary)
            }else{
                Text("Done for today")
                    .foregroundStyle(.secondary)
            }
      
            if updater.status.irrigation.active{
                activeControlArea
            }else{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(updater.status.irrigation.zones){zone in
                            Button(action: {selectZone(zone: zone)}){
//                                QuickActionControl(title: zone.name, description: "", icon: "drop", color: .teal)
                                VStack{
                                    HStack{
                                        Spacer()
                                    }
                                    Image(systemName: "drop")
                                        .font(.title2)
                                        .foregroundStyle(.teal)
                                        .padding([.leading, .trailing, .top])
//                                        .background(Color.gray.opacity(0.3))
//                                        .clipShape(Circle())
                                    Text(zone.name)
                                        .foregroundColor(.black)
//                                        .foregroundStyle(.secondary)
                                        .font(.caption.bold())
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .padding([.top, .bottom])
                                }
                                .aspectRatio(0.8, contentMode: .fit)
                                .background(.white).cornerRadius(12)
                            }.padding(.trailing, 5)
                        }
                    }.padding(.top)
                }
            }
            Text(IrrigationKit().getModeDescription(system: updater.status.irrigation))
                .foregroundStyle(.tertiary)
                .font(.caption)
                .padding(.top, 10)
        }
       
    }
}

