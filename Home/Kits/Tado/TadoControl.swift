//
//  ACControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 24.06.21.
//

import SwiftUI

struct TadoControl: View {
    @EnvironmentObject var updater: UpdateManager
    @Binding var device: TempDevice
    @State var offset: Float = 0.0
    @State var setTemp: Float = 0
    @State var modeLabel: String = ""
    @State var activityLabel: String = ""
    @State var valueChanged: Bool = false

    func updateUI(){
        let minTemp: Float = device.isAC ? 16 : 5
        if device.setTemp <= minTemp{
            modeLabel = "OFF"
        }else{
            if device.manualMode{
                modeLabel = "MANUAL"
            }else{
                modeLabel = "AUTO"
            }
        }
        
        if device.active{
            activityLabel = device.isAC ? "cooling \(device.performance)%" : "heating \(device.performance)%"
        }
    }
    
    func setNewTemp(){
        device.setTemp = setTemp
        TadoKit().setTemp(device: device)
        valueChanged = false
        device.manualMode = true
        updateUI()
    }
    func backToAuto(){
        TadoKit().backToAuto(device: device)
        device.manualMode = false
        updateUI()
    }
    func updateTemp(){
        let minTemp: Float = device.isAC ? 16 : 5
        let newSetTemp = minTemp + offset
        
        setTemp = newSetTemp
        
        valueChanged = device.setTemp != setTemp ? true : false
        updateUI()
    }
    
    func setup(){
        if !valueChanged{
            device = (updater.status.rooms.first(where: {$0.tempDevices.contains(where: {$0.id == device.id})})?.tempDevices.first(where: {$0.id == device.id}))!
            print("value updated")
            let minTemp: Float = device.isAC ? 16 : 5
            offset = device.setTemp - minTemp
            updateUI()
            updateTemp()
        }
        
    }
    var gaugeOverlay: some View{
        VStack{
            Text(modeLabel)
                .foregroundColor(device.isAC ? .teal : .orange)
            if device.isAC{
                Text("\(Int(setTemp).description)°")
                    .font(.custom("SF Mono", size: 50).weight(.medium))
            }else{
                Text("\(String(format: "%.1f", setTemp))°")
                    .font(.custom("SF Mono", size: 50).weight(.medium))
            }
//                .font(.largeTitle)
               
            Text("Inside now \(String(format: "%.1f", device.temp))°")
                .foregroundStyle(.secondary)
            if device.active{
                Text(activityLabel)
                    .foregroundStyle(.secondary)
            }
        }
    }
    var body: some View {
        GeometryReader{proxy in
            ZStack{
                VStack{
                    Spacer()
                    if valueChanged{
                        HStack{
                            Spacer()
                            Button(action: setNewTemp){
                                Text("Set")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding([.leading, .trailing])
                                    .background(device.isAC ? .teal : .orange)
                                    .cornerRadius(30)
                                    .padding()
                            }
                            Spacer()
                        }
                    }else if device.manualMode{
                        HStack{
                            Spacer()
                            Button(action: backToAuto){
                                Text("Back to auto")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding([.leading, .trailing])
                                    .background(device.isAC ? .teal : .orange)
                                    .cornerRadius(30)
                                    .padding()
                            }
                            Spacer()
                        }
                    }
                }
            
            VStack{
                HStack{
                    Spacer()
                    VStack{
                        Text(device.name)
                            .font(.title.bold())
                        VStack(alignment: .leading){
                            HStack{
                                HStack{
                                    Text("Current")
                                    Text("\(String(format: "%.1f", device.temp))°")
                                        .bold()
                                }
                                Text("|")
                                HStack{
                                    Text("Humidity")
                                    Text("\(String(format: "%.1f", device.humidity))%")
                                        .bold()
                                }
                            }
                        }.foregroundStyle(.secondary)
              
    //                    Text("Current \(String(format: "%.1f", device.temp))°")
                            
    //                    if !device.state{
    //                        Text("Off")
    //                            .foregroundColor(.secondary)
    //                    }else{
    ////                        Text("\(String(Int(light.brightness)))% Brightness")
    ////                            .foregroundColor(.secondary)
    //                    }
                    }
                    Spacer()
                }.padding(.top)
                Spacer()
                if device.isAC{
                    CircleSlider(progressColors: [.teal, .blue], value: $offset, maxValue: 10, size: proxy.size.width*0.7)
                        .overlay(gaugeOverlay)
                }else{
                    CircleSlider(progressColors: [.yellow, .orange], value: $offset, maxValue: 20, size: proxy.size.width*0.7)
                        .overlay(gaugeOverlay)
                }
                Spacer()
           
                
            }
            }
            .padding()
            .onChange(of: offset, perform: {value in updateTemp()})
            .onChange(of: updater.lastUpdated, perform: {value in setup()})
            .onAppear(perform: setup)
        }
    }
}

//struct ACControl_Previews: PreviewProvider {
//    static var previews: some View {
//        ACControl()
//    }
//}
