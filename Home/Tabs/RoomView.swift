//
//  RoomView.swift
//  Home
//
//  Created by David Bohaumilitzky on 12.06.21.
//

import SwiftUI

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

private struct OffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    
    value = nextValue()
    
  }
}

struct RoomView: View {
    @Binding var room: Room
    @EnvironmentObject var updater : UpdateManager
    @EnvironmentObject var sceneKit : SceneKit
    @EnvironmentObject var appState: AppState
    
    @State var activeLights: Int = 0
    @State var openBlinds: Int = 0
    @State var averageTemp: Float = 22.0
    @State var backgroundColors: [Color] = [Color]()
    @State var controlLight: Bool = false
    @State var controlTemp: Bool = false
    @State var selectedLight: Light = Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    @State var controlBlind: Bool = false
    @State var presenceControl: Bool = false
    @State var selectedBlind: Blind = Blind(id: "", name: "", position: 0, moving: false)
    @State var selectedTempDevice: TempDevice = TempDevice(id: "", isAC: false, name: "", manualMode: false, active: false, openWindow: false, temp: 0, setTemp: 0, humidity: 0, performance: 0)
//    @State var roomOccupied: Bool = false
//    @State var lastOccupied: String = "Unknown"
    @State var roomScenes: [SceneAutomation] = [SceneAutomation]()
    @State var showRoomControl: Bool = false
    @State var showDeviceSummary: Bool = false
    @State var showOccupied: Bool = false
    
    
    @State var humidityNotNominal: Bool = false
    @State var humidityDescription: String = ""
    @State var allOffScene = SceneAutomation(id: 0, name: "All Off", lights: [Light](), blinds: [Blind](), tado: [TempDevice](), active: false, schedule: nil, room: nil, icon: "moon.fill")
    
    
    func checkHumidity(){
        guard let device = room.tempDevices.first else{return}
        let humidityState = TadoKit().humidityIsNominal(tado: device)
        switch humidityState{
        case 0:
            humidityNotNominal = true
            humidityDescription = "Dry\n\(Int(device.humidity))%"
        case 1:
            humidityNotNominal = false
        case 2:
            humidityNotNominal = true
            humidityDescription = "Humid\n\(Int(device.humidity))%"
        default:
            humidityNotNominal = false
        }
    }
    func selectRoom(id: Int){
        guard let Room = updater.status.rooms.first(where: {$0.id == id}) else{return}
        appState.activeRoom = Room
    }
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func setScene(scene: SceneAutomation){
        sceneKit.setScene(scene: scene)
    }
    func roomOff(){
        sceneKit.roomOff(room: room)
    }
    func resetControls(){
        controlLight = false
        controlTemp = false
        controlBlind = false
        
    }
    func editLight(light: Light){
        resetControls()
        selectedLight = light
        controlLight = true
    }
    func editBlind(blind: Blind){
        resetControls()
        selectedBlind = blind
        controlBlind = true
    }
    func editTado(tado: TempDevice){
        resetControls()
        selectedTempDevice = tado
        controlTemp = true
    }
    func setup(){
        guard let currentRoom = updater.status.rooms.first(where: {$0.id == room.id})else{return}
        backgroundColors.removeAll()
        backgroundColors.append(ColorFromHex(hex: currentRoom.type.color))
        backgroundColors.append(Color(UIColor(ColorFromHex(hex: currentRoom.type.color)).darker(by: 50) ?? .clear))
        
        room = currentRoom
        let lights = currentRoom.lights.filter({$0.state == true})
        activeLights = lights.count
        
        let blinds = currentRoom.blinds.filter({$0.position != 0})
        openBlinds = blinds.count
        
        let temp = currentRoom.tempDevices.compactMap({$0.temp}).reduce(0, +)
        averageTemp = temp/Float(room.tempDevices.count)
        
        guard let updatedLight = currentRoom.lights.first(where: {$0.id == selectedLight.id})else{return}
        selectedLight = updatedLight
        
        guard let updatedBlind = currentRoom.blinds.first(where: {$0.id == selectedBlind.id})else{return}
        selectedBlind = updatedBlind
        
        guard let updatedTado = currentRoom.tempDevices.first(where: {$0.id == selectedTempDevice.id})else{return}
        selectedTempDevice = updatedTado
        
        roomScenes = updater.status.scenes
        checkHumidity()
        print("updating")
        print(updater.status.scenes.description)
    }
    
    var background: some View{
        ZStack{
            Image(room.id.description)
                .centerCropped()
                .ignoresSafeArea()
        }.ignoresSafeArea()
    }
    
    var quickActions: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                SceneControl(scene: allOffScene, onTap: roomOff)
                    .padding(.trailing, 5)
                ForEach(updater.status.scenes.filter({$0.room == room.id})){scene in
                    SceneControl(scene: scene, onTap: {setScene(scene: scene)})
                        .padding(.trailing, 5)
                }
            }
        }
    }
    var status: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                if activeLights != 0{
                    StatusItem(active: activeLights != 0, onDescription: activeLights == 1 ? "\(activeLights) Light\nOn" : "\(activeLights) Lights\nOn", offDescription: "Lights\nOff", icon: getDeviceIcon(type: .LightBulbMono, state: activeLights != 0, accent: .yellow), onTap: {showDeviceSummary.toggle()})
                }
                if  openBlinds != 0{
                    StatusItem(active: openBlinds != 0, onDescription: openBlinds == 1 ? "\(openBlinds) Blinds\nOpen" : "\(openBlinds) Blind\nOpen", offDescription: "Blinds\nClosed", icon: getDeviceIcon(type: .Blind, state: openBlinds != 0, accent: .teal), onTap: {showDeviceSummary.toggle()})
                }
                if room.lastOccupied != ""{
                    StatusItem(active: room.occupied, onDescription: "Now\nOccupied", offDescription: "Last Occupied\n\(IrrigationKit().getLocalTimeFromUnix(unix: room.lastOccupied))", icon: AnyView(
                        Image(systemName: "person.wave.2.fill")
                            .foregroundColor(room.occupied ? .teal : .secondary)
                            .foregroundStyle(room.occupied ? .primary : .secondary)
                    ), onTap: {showOccupied.toggle()})
                }
                if  room.openWindow{
                StatusItem(active: room.openWindow, onDescription: "Windows\nopen", offDescription: "", icon: AnyView(
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.teal)
                    ), onTap: {})
                }
                if humidityNotNominal{
                    StatusItem(active: humidityNotNominal, onDescription: humidityDescription, offDescription: "", icon: AnyView(
                        Image(systemName: "humidity.fill")
                            .foregroundColor(.orange)
                    ), onTap: {})
                }
                
                
                StatusItem(active: true, onDescription: "\(String(format: "%.1f", averageTemp))°C\n Average", offDescription: "\(String(format: "%.1f", averageTemp))°C\n Average", icon: AnyView(
                    Text("\(Int(averageTemp.isNaN ? 0 : averageTemp).description)°")
                        .foregroundColor(TadoKit().getTempColor(temp: averageTemp))
                ), onTap: {showDeviceSummary.toggle()})
                
//                VStack{
//                    if activeLights == 0{
//                        getDeviceIcon(type: .LightBulbMono, state: false, accent: .yellow)
//                            .padding()
//                            .background(.regularMaterial)
//                            .clipShape(Circle())
//                        Text("Lights\nOff")
//                            .lineLimit(2)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .multilineTextAlignment(.center)
//                    }else{
//                        getDeviceIcon(type: .LightBulbMono, state: true, accent: .yellow)
//                            .padding()
//                            .background(Color.white)
//                            .clipShape(Circle())
//                        Text(activeLights == 1 ? "\(activeLights) Light\nOn" : "\(activeLights) Lights\nOn")
//                            .lineLimit(2)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//
//                }.padding([.trailing])
//                VStack{
//                    if openBlinds == 0{
//                        getDeviceIcon(type: .Blind, state: false, accent: .cyan)
//                            .padding()
//                            .background(.regularMaterial)
//                            .clipShape(Circle())
//                        Text("Blinds\nClosed")
//                            .lineLimit(2)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .multilineTextAlignment(.center)
//                    }else{
//                        getDeviceIcon(type: .Blind, state: true, accent: .cyan)
//                            .padding()
//                            .background(Color.white)
//                            .clipShape(Circle())
//                        Text(openBlinds == 1 ? "\(openBlinds) Blind\n Open" : "\(openBlinds) Blinds\n Open")
//                            .lineLimit(2)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                }.padding([.trailing])
//                VStack{
//                    getDeviceIcon(type: .Heating, state: true, accent: .orange)
//                        .padding()
//                        .background(Color.white)
//                        .clipShape(Circle())
//                    Text("\(String(format: "%.1f", averageTemp))°C\n Average")
//                        .lineLimit(2)
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                }.padding([.trailing])
//                Button(action: {presenceControl.toggle()}){
//                    VStack{
//                        if !room.occupied{
//                            Image(systemName: "person.wave.2.fill")
//                                .font(.title2)
//                                .foregroundStyle(.secondary)
//                                .padding()
//                                .background(.regularMaterial)
//                                .clipShape(Circle())
//                            Text("Last Occupied\n\(IrrigationKit().getLocalTimeFromUnix(unix: room.lastOccupied))")
//                                .lineLimit(2)
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                                .multilineTextAlignment(.center)
//                        }else{
//                            Image(systemName: "person.wave.2.fill")
//                                .font(.title2)
//                                .foregroundColor(.teal)
//                                .padding()
//                                .background(Color.white)
//                                .clipShape(Circle())
//                            Text("Now\nOccupied")
//                                .lineLimit(2)
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                                .multilineTextAlignment(.center)
//                        }
//                    }.padding([.trailing]).foregroundColor(.primary)
//                }
            }
        }
    }

    var devices: some View{
        VStack{
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                ForEach(room.lights){light in
                    DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {editLight(light: light)}, onTap: {editLight(light: light)})
                    .id(UUID())
                }
                ForEach(room.blinds){blind in
                    DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))% Open", name: blind.name, active: blind.position != 0, offStatus: "Closed", onLongPress: {editBlind(blind: blind)}, onTap: {editBlind(blind: blind)})
                    .id(UUID())
                }
                ForEach(room.tempDevices){tado in
                    DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(format: "%.1f", tado.temp) )°", name: tado.name, active: true, offStatus: "Off",onLongPress: {editTado(tado: tado)}, onTap: {editTado(tado: tado)})
                        .id(UUID())
                }
            }.padding(.trailing, sizeOptimizer(iPhoneSize: 0, iPadSize: 300))
        }
    }
    var body: some View {
        GeometryReader{geo in
            ScrollView{
                if #available(iOS 15.0, *) {
                        VStack(alignment: .leading){
                            HStack(alignment: .top){
                                Text(room.name)
                                    .font(.title2.bold())
                                Spacer()
                                Menu(content: {
                                    ForEach(updater.status.rooms){room in
                                        Button(action: {selectRoom(id: Int(room.id))}){
                                            Text(room.name)
                                        }
                                        
                                    }
                                }, label: {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .foregroundStyle(.secondary)
                                })
                                    
                                
//                                Text("HOME")
//                                    .foregroundStyle(.tertiary)
                            }
                            status
                        }
                        .padding()
//                        .background(.thinMaterial)
//                        .cornerRadius(13)
                        .padding()
                    if room.name == "Garten"{
                        IrrigationRoom()
                    }
                    VStack(alignment: .leading){
                        Text("Devices")
                            .font(.title2.bold())
                        devices
                    }.padding()
                    VStack(alignment: .leading){
                        Text("Quick Actions")
                            .font(.title2.bold())
                        quickActions
                        Text("These actions only affect the current room.")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .padding(.top, 10)
                    }
                    .padding()
                } else {
                    VStack{
                        devices
                    }
                    .padding()
                    .background(Color(UIColor.gray))
                    .opacity(0.5)
                    .cornerRadius(13)
                }
                HStack{
                    Button(action: {showRoomControl.toggle()}){
                        Text("Edit...")
                            .foregroundColor(.primary)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }.padding(.leading)
                
                Spacer(minLength: 150)
            }
                .anchorPreference(key: OffsetKey.self, value: .top) {
                    geo[$0].y
                }
        }
        .sheet(isPresented: $presenceControl){
            PresenceRoomView(room: $room, active: $presenceControl)
        }
        .sheet(isPresented: $showRoomControl){
            RoomFavoriteControl(room: room)
        }
        .sheet(isPresented: $controlLight){
            LightControl(light: $selectedLight)
        }
        .sheet(isPresented: $controlBlind){
            BlindControl(blind: $selectedBlind)
        }
        .sheet(isPresented: $controlTemp){
            TadoControl(device: $selectedTempDevice)
        }
        .sheet(isPresented: $showDeviceSummary){
            RoomDeviceSummary(room: $room)
        }
        .sheet(isPresented: $showOccupied){
            OccupiedRoom(room: $room)
        }
        .navigationTitle(Text(room.name))
        .colorScheme(.dark)
        .background(background)
        .onAppear(perform: {setup()})
        .onChange(of: updater.status.rooms.description, perform: {value in setup()})
        .onChange(of: room.id, perform: {value in setup()})
        .onPreferenceChange(OffsetKey.self) {
//                print($0)
            print("Scroll Position: \($0)")
            if $0 < -50 {
                DispatchQueue.main.async {
                    withAnimation {
                        print("Scrolling")
//                        self.scrolling = true
                    }
                }
            }else {
                DispatchQueue.main.async {
                    withAnimation {
//                        self.scrolling = false
                        print("Stopped")
                    }
                }
            }
        }
    }
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView(room: Room(id: 0, name: "David", floor: 0, lights: [Light(id: "h", name: "Deckenlicht", isHue: false, isDimmable: false, r: 0, g: 0, b: 0, brightness: 100, state: false), Light(id: "hh", name: "Light Name", isHue: false, isDimmable: false, r: 0, g: 0, b: 0, brightness: 100, state: false), Light(id: "hhh", name: "Ligscscscscscht Name", isHue: false, isDimmable: false, r: 0, g: 0, b: 0, brightness: 100, state: false)], blinds: [Blind(id: "hh", name: "Blind name", position: 10, moving: false)], tempDevices: [TempDevice(id: "k", isAC: false, name: "Temp Device", manualMode: false, active: true, openWindow: false, temp: 22.2, setTemp: 22.0, humidity: 34, performance: 50)], type: RoomType(icon: "", color: "")))
//    }
//}
