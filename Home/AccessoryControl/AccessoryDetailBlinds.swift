//
//  AccessoryDetailBlinds.swift
//  Home
//
//  Created by David Bohaumilitzky on 16.08.21.
//

import SwiftUI

struct AccessoryDetailBlinds: View {
    @EnvironmentObject var updater: Updater
    @State var closedBlinds: [Blind] = [Blind]()
    @State var egSelected: Bool = true
    
    @State var selectedBlind: Blind = Blind(id: "", name: "", position: 0, moving: false)
    @State var controlBlind: Bool = false
    
    func closeBlind(blind: Blind){
        var newBlind = blind
        newBlind.position = 0
        BlindKit().setBlind(blind: newBlind)
    }
    func controlBlind(blind: Blind){
        selectedBlind = blind
        controlBlind = true
    }
    
    func update(){
        let blinds = updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)}).flatMap({$0.blinds})
        closedBlinds = blinds.filter({$0.position > 10})
    }
    var body: some View {
        ScrollView{
            VStack{
            HStack{
                Spacer()
                VStack{
                    VStack{
                    Image("blind.open")
                        .renderingMode(.original)
                        .font(.system(size: 70))
                        .shadow(color: .teal, radius: 15, x: 0, y: 0)
                    }.frame(height: 80).padding()
                Text("Open Blinds")
                    .font(.largeTitle.bold())
                    .padding(10)
                }
                Spacer()
            }.padding(.bottom)
                HStack{
                    HStack{
                        Button(action: {egSelected = true}){
                            Text("EG")
                                .frame(width: 65, height: 35)
                                .foregroundColor(egSelected ? .white : .secondary)
                                .background(egSelected ? .teal : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.leading, 10)
                        }
                        Spacer()
                        Button(action: {egSelected = false}){
                            Text("OG")
                                .frame(width: 65, height: 35)
                                .foregroundColor(!egSelected ? .white : .secondary)
                                .background(!egSelected ? .teal : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(width: 150, height: 45)
//                    .background(Color.gray.opacity(0.3))
                    .background(.regularMaterial)
                    .cornerRadius(30)
                    Spacer()
                }
            VStack{
                ForEach(closedBlinds){blind in
                    HStack{
                        Text(blind.name)
                            .bold()
                            Spacer()
                        Button(action: {closeBlind(blind: blind)}){
                            Text("Close")
                                .foregroundColor(.teal)
                        }
                    }.font(.headline)
                        .onLongPressGesture {
                            controlBlind(blind: blind)
                        }
                        .padding([.top, .bottom], 10)
                    Divider()
                }
                HStack{
                    Text("For extended controls long tap blind.")
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .padding([.top, .bottom], 10)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 10)
            
            .padding([.leading, .trailing])
            .background(.regularMaterial)
            .cornerRadius(13)
            Spacer()
        }
            .padding()
            .padding(.top)
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
            .onChange(of: egSelected, perform: {_ in update()})
            .sheet(isPresented: $controlBlind){
                BlindControl(blind: $selectedBlind)
            }
        }
    }
}

struct AccessoryDetailBlinds_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryDetailBlinds()
    }
}
