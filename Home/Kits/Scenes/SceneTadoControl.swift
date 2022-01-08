//
//  SceneTadoControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI

struct SceneTadoControl: View {
    @Binding var scene: SceneAutomation
    @Binding var tado: TempDevice
    @State var offset: Float = 0.0
//    @State var setTemp: Float = 0
    @State var modeLabel: String = ""
    @State var activityLabel: String = ""
    @State var valueChanged: Bool = false

    func sync(){
        guard let index = scene.tado.firstIndex(where: {$0.id == tado.id})else{return}
        scene.tado[index] = tado
    }
    
    func updateUI(){
        let minTemp: Float = tado.isAC ? 16 : 5
        if tado.setTemp <= minTemp{
            modeLabel = "OFF"
        }else{
            if tado.manualMode{
                modeLabel = "MANUAL"
            }else{
                modeLabel = "AUTO"
            }
        }
        
        if tado.active{
            activityLabel = tado.isAC ? "cooling \(tado.performance)%" : "heating \(tado.performance)%"
        }
    }
    
//    func setNewTemp(){
//        tado.setTemp = setTemp
//        valueChanged = false
//        tado.manualMode = true
//        updateUI()
//    }
    func backToAuto(){
        tado.manualMode = false
        updateUI()
        sync()
    }
    func updateTemp(){
        let minTemp: Float = tado.isAC ? 16 : 5
        let newSetTemp = minTemp + offset
        tado.setTemp = newSetTemp
//        setTemp = newSetTemp
        
//        valueChanged = tado.setTemp != setTemp ? true : false
        sync()
        updateUI()
    }
    
    func setup(){
        if !valueChanged{
            let minTemp: Float = tado.isAC ? 16 : 5
            offset = tado.setTemp - minTemp
            updateUI()
            updateTemp()
        }
        
    }
    var gaugeOverlay: some View{
        VStack{
            Text(modeLabel)
                .foregroundColor(tado.isAC ? .teal : .orange)
            if tado.isAC{
                Text("\(Int(tado.setTemp).description)°")
                    .font(.custom("SF Mono", size: 50).weight(.medium))
            }else{
                Text("\(String(format: "%.1f", tado.setTemp))°")
                    .font(.custom("SF Mono", size: 50).weight(.medium))
            }
//                .font(.largeTitle)
               
//            Text("Inside now \(String(format: "%.1f", tado.temp))°")
//                .foregroundStyle(.secondary)
//            if tado.active{
//                Text(activityLabel)
//                    .foregroundStyle(.secondary)
//            }
        }
    }
    
    var body: some View{
        if tado.manualMode{
            manual
        }else{
            VStack{
                HStack{
                    Spacer()
                    VStack{
                        Text(tado.name)
                            .font(.title.bold())
                    }
                    Spacer()
                }.padding(.top)
                Spacer()
                Text("Override Auto mode")
                    .font(.title2.bold())
                    .foregroundColor(.secondary)
                Toggle("", isOn: $tado.manualMode)
                    .labelsHidden()
                Spacer()
            }.padding()
        }
    }
    var manual: some View {
        GeometryReader{proxy in
            ZStack{
                VStack{
                    Spacer()
                    if tado.manualMode{
                        HStack{
                            Spacer()
                            Button(action: backToAuto){
                                Text("Back to auto")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding([.leading, .trailing])
                                    .background(tado.isAC ? .teal : .orange)
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
                        Text(tado.name)
                            .font(.title.bold())
                        
              
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
                if tado.isAC{
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
            .onAppear(perform: setup)
        }
    }
}

//struct SceneTadoControl_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneTadoControl()
//    }
//}
