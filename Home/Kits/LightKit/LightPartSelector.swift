//
//  LightPartSelector.swift
//  Home
//
//  Created by David Bohaumilitzky on 10.12.21.
//

import SwiftUI

struct LightPartSelector: View {
    @Binding var lights: [Light]
    @Binding var selected: Light
    var groupLight: Light
    @State var circle: CGFloat = 40
    @EnvironmentObject var updater: UpdateManager
    
    func update(){
        lights = updater.status.rooms.flatMap({$0.lights}).first(where: {$0.id == groupLight.id})?.parts ?? lights
    }

    var body: some View {
        HStack{
            Spacer()
            ZStack{
               
                VStack(alignment: .leading){
//                    Spacer()
                    HStack{
                        Rectangle()
                            .frame(width: circle+8, height: (circle+48)*CGFloat(lights.count))
                            
                        .foregroundStyle(.regularMaterial)
                        .cornerRadius(60)
                        Spacer()
                    }
//                    Spacer()
                }
                HStack{
                
                VStack(alignment: .leading){
                    ForEach(lights){light in
                        VStack{
                            if lights.firstIndex(where: {$0.id == light.id}) ?? 0 != 0{
                                Spacer()
                            }
                            Button(action: {
                                withAnimation(.linear(duration: 0.1)){
                                    selected = light
                                }
                            }){
                                HStack{
                                    Circle()
                                        .frame(width: circle, height: circle)
                                        .foregroundColor(light.id == selected.id ? Color(hue: Double(light.hue)/360, saturation: Double(light.saturation/255), brightness: 1) : .clear)
                                        .overlay(Image("light.bulb")
                                                    .font(.caption)
                                                    .foregroundColor(light.id == selected.id ? .white : Color(hue: Double(light.hue)/360, saturation: Double(light.saturation/255), brightness: 1))
                                                    .shadow(color: Color(hue: Double(light.hue)/360, saturation: Double(light.saturation/255), brightness: 1), radius: light.id == selected.id ? 0 : 10)
                                                    
                                            .foregroundStyle(.regularMaterial)
                                        )
                                        .transition(.slide)
                                        
                                    Text(light.name)
                                        .font(.caption)
                                        .foregroundColor(light.id == selected.id ? .primary : .secondary)
                                        .foregroundStyle(.secondary)
                                        .padding(.leading)
                                        .lineLimit(2)
                                        .fixedSize()
                                }
                            }
                        }.transition(.slide)
                    }
                }.padding(.leading, 4)
                        .frame(height: (circle+45)*CGFloat(lights.count))
                    Spacer()
                }
            }
        }
        .onChange(of: updater.lastUpdated, perform: {_ in update() })
    }
}
//
//struct LightPartSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        LightPartSelector()
//    }
//}
