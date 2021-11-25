//
//  RoomTagSetup.swift
//  Home
//
//  Created by David Bohaumilitzky on 31.07.21.
//

import SwiftUI

struct RoomTagRoom: View{
    var room: Room
    var selection: String
    var body: some View{
        VStack{
            HStack{
                Image(systemName: room.type.icon)
                    .font(.title)
                    .foregroundColor(ColorFromHex(hex: room.type.color))
                    .padding(.trailing, 10)
                VStack(alignment: .leading){
                    Text(room.name)
                        .bold()
                        .foregroundColor(selection == room.id.description ? Color.black : Color.primary)
                }
                Spacer()
            }.padding()

        }
        .background(selection == room.id.description ? Color.white : Color.clear)
        .background(.thinMaterial)
        .cornerRadius(18)
        .foregroundColor(.primary)
        .aspectRatio(3.3, contentMode: .fit)
    }
}

struct RoomTagSetup: View {
    @StateObject var nfc = NFCReader()
    @StateObject var nfcProgrammer = NFCProgrammer()
    @EnvironmentObject var updater: Updater

    func programTag(){
        nfcProgrammer.startScanning()
    }
    

    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
    //            Picker("Room", selection: $nfcProgrammer.selectedRoom){
                ScrollView{
                    ForEach(updater.status.rooms){room in
                        Button(action: {nfcProgrammer.selectedRoom = room.id.description}){
                            RoomTagRoom(room: room, selection: nfcProgrammer.selectedRoom)
                        }
                    }
                }.padding(.bottom)
                Spacer()
                Button(action: programTag){
                    HStack{
                        Spacer()
                        Text("Program RoomTag")
                            .font(.body.bold())
                        Spacer()
                    }

                }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
            }
            .padding()
            .navigationTitle("Tag location")
        }
    }
}

struct RoomTagSetup_Previews: PreviewProvider {
    static var previews: some View {
        RoomTagSetup()
    }
}
