//
//  Rooms.swift
//  Home
//
//  Created by David Bohaumilitzky on 13.06.21.
//

import SwiftUI
func ColorFromHex(hex: String)->Color{
    var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexString.hasPrefix("#"){
        hexString.remove(at: hexString.startIndex)
    }
    if hexString.count != 6{
        return Color.accentColor
    }
    
    var rgb : UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&rgb)
    
    return Color.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
    green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
    blue: CGFloat(rgb & 0x0000FF) / 255.0)
    
}



struct Rooms: View {
    @EnvironmentObject var updater: UpdateManager
    @State var selectedRoom: Room = testRoom
    @State var showRoomSelector = false
    
    func selectRoom(room: Room){
        selectedRoom = room
        print("room switched")
    }
    func setup(){
        guard let room = updater.status.rooms.first else{return}
        selectRoom(room: room)
    }
    var roomSelector: some View{
        GeometryReader{geo in
            VStack{
                Spacer()
                ScrollViewReader{proxy in
                    ScrollView(.horizontal, showsIndicators: false){
        //
                        HStack(alignment: .top){
                            ForEach(updater.status.rooms){room in
                                Button(action: {selectRoom(room: room)}){
                                    VStack{
                                        Image(systemName: room.type.icon)
                                            .foregroundColor(ColorFromHex(hex: room.type.color))
        //                                    .foregroundColor(Color(hue: room.type.hue/360, saturation: room.type.saturation/360, brightness: room.type.brightness/360))
                                            .font(.title2)
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            
                                        if #available(iOS 15.0, *) {
                                            Text(room.name)
                                                .bold()
                                                .foregroundColor(.white)
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                                .lineLimit(2)
                                        } else {
                                            Text(room.name)
                                                .bold()
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                                .lineLimit(2)
                                        }
                                    }.frame(width: 100)
                                }
                            }
        //                }
                        }.padding(10)
                    
                    }.onChange(of: selectedRoom.id, perform: {Room in
                        withAnimation(.linear, {
                            proxy.scrollTo(selectedRoom.id, anchor: .center)})
                        })
                
                    
                }.padding(.top, 10).background(.thinMaterial)
            }
        }
        
    }
    var body: some View {
        
            ZStack{
                NavigationView{
                    RoomView(room: $selectedRoom)
                    
                }
                .navigationViewStyle(StackNavigationViewStyle())
#if !os (tvOS)
                .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
                         
                            .onChanged({value in
//                    print("GESTURE\(value)")
//                    showRoomSelector = true
                                if value.translation.width < 0 {
                                    // left
                                }

                                if value.translation.width > 0 {
                                    // right
                                }
                    if value.translation.height < 0 {
                        // up
                        withAnimation(.linear, {
                            showRoomSelector = true
                        })
                       
                    }

                    if value.translation.height > 0 {
                        withAnimation(.linear, {
                            showRoomSelector = false
                        })
                    }
                             //down
                            }))#endif
                if showRoomSelector{
                    VStack{
                        Spacer()
                        if #available(iOS 15.0, *) {
                            roomSelector
                                
                        } else {
                            roomSelector
                                .background(Color.gray.opacity(0.7))
                        }
                    }
                }
            }.onAppear(perform: setup)
//            .onChange(of: showRoomSelector, perform: {value in
//                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
//                    showRoomSelector = false
//                }
//            })
    }
}

struct Rooms_Previews: PreviewProvider {
    static var previews: some View {
        Rooms()
    }
}
