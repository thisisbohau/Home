//
//  SceneEditScene.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

struct SceneEditScene: View {
    @Binding var active: Bool
    @Binding var scene: SceneAutomation
    @EnvironmentObject var updater: UpdateManager
    
    @State var step: Int = 1
//    @State var title: String = "Select Accessories"
    
//    @State var rooms: [Room] = [Room]()
    @State var scheduleString: String = ""
    @State var editSchedule: Bool = false
    @State var editDevices: Bool = false
    @State var addDevices: Bool = false
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func delete(){
        SceneKit().deleteScene(scene: scene)
        active = false
    }
    func edit(){
        SceneKit().editScene(scene: scene)
        active = false
    }
    func update(){
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
                
                Button(action: {editSchedule.toggle()}){
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
            Button(action: edit){
                HStack{
                    Spacer()
                    Text("Update")
                        .font(.body.bold())
                    Spacer()
                }

            }.buttonStyle(RectangleButtonStyle(color: scene.name == "" ? .gray : Color.accentColor)).disabled(scene.name == "")
                .padding(.bottom)
        }
        .padding()
        .background(Color("background").ignoresSafeArea())
    }
    var maisn: some View{
        ZStack{
            Form{
                Section(header: Text("Name")){
                    TextField("Name", text: $scene.name)
                }
                Section(header: Text("Schedule")){
                    if scene.schedule?.isEmpty ?? true{
                        Text("No Schedule")
                            .foregroundColor(.secondary)
                    }else{
                        Text(scheduleString)
                    }
                    Button(action: {editSchedule.toggle()}){
                        Text("Edit Schedule")
                    }
                }
                Section(header: Text("Icon")){
                    Menu(content: {
                        ForEach(SceneKit().sceneIcons){icon in
                            Button(action: {scene.icon = icon.id.description}){
                                Image(systemName: icon.id)
                                    .id(icon.id.description)
                            }
                        }
                    }, label: {
                        HStack{
                            Text("Icon")
                        }
                    })
                }
                Section(header: Text("Room")){
                    Menu(updater.status.rooms.first(where: {$0.id == scene.room})?.name ?? "Room"){
                        ForEach(updater.status.rooms){room in
                            Button(action: {scene.room = room.id}){
                            Text(room.name)
                                .id(room.id)
                            }
                        }
                    }
                }
                Button(action: {editDevices.toggle()}){
                    Text("Edit Accessories")
                }
                devices
                Button(action: {addDevices.toggle()}){
                    Label("Add|Remove Devices", systemImage: "ellipsis.circle")
                }
                Button(action: delete){
                    Text("Delete Scene")
                        .foregroundColor(.pink)
                }
                Spacer(minLength: 150)
            }
            VStack{
                Spacer()
                Button(action: edit){
                    HStack{
                        Spacer()
                        Text("Save changes")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                }.buttonStyle(RectangleButtonStyle(color: scene.name == "" ? .gray : Color.accentColor)).disabled(scene.name == "")
            }.padding(10)
                
        }
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    if editSchedule{
                        VStack{
                            SceneSchedule(scene: $scene, step: $step)
                            Spacer()
                            Button(action: {editSchedule.toggle()}){
                                HStack{
                                    Spacer()
                                    Text("Done")
                                        .font(.body.bold())
                                    Spacer()
                                }
                            }.buttonStyle(RectangleButtonStyle(color: .accentColor))
                        }
                        
                            
                    }else{
                        main
                    }
                }
                .background(Color("background").ignoresSafeArea())
                .onAppear(perform: update)
                .onChange(of: scene.schedule?.description, perform: {value in update()})
                .navigationTitle(scene.name)
                .animation(.easeInOut, value: step)
          

//                .sheet(isPresented: $editDevices){
//                    NavigationView{
//                        SceneEditAccessories(scene: $scene, step: $step)
//                            .padding([.leading, .trailing, .bottom])
//                            .navigationTitle("Edit Accessories")
//                    }
//                }
//                .sheet(isPresented: $addDevices){
//                    NavigationView{
//                        SceneSelectAccessories(scene: $scene, step: $step)
//                            .padding([.leading, .trailing, .bottom])
//                            .navigationTitle("Add or remove Devices")
//                    }
//                }
//                .sheet(isPresented: $editSchedule){
//                    NavigationView{
//                        SceneSchedule(scene: $scene, step: $step)
//                            .navigationTitle("Schedule")
//                            .background(Color("background").ignoresSafeArea())
//                    }
//
//                }
            } .background(Color("background").ignoresSafeArea())
        }
//        .sheet(isPresented: $editLight){
//            SceneLightControl(scene: $scene, light: $selectedLight)
//        }
    }
}

//struct SceneEditScene_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneEditScene()
//    }
//}
