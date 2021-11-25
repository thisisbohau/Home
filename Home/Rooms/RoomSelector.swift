//
//  RoomSelector.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.10.21.
//

import SwiftUI

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}


struct RoomCard: Identifiable{
    var id: Int
    var room: Room
    var show: Bool
}
struct RoomSnapper: View{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var sceneKit : SceneKit
    @State var x: CGFloat = 0
    @State var count: CGFloat = 0
    @State var screen = UIScreen.main.bounds.width - 30
    @State var op: CGFloat = 0
    
    @State var data = [RoomCard]()
    @State var lights: Int = 0
    @State var blinds: Int = 0
    @State var occupied: Bool = false
    @State var lastOccupied: String = ""
    
    func roomOff(){
        guard let room = updater.status.rooms.first(where: {$0.id == appState.activeRoom.id}) else{return}
        sceneKit.roomOff(room: room)
    }
    
    func expand(){
        appState.activeTab = 2
        appState.showRoomSelector = false
    }
    func refreshData(){
        guard let room = updater.status.rooms.first(where: {$0.id == appState.activeRoom.id}) else{return}
        lights = room.lights.filter({$0.state == true}).count
        blinds = room.blinds.filter({$0.position > 90}).count
        occupied = room.occupied
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        lastOccupied = formatter.string(from: Date(timeIntervalSince1970: Double(room.lastOccupied) ?? 0))
        
    }
    func update(){
        for room in updater.status.rooms{
            if !data.contains(where: {$0.id == room.id}){
                data.append(RoomCard(id: room.id, room: room, show: false))
            }
            
        }
        refreshData()
    }
    
    func updateHeight(value: Int){
        for i in 0..<data.count{
            data[i].show = false
        }
        data[value].show = true
        guard let room = updater.status.rooms.first(where: {$0.id == data[value].id})else{return}
        appState.activeRoom = room
        refreshData()
    }
    
    var body: some View{
        VStack{
            VStack{
                HStack(spacing: 15){
                    ForEach(data){i in
                        Image(i.room.id.description)
                            .centerCropped()
                            .frame(width: UIScreen.main.bounds.width - 30, height: i.show ? sizeOptimizer(iPhoneSize: 200, iPadSize: 400) : sizeOptimizer(iPhoneSize: 140, iPadSize: 280))
                            .overlay(
                                VStack{
                                    Spacer()
                                    HStack{
                                        Text(i.room.name)
                                            .font(.title.bold())
                                            .foregroundStyle(.secondary)
                                            .padding()
                                        Spacer()
                                    }
                                }
                            )
                            .cornerRadius(20)
                            .offset(x: self.x)
                            .highPriorityGesture(DragGesture()
                                .onChanged({(value) in
                                if value.translation.width > 0{
                                    self.x = value.location.x
                                }else{
                                    self.x = value.location.x - self.screen
                                    
                                }
                            })
                                                    .onEnded({ (value) in
                                if value.translation.width > 0{
                                    if value.translation.width > ((self.screen - 80)/2) && Int(self.count) != 0{
                                        self.count -= 1
                                        self.updateHeight(value: Int(self.count))
                                        self.x = -((self.screen + 15) * self.count)
                                    }else{
                                        self.x = -((self.screen + 15) * self.count)
                                    }
                                }else{
                                    if -value.translation.width > ((self.screen - 80) / 2) && Int(self.count) != (self.data.count - 1){
                                        self.count += 1
                                        self.updateHeight(value: Int(self.count))
                                        self.x = -((self.screen + 15) * self.count)
                                    }else{
                                        self.x = -((self.screen + 15) * self.count)
                                    }
                                }
                            })
                        )
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: op.self)
                .padding(.bottom)
                
                HStack{
                    VStack(alignment: .leading){
                        HStack{
                            if lights > 0{
                                Image("light.bulb")
                                    .renderingMode(.original)
                                    .font(.caption)
                                Text(String(lights))
                                
                            }else{
                                Image("light.bulb.off")
                                    .renderingMode(.original)
                                    .font(.caption)
                            }
                            Image(systemName: "circle.fill")
                                .font(.system(size: 5))
                                .foregroundStyle(.secondary)
                            if blinds > 0{
                                Image("blind.open")
                                    .renderingMode(.original)
                                    .font(.caption)
                                Text(String(blinds))
                            }else{
                                Image("blind.closed")
                                    .renderingMode(.original)
                                    .font(.caption)
                            }
                        }
                        HStack{
                            if occupied{
                                Image(systemName: "person.wave.2.fill")
                                    .foregroundColor(.teal)
                                    .font(.caption)
                                    .padding(10)
                                    .background(Circle().foregroundColor(.teal).blur(radius: 30))
                                Text("Now Occupied")
                                    .font(.caption)
                            }else{
                                Image(systemName: "person.wave.2.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .padding(10)
                                Text("Last Occupied: \(lastOccupied)")
                                    .font(.caption)
                            }
                            
                        }
                    }
                    Spacer()
                    Button(action: roomOff){
                        Image(lights > 0 ? "light.bulb" : "light.bulb.off")
                            .renderingMode(.original)
                            .padding()
                            .background(Circle().foregroundStyle(.regularMaterial))
                    }.padding(.trailing)
                    Button(action: expand){
                        Image(systemName: "rectangle.expand.vertical")
                            .renderingMode(.original)
                            .padding()
                            .background(Circle().foregroundStyle(.regularMaterial))
                    }.padding([.leading, .trailing])
                }
                .padding([.leading, .trailing])
            }
            .padding(.bottom, 30)
            .padding(.top, 30)
            .padding(.top)
            .background(
                Rectangle()
                    .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                    .foregroundStyle(.regularMaterial))
            .shadow(radius: 10)
            .ignoresSafeArea()
            
            Button(action: {withAnimation(.linear){appState.showRoomSelector = false}}){
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                    }
                }
            }
        }
        .transition(.slide.combined(with: .slide))
        .onAppear(perform: {
            update()
            self.op = ((self.screen + 15) * CGFloat(self.data.count / 2)) - (self.data.count % 2 == 0 ? ((self.screen + 15) / 2) : 0)
            let selected = data.firstIndex(where: {$0.room.id == appState.activeRoom.id}) ?? 0
            self.data[selected].show = true
    
            self.x = -((self.screen + 15) * CGFloat(selected))
            refreshData()
        })
        .onChange(of: updater.lastUpdated, perform: {_ in refreshData()})
    }
}
struct RoomSelector: View {
    var colors: [Color] = [.blue, .green, .red, .orange]
    @State var index: Int = 0
    var body: some View {
        RoomSnapper()
    }
}

struct RoomSelector_Previews: PreviewProvider {
    static var previews: some View {
        RoomSelector()
    }
}
