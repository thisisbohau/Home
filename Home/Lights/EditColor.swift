//
//  EditColor.swift
//  Home
//
//  Created by David Bohaumilitzky on 21.06.21.
//

import SwiftUI
//import ColorPickerRing

struct EditColor: View {
    @Binding var light: Light
    @State var color: RGB = RGB(r: 0, g: 0, b: 0)
    @State var brightness: CGFloat = 1
    var onChange: (Void)
    
    
    func update(){
//        light.b = Float(255*color.toRGBAComponents().b)
//        light.r = Float(255*color.toRGBAComponents().r)
//        light.g = Float(255*color.toRGBAComponents().g)
////        light.brightness = Float(brightness)
//        print("color changed")
//        LightKit().setLight(light: light)
//        onChange
    }
    var body: some View {
        VStack{
//            Spacer()
            HStack{
                Spacer()
                VStack{
                    Text(light.name)
                        .font(.title.bold())
                    if !light.state{
                        Text("Off")
                            .foregroundColor(.secondary)
                    }else{
                        Text("\(String(Int(light.brightness)))% Brightness")
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }.padding(.top)
            Spacer()
            ColorPicker(radius: 300, rgbColour: $color, brightness: $brightness)
//                        .frame(width: 300, height: 300, alignment: .center)
//            Button(action: {update()}){
//                Text("Set")
//            }
//                .onChange(of: rgb.r, perform: {value in update()})
//                .onChange(of: brightness, perform: {value in update()})
//                        .onChange(of: color, perform: {value in update()})
//            Spacer()
            HStack{
                Spacer()
            }
            .background(Color.pink)
            .frame(height: 10)
            Spacer()
        }.padding()
    }
}
//
//struct EditColor_Previews: PreviewProvider {
//    static var previews: some View {
//        EditColor(onChange: {})
//    }
//}
