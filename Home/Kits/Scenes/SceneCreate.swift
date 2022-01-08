//
//  SceneCreate.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI

struct SceneCreate: View {
    @EnvironmentObject var updater: UpdateManager
    @Binding var scene: SceneAutomation
    @Binding var step: Int
    @State var scheduleString: String = ""
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func create(){
        SceneKit().createScene(scene: scene)
        step = 5
    }
    func setup(){
        var schedule: [String] = [String]()
        for day in scene.schedule ?? [Schedule](){
            schedule.append(SceneKit().getShortDayDescription(id: day.id))
        }
        scheduleString = schedule.joined(separator: ", ")
    }
    
    var devices: some View{
        VStack(alignment: .leading){
            HStack{
                Image("summary")
                    .symbolRenderingMode(.multicolor)
                Text("Devices")
                    .font(.title3.bold())
                Spacer()
            }
            Text("Important: As this Scene is a snapshot of the current device state you will not be able to change the configuration after creating this scene.")
                .font(.caption)
                .padding([.top, .bottom], 10)
            
            VStack(alignment: .leading){
                Text("\(scene.lights.count) LIGHTS")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(scene.lights){light in
                        DeviceControl(type: light.isHue ? .LightBulbDynamic : .LightBulbMono, status: "\(String(Int(light.brightness)))%", name: light.name, active: light.state, offStatus: "Off", onLongPress: {}, onTap: {})
                    }
                }
            } .padding([.bottom, .top])
            
            VStack(alignment: .leading){
                Text("\(scene.blinds.count) BLINDS")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(scene.blinds){blind in
                        DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))% Open", name: blind.name, active: blind.position != 0, offStatus: "Closed", onLongPress: {}, onTap: {})
                            .id(UUID())
                    }
                }
            } .padding(.bottom)
            
            VStack(alignment: .leading){
                Text("\(scene.tado.count) ACs")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(scene.tado){tado in
                        DeviceControl(type: tado.isAC ? .Cooling : .Heating, status: "\(String(format: "%.1f", tado.setTemp) )°C", name: tado.name, active: true, offStatus: "Off", onLongPress: {}, onTap: {})
                            .id(UUID())
                    }
                }
            } .padding(.bottom)
            
            Button(action: {step = 2}){
                HStack{
                    Spacer()
                    Text("Edit")
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color("fill"))
        .cornerRadius(15)
    }
    
    var main: some View{
        VStack{
            HStack{
                Spacer()
                Menu(content: {
                    ForEach(SceneKit().sceneIcons){icon in
                        Button(action: {scene.icon = icon.id.description}){
                            Image(systemName: icon.id)
                                .id(icon.id.description)
                        }
                    }
                }, label: {
                    Image(systemName: scene.icon ?? "heart.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Circle().foregroundColor(Color("fill")))
                })
                Spacer()
                
            }.padding()
            TextField("Name", text: $scene.name)
                .padding(10)
                .background(Color("fill"))
                .cornerRadius(10)
                .padding(.bottom)
            
            VStack{
                HStack{
                    Image(systemName: "square.split.bottomrightquarter")
                        .foregroundColor(.pink)
                    Text("Room")
                        .font(.title3.bold())
                        
                    Spacer()
                }

                Menu(content: {
                    ForEach(updater.status.rooms){room in
                        Button(action: {scene.room = room.id}){
                        Text(room.name)
                            .id(room.id)
                        }
                    }
                }, label: {
                    Text(updater.status.rooms.first(where: {$0.id == scene.room})?.name ?? "Room")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                        .padding([.top, .bottom])
                })
            }
            .padding()
            .background(Color("fill"))
            .cornerRadius(15)
            
            VStack{
                HStack{
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.accentColor)
                    Text("Schedule")
                        .font(.title3.bold())
                    Spacer()
                }
                if scene.schedule?.isEmpty ?? true{
                    Text("No Schedule")
                        .padding()
                        .foregroundStyle(.secondary)
                }else{
                    ForEach(scene.schedule?.sorted(by: {$1.id > $0.id}) ?? [Schedule]()){slot in
                        HStack{
                            Text(SceneKit().getDay(id: slot.id))
                                .bold()
                            Spacer()
                            Text(IrrigationKit().getLocalTimeFromUnix(unix: slot.time))
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                        .padding(3)
                    }
                }
                
                Button(action: {step = 3}){
                    HStack{
                        Spacer()
                        Text("Edit")
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color("fill"))
            .cornerRadius(15)

            
            devices
            Spacer()
            Button(action: create){
                HStack{
                    Spacer()
                    Text("Create")
                        .font(.body.bold())
                    Spacer()
                }

            }.buttonStyle(RectangleButtonStyle(color: scene.name == "" ? .gray : Color.accentColor)).disabled(scene.name == "")
                .padding(.bottom)
        }
        .padding()
        .background(Color("background").ignoresSafeArea())
    }
    var body: some View {
        main
//        ZStack{
//            Form{
//                Section(header: Text("Name")){
//                    TextField("Name", text: $scene.name)
//                }
//                Section(header: Text("Schedule")){
//                    if scene.schedule?.isEmpty ?? true{
//                        Text("No Schedule")
//                            .foregroundColor(.secondary)
//                    }else{
//                        Text(scheduleString)
//                    }
//                }
//                Section(header: Text("Icon")){
////                    HStack{
////                        Spacer()
////                        Image(systemName: scene.icon!.description)
////                            .font(.largeTitle)
////                        Spacer()
////                    }
//                    Menu(content: {
//                        ForEach(SceneKit().sceneIcons){icon in
//                            Button(action: {scene.icon = icon.id.description}){
//                                Image(systemName: icon.id)
//    //                                .font(.title2)
//                                    .id(icon.id.description)
//                            }
//
//                        }
//                    }, label: {
//                        HStack{
//
//                            Text("Icon")
//                        }
//
//                    })
//
//                }
//                Section(header: Text("Room")){
//                    Menu(updater.status.rooms.first(where: {$0.id == scene.room})?.name ?? "Room"){
//                        ForEach(updater.status.rooms){room in
//                            Button(action: {scene.room = room.id}){
//                            Text(room.name)
////                                .font(.title2)
//                                .id(room.id)
//                            }
//
//                        }
//                    }
////                    Picker(updater.status.rooms.first(where: {$0.id == scene.room})?.name ?? "Room", selection: $scene.room){
////                        ForEach(updater.status.rooms){room in
////                            Button(action: {scene.room = room.id}){
////                            Text(room.name)
//////                                .font(.title2)
////                                .id(room.id)
////                            }
////
////                        }
////                    }
//                }
//                devices
//            }
//            VStack{
//                Spacer()
//                Button(action: create){
//                    HStack{
//                        Spacer()
//                        Text("Create")
//                            .font(.body.bold())
//                        Spacer()
//                    }
//
//                }.buttonStyle(RectangleButtonStyle(color: scene.name == "" ? .gray : Color.orange)).disabled(scene.name == "")
//            }.padding(10)
//
//        }
        .onAppear(perform: setup)
    }
}

//struct SceneCreate_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneCreate()
//    }
//}
