//
//  IrrigationView.swift
//  Home
//
//  Created by David Bohaumilitzky on 26.09.21.
//

import SwiftUI

struct IrrigationView: View {
    @EnvironmentObject var updater: UpdateManager
    @State var changeSchedule: Bool = false
    @State var manualStart: Bool = false
    @State var zone: irrigationZone = irrigationZone(id: "", name: "", active: false)
    
    
    var winterMode: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    Image(systemName: "snowflake")
                        .font(.system(size: 80))
                        .padding()
//                    Spacer()
                    Text("Winter Mode")
                        .font(.largeTitle.bold())
                    Text("Irrigation unavailable. Deactivate Winter Mode to start.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                Spacer()
            }
            
            Spacer()
            
        }
        .padding()
        .background(Color("background")).ignoresSafeArea()
        .background(.regularMaterial)
        
    }
    
    var body: some View{
        if updater.status.irrigation.mode == 5{
            //winter mode
            winterMode
        }else{
            main
        }
    }
    
    var main: some View {
        VStack{
            HStack{
                Text("Irrigation")
                    .font(.largeTitle.bold())
                Spacer()
            }.padding(.top)
            if updater.status.irrigation.active{
                VStack{
                    HStack{
                        VStack{
                            TimerGauge(timeRemaining: updater.status.irrigation.secondsRemaining, startDuration: updater.status.irrigation.irrigationDuration, color: Color("secondary"), stroke: 10, font: .title)
                                .frame(width: 100, height: 100)
                        }.padding(.trailing)
                        Text(updater.status.irrigation.zones.first(where: {$0.active})?.name ?? "")
                            .font(.title2.bold())
                        Spacer()
                        
                        
                    }.padding(10)
                    Button(action: {IrrigationKit().stopManualIrrigation()}){
                        HStack{
                            Spacer()
                            Text("Stop")
                                .font(.body.bold())
                            Spacer()
                        }
                        
                    }.buttonStyle(RectangleBorderButtonStyle(color: Color("secondary")))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(updater.status.irrigation.zones){zone in
                        Button(action: {self.zone = zone; manualStart.toggle()}){
                            MainControl(icon: AnyView(Image("irrigation").font(.title)), title: zone.name, caption: zone.active ? "Now running" : "Tap for info")
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
            
        }
        .padding()
        .background(Color("background").ignoresSafeArea())
        .sheet(isPresented: $changeSchedule){
            IrrigationScheduleView(active: $changeSchedule, status: $updater.status.irrigation)
        }
        .sheet(isPresented: $manualStart){
            IrrigationZoneView(active: $manualStart, zone: $zone)
        }
    }
}

struct IrrigationView_Previews: PreviewProvider {
    static var previews: some View {
        IrrigationView()
    }
}
