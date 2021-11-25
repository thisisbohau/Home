//
//  BlindControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.06.21.
//

import SwiftUI

struct BlindControl: View {
    @EnvironmentObject var updater: Updater
    @Binding var blind: Blind
    @State var position: Float = 0
    @State var color: Color = .teal
    func setup(){
        print("updating blind\(blind.position)open")
        position = 100-Float(blind.position)
    
//        update()
    }
    func update(){
        blind.position = 100-Int(position)
        BlindKit().setBlind(blind: blind)
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
        .onChange(of: updater.lastUpdated, perform: {value in setup()})
//        .onChange(of: light.brightness, perform: {value in setup()})
//        .onChange(of: brightness, perform: {value in update()})
        
    }
}

//struct BlindControl_Previews: PreviewProvider {
//    static var previews: some View {
//        BlindControl()
//    }
//}
