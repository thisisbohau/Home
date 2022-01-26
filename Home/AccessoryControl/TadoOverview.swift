//
//  AccessoryDetailAvgTemp.swift
//  Home
//
//  Created by David Bohaumilitzky on 16.08.21.
//

import SwiftUI
import simd

struct TadoOverview: View{
    @EnvironmentObject var updater: UpdateManager
    @State var notInAutoMode: [TempDevice] = [TempDevice]()
    @State var allTadoDevices: [TempDevice] = [TempDevice]()
    @State var selectedFloor: Int = 2
    @State var devicesNotInAuto: Bool = false
    @State var viewSize: CGSize = CGSize(width: 0, height: 0)
    
    @State var avgTemp: Float = 0
    @State var avgTempInt: Int = 0
    @State var setAllTemp: Float = 22
    @State var setAllOffset: Float = 6
    @State var defaultPos: CGFloat = 0
    @State var showTempSlider: Bool = true
    @State var animateChanges: Bool = false
    @State var animate: Bool = false
    @State var animateTo: Bool = false
    @State var autoAdaptOn: Bool = false
    
    @State var selectedTado: TempDevice = TempDevice(id: "", isAC: false, name: "", manualMode: false, active: false, openWindow: false, temp: 0, setTemp: 0, humidity: 0, performance: 0)
    
    @State var controlTado: Bool = false
    @State var selectionOptions: [SelectionPoint] = [SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 1, icon: AnyView(Text("EG").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 2, icon: AnyView(Text("OG").rotationEffect(Angle(degrees: 90))), title: "")]
    @State var selectedOption: SelectionPoint = SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: "")
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func updateSetAll(){
        //minimum: 16°
        let setTo = 16 + setAllOffset
        setAllTemp = setTo
    }
    
    func getRoomName(tado: TempDevice) -> String{
        return updater.status.rooms.first(where: {$0.tempDevices.contains(where: {$0.id == tado.id})})?.name ?? ""
    }
    func returnToAuto(tado: TempDevice){
        TadoKit().backToAuto(device: tado)
    }
    func controlTado(tado: TempDevice){
        selectedTado = tado
        controlTado = true
    }
    
    func boostAll(){
        Task{
            animate = true
            await TadoKit().boost()
            animate = false
        }
    }
    func setAll(){
        animate = true
        for tado in updater.status.rooms.flatMap({$0.tempDevices}){
            var modified = tado
            modified.setTemp = setAllTemp
            
            TadoKit().setTemp(device: modified)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            animate = false
        })
    }
    
    func returnAllToAuto(){
        animate = true
        for tado in notInAutoMode{
            TadoKit().backToAuto(device: tado)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            animate = false
        })
    }
    func update(){
//        switch selectedOption.id{
//        case 0:
//            selectedFloor = 2
//        case 1:
//            selectedFloor = 0
//        case 2:
//            selectedFloor = 1
//        default:
//            selectedFloor = 2
//        }
        if selectedFloor == 2{
            let tado = updater.status.rooms.flatMap({$0.tempDevices})
            notInAutoMode = tado.filter({$0.manualMode})
            allTadoDevices = Array(Set(tado).subtracting(Set(notInAutoMode)))
        }else{
            let tado = updater.status.rooms.filter({$0.floor == selectedFloor}).flatMap({$0.tempDevices})
            notInAutoMode = tado.filter({$0.manualMode})
            allTadoDevices = tado
        }
        
        if notInAutoMode.count > 0{
            devicesNotInAuto = true
        }else{
            devicesNotInAuto = false
            animate = false
        }
        
        let tado = updater.status.rooms.flatMap({$0.tempDevices})
        avgTemp = tado.compactMap({$0.temp}).reduce(0, +)/Float(tado.count)
        if !avgTemp.isNaN{
            avgTempInt = Int(avgTemp)
        }
    }
    
    var gaugeOverlay: some View{
        VStack{
            Text("SET ALL")
                .foregroundColor(.orange)

                Text("\(String(format: "%.1f", setAllTemp))°")
                    .font(.custom("SF Mono", size: 50).weight(.medium))
               
            Text("Inside avg. \(String(format: "%.1f", avgTemp))°")
                .foregroundStyle(.secondary)
        }
    }
    
    var tempSlider: some View{
        VStack{
            CircleSlider(progressColors: [.orange, .pink], value: $setAllOffset, maxValue: 9, size: 250)
                .overlay(gaugeOverlay)
            Button(action: setAll){
                Text("SET")
                    .padding([.leading, .trailing], 16)
                    .padding([.bottom, .top], 8)
                    .foregroundColor(.primary)
                    .background(.orange)
                    .cornerRadius(60)
            }
            .offset(y: -55)
        }
        .padding([.top, .leading, .trailing])
        .onChange(of: setAllOffset, perform: {_ in
            updateSetAll()
        })
    }
    var topLevelControl: some View{
        HStack{
            CircleGauge(maxValue: CGFloat(25), value: $avgTempInt, label: "\(avgTempInt.description)°", color: .orange, stroke: 9, font: .headline)
                .frame(width: 65, height: 65)
            
            VStack(alignment: .leading){
                Text("Tado")
                    .font(.title.bold())
                
                if notInAutoMode.count <= 0{
                    Text("Auto Mode")
                        .foregroundStyle(.secondary)
                }else{
                    Text("\(String(Int(notInAutoMode.count))) \(notInAutoMode.count == 1 ? "device in manual mode" : "devices in manual mode")")
                        .foregroundStyle(.secondary)
                }
            }.padding(.leading)
            Spacer()
        }
    }
    
    var main: some View{
        VStack{
            topLevelControl
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)){
                        animate.toggle()
                    }
                })
            VStack{
                if showTempSlider{
                    tempSlider
                        .padding(.top)
                       
                }
            }
            .padding(.top)

            ScrollView{
//                GeometryReader{proxy in
                    VStack{
//                        sectionControl
                        VStack{
                            notInAutoList
                        }
                        VStack{
                            autoModeDevices
                        }
                        .padding(.top)
//                        .onAppear(perform: {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                            defaultPos = proxy.frame(in: .global).midY
//                            showTempSlider = true
//                            print("after setup: \(proxy.frame(in: .global).midY)")
//                            }
//                        })
//                        .onChange(of: proxy.frame(in: .global).midY, perform: {frame in
//
//                            print("onChange: \(proxy.frame(in: .global).midY)")
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                                withAnimation(.linear, {
//                                    if proxy.frame(in: .global).midY.distance(to: defaultPos) < 50{
//                                        showTempSlider = true
//
//                                    }else{
//                                        showTempSlider = false
//                                        defaultPos = proxy.frame(in: .global).midY
//                                    }
//                                })
//                            }
//
//                        })
                  
                    }
//                }
            }
            
            Spacer()
        }
    }
    
    var quickActions: some View{
        HStack{
            Button(action: boostAll){
                HStack{
                    Image(systemName: "flame.fill")
                        .foregroundColor(.pink)
                    VStack(alignment: .leading){
                        Text("Boost All")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("25° for 30min")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.black)
                    Spacer()
                }
                .padding(10)
                .background(.white)
                .cornerRadius(18)
            }
            
            Button(action: returnAllToAuto){
                HStack{
                    Image(systemName: "calendar")
                        .foregroundColor(.teal)
                    VStack(alignment: .leading){
                        Text("Back to Auto")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("Resume schedule")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(devicesNotInAuto ? .black : .white)
                    Spacer()
                }
                .padding(10)
                .onCondition(devicesNotInAuto, transform: {view in
                    view.background(.white)
                })
                .onCondition(!devicesNotInAuto, transform: {view in
                    view.background(.regularMaterial)
                })
                .cornerRadius(18)
            }
        }
    }
    var sectionControl: some View{
        VStack(){
            HStack{
                Text("Level")
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
                Spacer()
            }
            VStack{
                SmartSelectionSlider(selectionPoints: $selectionOptions, selectedPoint: $selectedOption, controlSize: 45, availableSpace: viewSize.width*0.9, selectColor: .yellow, noBackground: true)
                    .background(.regularMaterial)
                    .cornerRadius(25)
                
            }.rotationEffect(Angle(degrees: -90))
                .frame(height: 45)
            
        }
        .padding([.top, .bottom])
        .padding(.top)
    }
    var notInAutoList: some View{
        VStack{
            quickActions
                .onCondition(devicesNotInAuto, transform: {view in
                    view
                        .padding(.bottom)
                })
            if devicesNotInAuto{
                HStack{
                Text("in manual mode")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(notInAutoMode){tado in
                        DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(Int(tado.temp)))°", name: getRoomName(tado: tado), active: true, offStatus: "Off", onLongPress: {controlTado(tado: tado)}, onTap: {returnToAuto(tado: tado)})
                    }
                }
            }
        }
        .padding(10)
        .background(.regularMaterial)
        .cornerRadius(25)
    }
    var autoModeDevices: some View{
        VStack{
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                ForEach(allTadoDevices){tado in
                    DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(Int(tado.temp)))°", name: getRoomName(tado: tado), active: true, offStatus: "Off", onLongPress: {controlTado(tado: tado)}, onTap: {returnToAuto(tado: tado)})
                }
            }
            
//            ForEach(updater.status.rooms){room in
//                if room.tempDevices.count > 0{
//                    VStack{
//                        HStack{
//                            Text(room.name)
//                                .font(.headline)
//                                .foregroundStyle(.secondary)
//                            Spacer()
//                        }
//                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
//                            ForEach(room.tempDevices){tado in
//                                DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(Int(tado.temp)))°", name: tado.name, active: true, offStatus: "Off", onLongPress: {controlTado(tado: tado)}, onTap: {returnToAuto(tado: tado)})
//                            }
//                        }
//                    }.animation(nil, value: animate)
//                }
//            }
        }
    }
    var body: some View {
        GeometryReader{proxy in
            VStack{
//            ScrollView(showsIndicators: false){
                main
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
            .onChange(of: selectedOption.id, perform: {_ in update()})
            .onAppear(perform: update)

            .sheet(isPresented: $controlTado){
                TadoControl(device: $selectedTado)
            }
            .onAppear(perform: {viewSize = proxy.size})
        }
        
        .padding()
        .padding(.top)
        
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .trim(from: !animate ? 0 : 0.9, to: !animate ? 0.03 : 1)
                .stroke(animateTo  ? .yellow : .clear , lineWidth: 3)
                .foregroundStyle(.secondary)
                .ignoresSafeArea()
        )
    }
}


//{
//    @EnvironmentObject var updater: UpdateManager
//    @State var averageTemp: Float = 0.0
//    @State var egSelected: Bool = true
//
//    func setAllTo(temp: Int){
//        print("setting temp to: \(temp)")
//        for tado in updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)}).flatMap({$0.tempDevices}){
//            if !tado.isAC{
//                var newDevice = tado
//                newDevice.setTemp = Float(temp)
//                TadoKit().setTemp(device: newDevice)
//            }
//        }
//    }
//
//    func update(){
//        let rooms = updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)})
//        let tado = rooms.flatMap({$0.tempDevices}).filter({$0.isAC == false}).compactMap({$0.temp}).reduce(0, +)
//        let avg = tado/Float(rooms.flatMap({$0.tempDevices}).filter({$0.isAC == false}).count)
//        averageTemp = avg
//    }
//
//    var body: some View {
//        ScrollView{
//            VStack{
//            HStack{
//                Spacer()
//                VStack{
//                    VStack{
//                        Text("\(String(format: "%.1f", averageTemp))°")
//                            .foregroundColor(TadoKit().getTempColor(temp: averageTemp))
//                        .font(.system(size: 70))
//                        .shadow(color: TadoKit().getTempColor(temp: averageTemp), radius: 15, x: 0, y: 0)
//                    }.frame(height: 80).padding()
//                Text("Average Temp")
//                    .font(.largeTitle.bold())
//                    .padding(10)
//                }
//                Spacer()
//            }.padding(.bottom)
//                HStack{
//                    HStack{
//                        Button(action: {egSelected = true}){
//                            Text("EG")
//                                .frame(width: 65, height: 35)
//                                .foregroundColor(egSelected ? .white : .secondary)
//                                .background(egSelected ? .orange : .gray.opacity(0.3))
//                                .cornerRadius(30)
//                                .padding(.leading, 10)
//                        }
//                        Spacer()
//                        Button(action: {egSelected = false}){
//                            Text("OG")
//                                .frame(width: 65, height: 35)
//                                .foregroundColor(!egSelected ? .white : .secondary)
//                                .background(!egSelected ? .orange : .gray.opacity(0.3))
//                                .cornerRadius(30)
//                                .padding(.trailing, 10)
//                        }
//                    }
//                    .frame(width: 150, height: 45)
////                    .background(Color.gray.opacity(0.3))
//                    .background(.regularMaterial)
//                    .cornerRadius(30)
//                    Spacer()
//
//                    Menu(content: {
////                        List{
//                            Button(action: {setAllTo(temp: 0)}){
//                                Text("Off")
//                            }
//                            Button(action: {setAllTo(temp: 20)}){
//                                Text("20°")
//                            }
//                            Button(action: {setAllTo(temp: 22)}){
//                                Text("22°")
//                            }
//                            Button(action: {setAllTo(temp: 23)}){
//                                Text("23°")
//                            }
//                            Button(action: {setAllTo(temp: 24)}){
//                                Text("24°")
//                            }
//                        Button(action: {setAllTo(temp: 25)}){
//                            Text("25°")
//                        }
////                        }
//                    }, label: {
//                        Text("Set All")
//                            .padding(10)
//                            .padding([.leading, .trailing], 5)
//                            .background(.orange)
//                            .cornerRadius(30)
//                            .foregroundColor(.white)
//                    }).padding(10)
//                }
//            VStack{
//                ForEach(updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)})){room in
//                    ForEach(room.tempDevices.filter({$0.isAC == false})){tado in
//                        HStack{
//                            Text(room.name)
//                                .bold()
//                                Spacer()
//                            Text("\(Int(tado.setTemp)) ")
//                                .foregroundStyle(.secondary)
//                            Text(String(format: "%.1f", tado.temp))
//                                    .foregroundColor(.orange)
//                        }.font(.headline)
//                            .padding([.top, .bottom], 10)
//                        Divider()
//                    }
//                }
//                HStack{
//                    Text("Only Room Thermostats and Radiators are shown.")
//                        .foregroundColor(.secondary)
//                        .font(.callout)
//                        .padding([.top, .bottom], 10)
//                    Spacer()
//                }
//            }
//            .padding([.top, .bottom], 10)
//
//            .padding([.leading, .trailing])
//            .background(.regularMaterial)
//            .cornerRadius(13)
//            Spacer()
//        }
//            .padding()
//            .padding(.top)
//            .onChange(of: updater.lastUpdated, perform: {_ in update()})
//            .onChange(of: egSelected, perform: {_ in update()})
//            .onAppear(perform: update)
//        }
//    }
//}

struct AccessoryDetailAvgTemp_Previews: PreviewProvider {
    static var previews: some View {
        TadoOverview()
    }
}
