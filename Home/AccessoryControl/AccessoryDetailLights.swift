//
//  accessoryDetail.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.08.21.
//

import SwiftUI

struct AccessoryDetailLights: View {
    @EnvironmentObject var updater: UpdateManager
    @State var activeLights: [Light] = [Light]()
    @State var inactiveLights: [Light] = [Light]()
    @State var selectedFloor: Int = 2
    @State var lightsOn: Bool = false
    @State var viewSize: CGSize = CGSize(width: 0, height: 0)
    
    @State var animateChanges: Bool = false
    @State var animate: Bool = false
    @State var animateTo: Bool = false
    @State var autoAdaptOn: Bool = false
    
    @State var selectedLight: Light = Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    @State var controlLight: Bool = false
    @State var selectionOptions: [SelectionPoint] = [SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 1, icon: AnyView(Text("EG").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 2, icon: AnyView(Text("OG").rotationEffect(Angle(degrees: 90))), title: "")]
    @State var selectedOption: SelectionPoint = SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: "")
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func turnLightOff(light: Light){
        var offLight = light
        offLight.state = false
        offLight.brightness = 0
        LightKit().setColor(light: offLight)
    }
    func controlLight(light: Light){
        selectedLight = light
        controlLight = true
    }
    
    func autoAdapt(){
        Task{
            DispatchQueue.main.async {
                animateTo = true
                autoAdaptOn = true
            }
            
            await LightKit().autoAdaptLights(lights: activeLights)
            
            DispatchQueue.main.async {
                animateTo = false
            }
        }
        
    }
    
    func floorOff(){
        animateTo = true
        if selectedFloor == 2{
            SceneKit().floorOff(floor: 0){_ in
                SceneKit().floorOff(floor: 1){_ in
                }
            }
        }else{
            SceneKit().floorOff(floor: selectedFloor){_ in
            }
        }
        
    }
    func update(){
        switch selectedOption.id{
        case 0:
            selectedFloor = 2
        case 1:
            selectedFloor = 0
        case 2:
            selectedFloor = 1
        default:
            selectedFloor = 2
        }
        if selectedFloor == 2{
            let lights = updater.status.rooms.flatMap({$0.lights})
            activeLights = lights.filter({$0.state})
            inactiveLights = lights.filter({$0.state == false})
        }else{
            let lights = updater.status.rooms.filter({$0.floor == selectedFloor}).flatMap({$0.lights})
            activeLights = lights.filter({$0.state})
            inactiveLights = lights.filter({$0.state == false})
        }
        
        if activeLights.count > 0{
            lightsOn = true
        }else{
            lightsOn = false
            animateTo = false
        }
        
    }
    var topLevelControl: some View{
        HStack{
            Image(lightsOn ? "light.bulb" : "light.bulb.off")
                .font(.largeTitle)
                .symbolRenderingMode(.multicolor)
            
            VStack(alignment: .leading){
                Text("Lights")
                    .font(.title.bold())
                
                if activeLights.count < 0{
                    Text("Off")
                        .foregroundStyle(.secondary)
                }else{
                    Text("\(String(Int(activeLights.count))) \(activeLights.count == 1 ? "Light" : "Lights") On")
                        .foregroundStyle(.secondary)
                }
            }
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
            sectionControl
            
            VStack{
                //off control
                activeLightList
            }
            VStack{
                //                Text("All")
                //                    .font(.title2.bold())
                //                    .foregroundStyle(.secondary)
                inactiveLightList
            }
            .padding(.top)
            Spacer()
        }
    }
    
    var quickActions: some View{
        HStack{
            Button(action: floorOff){
                HStack{
                    Image(lightsOn ? "light.bulb" : "light.bulb.off")
                        .symbolRenderingMode(.multicolor)
                    VStack(alignment: .leading){
                        Text("Turn Off")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("All lights")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(lightsOn ? .black : .white)
                    Spacer()
                }
                .padding(10)
                .onCondition(lightsOn, transform: {view in
                    view.background(.white)
                })
                .onCondition(!lightsOn, transform: {view in
                    view.background(.regularMaterial)
                })
                .cornerRadius(18)
            }
            
            Button(action: autoAdapt){
                HStack{
                    Image(systemName: "sparkles")
                        .foregroundColor(.teal)
                    VStack(alignment: .leading){
                        Text("AutoAdapt")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("All active lights")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(autoAdaptOn ? .black : .white)
                    Spacer()
                }
                .padding(10)
                .onCondition(autoAdaptOn, transform: {view in
                    view.background(.white)
                })
                .onCondition(!autoAdaptOn, transform: {view in
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
    var activeLightList: some View{
        VStack{
            quickActions
                .onCondition(lightsOn, transform: {view in
                    view
                        .padding(.bottom)
                })
            if lightsOn{
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(activeLights){light in
                        DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {controlLight(light: light)}, onTap: {turnLightOff(light: light)})
                    }
                }
            }
        }
        .padding(10)
        .background(.regularMaterial)
        .cornerRadius(25)
    }
    var inactiveLightList: some View{
        VStack{
            ForEach(updater.status.rooms){room in
                VStack{
                    HStack{
                        Text(room.name)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                        ForEach(room.lights){light in
                            DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {controlLight(light: light)}, onTap: {turnLightOff(light: light)})
                        }
                    }
                }.animation(nil, value: animate)
            }
        }
    }
    var body: some View {
        GeometryReader{proxy in
            ScrollView(showsIndicators: false){
                main
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
            .onChange(of: selectedOption.id, perform: {_ in update()})
            .onAppear(perform: update)
            .sheet(isPresented: $controlLight){
                LightControl(light: $selectedLight)
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

//struct accessoryDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AccessoryDetail()
//    }
//}
