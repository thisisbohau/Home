//
//  AccessoryDetailAvgTemp.swift
//  Home
//
//  Created by David Bohaumilitzky on 16.08.21.
//

import SwiftUI

struct AccessoryDetailAvgTemp: View {
    @EnvironmentObject var updater: Updater
    @State var averageTemp: Float = 0.0
    @State var egSelected: Bool = true
    
    func setAllTo(temp: Int){
        print("setting temp to: \(temp)")
        for tado in updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)}).flatMap({$0.tempDevices}){
            if !tado.isAC{
                var newDevice = tado
                newDevice.setTemp = Float(temp)
                TadoKit().setTemp(device: newDevice)
            }
        }
    }
    
    func update(){
        let rooms = updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)})
        let tado = rooms.flatMap({$0.tempDevices}).filter({$0.isAC == false}).compactMap({$0.temp}).reduce(0, +)
        let avg = tado/Float(rooms.flatMap({$0.tempDevices}).filter({$0.isAC == false}).count)
        averageTemp = avg
    }
    
    var body: some View {
        ScrollView{
            VStack{
            HStack{
                Spacer()
                VStack{
                    VStack{
                        Text("\(String(format: "%.1f", averageTemp))°")
                            .foregroundColor(TadoKit().getTempColor(temp: averageTemp))
                        .font(.system(size: 70))
                        .shadow(color: TadoKit().getTempColor(temp: averageTemp), radius: 15, x: 0, y: 0)
                    }.frame(height: 80).padding()
                Text("Average Temp")
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
                                .background(egSelected ? .orange : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.leading, 10)
                        }
                        Spacer()
                        Button(action: {egSelected = false}){
                            Text("OG")
                                .frame(width: 65, height: 35)
                                .foregroundColor(!egSelected ? .white : .secondary)
                                .background(!egSelected ? .orange : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(width: 150, height: 45)
//                    .background(Color.gray.opacity(0.3))
                    .background(.regularMaterial)
                    .cornerRadius(30)
                    Spacer()
                    
                    Menu(content: {
//                        List{
                            Button(action: {setAllTo(temp: 0)}){
                                Text("Off")
                            }
                            Button(action: {setAllTo(temp: 20)}){
                                Text("20°")
                            }
                            Button(action: {setAllTo(temp: 22)}){
                                Text("22°")
                            }
                            Button(action: {setAllTo(temp: 23)}){
                                Text("23°")
                            }
                            Button(action: {setAllTo(temp: 24)}){
                                Text("24°")
                            }
                        Button(action: {setAllTo(temp: 25)}){
                            Text("25°")
                        }
//                        }
                    }, label: {
                        Text("Set All")
                            .padding(10)
                            .padding([.leading, .trailing], 5)
                            .background(.orange)
                            .cornerRadius(30)
                            .foregroundColor(.white)
                    }).padding(10)
                }
            VStack{
                ForEach(updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)})){room in
                    ForEach(room.tempDevices.filter({$0.isAC == false})){tado in
                        HStack{
                            Text(room.name)
                                .bold()
                                Spacer()
                            Text("\(Int(tado.setTemp)) ")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.1f", tado.temp))
                                    .foregroundColor(.orange)
                        }.font(.headline)
                            .padding([.top, .bottom], 10)
                        Divider()
                    }
                }
                HStack{
                    Text("Only Room Thermostats and Radiators are shown.")
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
            .onAppear(perform: update)
        }
    }
}

struct AccessoryDetailAvgTemp_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryDetailAvgTemp()
    }
}
