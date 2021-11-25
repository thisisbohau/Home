//
//  SceneBlindControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.07.21.
//

import SwiftUI

struct SceneBlindControl: View {
    @Binding var scene: SceneAutomation
//    @Binding var light: Light
    @Binding var blind: Blind
    @State var position: Float = 0
    @State var color: Color = .teal
    
    func sync(){
        guard let index = scene.blinds.firstIndex(where: {$0.id == blind.id})else{return}
        scene.blinds[index] = blind
    }
    
    func setup(){
        print("updating blind\(blind.position)open")
        position = 100-Float(blind.position)
    }
    func update(){
        blind.position = 100-Int(position)
        sync()
    }
    var blindPositionSlider: some View{
        VerticalSlider(value: $position, lineColor: $color, onChange: {update()})
            .rotationEffect(.init(degrees: -180), anchor: .center)
    }
    var body: some View {
        VStack{
            HStack{
                Spacer()
                VStack{
                    Text(blind.name)
                        .font(.title.bold())
                    if blind.position == 0{
                        Text("Closed")
                            .foregroundColor(.secondary)
                    }else{
                        Text("\(String(Int(blind.position)))% Open")
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }.padding(.top)
            Spacer()
        blindPositionSlider
            Spacer()
        }
        .padding()
        .onAppear(perform: setup)
//        .onChange(of: light.brightness, perform: {value in setup()})
//        .onChange(of: brightness, perform: {value in update()})
        
    }
}
//
//struct SceneBlindControl_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneBlindControl()
//    }
//}
