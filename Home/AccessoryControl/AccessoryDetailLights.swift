//
//  accessoryDetail.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.08.21.
//

import SwiftUI

struct AccessoryDetailLights: View {
    @EnvironmentObject var updater: Updater
    @State var activeLights: [Light] = [Light]()
    @State var egSelected: Bool = true
    
    @State var selectedLight: Light = Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    @State var controlLight: Bool = false
    
    func turnLightOff(light: Light){
        var offLight = light
        offLight.state = false
        offLight.brightness = 0
        LightKit().setLight(light: offLight)
    }
    func controlLight(light: Light){
        selectedLight = light
        controlLight = true
    }
    func floorOff(){
        SceneKit().floorOff(floor: egSelected ? 0 : 1){_ in
        }
    }
    func update(){
        let lights = updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)}).flatMap({$0.lights})
        activeLights = lights.filter({$0.state})
    }
    var body: some View {
        ScrollView{
            VStack{
            HStack{
                Spacer()
                VStack{
                    VStack{
                    Image("light.bulb")
                        .renderingMode(.original)
                        .font(.system(size: 70))
                        .shadow(color: .yellow, radius: 15, x: 0, y: 0)
                    }.frame(height: 80).padding()
                Text("Active Lights")
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
                                .foregroundColor(egSelected ? .black : .secondary)
                                .background(egSelected ? .yellow : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.leading, 10)
                        }
                        Spacer()
                        Button(action: {egSelected = false}){
                            Text("OG")
                                .frame(width: 65, height: 35)
                                .foregroundColor(!egSelected ? .black : .secondary)
                                .background(!egSelected ? .yellow : .gray.opacity(0.3))
                                .cornerRadius(30)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(width: 150, height: 45)
//                    .background(Color.gray.opacity(0.3))
                    .background(.regularMaterial)
                    .cornerRadius(30)
                    Spacer()
                    Button(action: floorOff){
                        Text("Floor Off")
                            .padding(10)
                            .padding([.leading, .trailing], 5)
                            .background(.yellow)
                            .cornerRadius(30)
                            .foregroundColor(.black)
                    }.padding(10)
                }
            VStack{
                ForEach(activeLights){light in
                    HStack{
                        Text(light.name)
                            .bold()
                            Spacer()
                        Button(action: {turnLightOff(light: light)}){
                            Text("Turn off")
                                .foregroundColor(.yellow)
                        }
                    }.font(.headline)
                        .padding([.top, .bottom], 10)
                        .onLongPressGesture {
                            controlLight(light: light)
                        }
                    Divider()
                }
                HStack{
                    Text("For extended controls long tap light.")
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
            .sheet(isPresented: $controlLight){
                LightControl(light: $selectedLight)
            }
        }
    }
}

//struct accessoryDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AccessoryDetail()
//    }
//}
