//
//  LightControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.06.21.
//

import SwiftUI
//import ColorPickerRing

struct SceneLightControl: View{
    @Binding var scene: SceneAutomation
    @Binding var light: Light
//    @EnvironmentObject var updater: Updater
    @State var colorControl: Bool = false
    
    @State var color = Color.pink
    @State var colorRGB: RGB = RGB(r: 0, g: 0, b: 0)
    @State var hue: Float = 0
    @State var brightness: Int = 0
    @State var saturation: Float = 0
    
    @State var wheelBrightness: CGFloat = 1
    @State var updateBlocked: Bool = false
    
    @State var modified: String = Date().description
    
    func sync(){
        guard let index = scene.lights.firstIndex(where: {$0.id == light.id})else{return}
        scene.lights[index] = light
    }
//
//    func update(){
//        if !updateBlocked{
//            //update tasks
//            hue = light.hue
//            brightness = light.brightness
//            saturation = light.saturation
//
//            light = updater.status.rooms.flatMap({$0.lights}).first(where: {$0.id == light.id}) ?? light
//
//            if light.type == "HUEC" || light.type == "NEOC"{
//                color = Color(hue: Double(hue)/360, saturation: Double(saturation/100), brightness: 1)
//            }else{
//                color = .yellow
//            }
//
//            if light.brightness == 0{
//                light.state = false
//            }
//        }
//    }
    
    func updateColorPreview(){
//        blockUpdate()
//        light.brightness = brightness
        color = Color(red: colorRGB.r, green: colorRGB.g, blue: colorRGB.b)
        sync()
        
    }
    func setup(){
        hue = light.hue
        brightness = Int(light.brightness)
        saturation = light.saturation
        
        colorRGB = HSV.toRGB(h: CGFloat(hue)/360, s: CGFloat(saturation)/100, v: CGFloat(brightness)/100)
        print("Color")
        print(colorRGB)
        if light.type == "HUEC" || light.type == "NEOC"{
            color = Color(hue: Double(hue)/360, saturation: Double(saturation/100), brightness: 1)
        }else{
            color = .yellow
        }
        sync()
        
    }
    func updateChanges(){
//        let hsv = rgbToHue(r: colorRGB.r, g: colorRGB.g, b: colorRGB.b)
//        hue = Float(colorRGB.hsv.h)
//        saturation = Float(colorRGB.hsv.s)
//        brightness = Float(hsv.b)
        light.hue = Float(colorRGB.hsv.h)
        light.brightness = Float(brightness)
        light.saturation = Float(colorRGB.hsv.s * 100)
        
        if brightness > 0{
            light.state = true
        }else{
            light.state = false
        }
//        LightKit().setLight(light: modified)
        
        updateColorPreview()

    }
    func toggleLight(state: Bool){
        light.state = state
        light.state = state
        
//        LightKit().setLight(light: modified)
        
//       blockUpdate()
        sync()
    }

    var brightnessSlider: some View{
        VStack{
            if light.type == "HUEC" || light.type == "NEOC"{
                SmartVerticalSlider(displayedValue: $brightness, setTo: $brightness, lineColor: $color, onChange: {updateChanges()})
            }else{
                SmartVerticalSlider(displayedValue: $brightness, setTo: $brightness, lineColor: $color, onChange: {updateChanges()})
            }
        }
    }
    
    var slide: some Gesture{
        DragGesture(minimumDistance: 10)
            .onChanged({value in
                if value.translation.height < 0 {
                    // up
                    toggleLight(state: true)
                }

                if value.translation.height > 0 {
                   //down
                    toggleLight(state: false)
                }
            })
    }
    
    var colorSelector: some  View{
        VStack{
            
            HStack{
                Spacer()
                VStack{
                    Text(light.name)
                        .font(.title.bold())
                    if !light.reachable{
                        Text("Not responding")
                            .foregroundColor(.pink)
                    }else{
                        if !light.state{
                            Text("Off")
                                .foregroundColor(.secondary)
                        }else{
                            Text("\(String(Int(light.brightness)))% Brightness")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }.padding(.top)
            Spacer()
            ColorPicker(radius: 300, rgbColour: $colorRGB, brightness: $wheelBrightness, modified: $modified)
            Spacer()
        }
        .padding()
        .background(
            color.overlay(.regularMaterial)
        )
            
    }
    
    var switchSlider: some View{
        GeometryReader{proxy in
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    ZStack{
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(width: 150)
                            .cornerRadius(36)
                        
                        if light.state{
                            VStack{
                                Rectangle()
                                    .foregroundColor(Color.orange)
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image("light.bulb").font(.largeTitle).foregroundColor(.white))
                                Spacer()
                            }
                        }else{
                            VStack{
                                Spacer()
                                Rectangle()
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image("light.bulb").font(.largeTitle).foregroundStyle(.secondary))
                            }
                        }
                    }.frame(height: proxy.size.height*0.70)
                        .gesture(slide)
                    Spacer()
                }
                Spacer()
                
            }
        }
    }
    
    var body: some View{
        VStack{
            HStack{
                Spacer()
                VStack{
                    Text(light.name)
                        .font(.title.bold())
                    if !light.reachable{
                        Text("Not responding")
                            .foregroundColor(.pink)
                    }else{
                        if !light.state{
                            Text("Off")
                                .foregroundColor(.secondary)
                        }else{
                            Text("\(String(Int(light.brightness)))% Brightness")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }.padding(.top)
            Spacer()
//            Text(light.type)
//                .font(.largeTitle.bold())
            if light.isDimmable{
                brightnessSlider
            }else{
                switchSlider
            }
            Button(action: {colorControl.toggle()}){
                Text("Color")
            }
            
            Spacer()
        }
        .onChange(of: colorRGB.hsv.h, perform: {_ in updateChanges()})
        .padding()
        .onAppear(perform: setup)
        .onChange(of: modified, perform: {time in updateChanges()})
//        .onChange(of: updater.lastUpdated, perform: {_ in update()})
        .sheet(isPresented: $colorControl){
            colorSelector
        }
    }
}
//struct LightControl: View {
//    @EnvironmentObject var updater: Updater
//    @Binding var light: Light
//    @State var brightness: Float = 0
//    @State var color: Color = .pink
//    @State var editColor: Bool = false
//    @State var brightnesss: CGFloat = 100
//    @State var Colorr: UIColor = .red
//    func setup(){
//        print("updating light")
//        brightness = light.brightness
////        if light.isHue{
////            color = Color(UIColor(red: CGFloat(light.r)/255, green: CGFloat(light.g)/255, blue: CGFloat(light.b)/255, alpha: 1.0))
////            print(color)
////        }else{
////            color = .yellow
////        }
////        update()
//    }
//    func update(){
//
//        if brightness > 0{
//            light.state = true
//        }else if brightness == 0{
//            light.state = false
//        }
//        light.brightness = brightness
////        let red = UIColor(color).redValue*255
////        let green = UIColor(color).greenValue*255
////        let blue = UIColor(color).blueValue*255
////        light.r = Float(red)
////        light.g = Float(green)
////        light.b = Float(blue)
//
//        LightKit().setLight(light: light)
//    }
//    var brightnessSlider: some View{
//        VerticalSlider(value: $brightness, lineColor: $color, onChange: {update()})
//    }
//    var body: some View {
//        VStack{
//            HStack{
//                Spacer()
//                VStack{
//                    Text(light.name)
//                        .font(.title.bold())
//                    if !light.state{
//                        Text("Off")
//                            .foregroundColor(.secondary)
//                    }else{
//                        Text("\(String(Int(light.brightness)))% Brightness")
//                            .foregroundColor(.secondary)
//                    }
//                }
//                Spacer()
//            }.padding(.top)
//            Spacer()
//        brightnessSlider
////            CIHueSaturationValueGradientView(radius: 2000, brightness: $brightnesss)
////            EditColor(light: $light, onChange: update())
//            Spacer()
//            Button(action: {editColor.toggle()}){
//                Text("Color")
//                    .padding()
//            }
//        }
//        .padding()
//        .onAppear(perform: setup)
//        .onChange(of: updater.lastUpdated, perform: {value in setup()})
//        .sheet(isPresented: $editColor){
//            EditColor(light: $light, onChange: update())
//
//        }
////        .onChange(of: light.brightness, perform: {value in setup()})
////        .onChange(of: brightness, perform: {value in update()})
//
//    }
//}
//
//struct LightControl_Previews: PreviewProvider {
//    static var previews: some View {
//        LightControl()
//    }
//}



////
////  SceneLightControl.swift
////  Home
////
////  Created by David Bohaumilitzky on 03.07.21.
////
//
//import SwiftUI
//
//struct SceneLightControl: View {
//    @Binding var scene: SceneAutomation
//    @Binding var light: Light
////    @State var brightness: Float = 0
//    @State var color: Color = .pink
//    @State var editColor: Bool = false
//
//    func sync(){
//        guard let index = scene.lights.firstIndex(where: {$0.id == light.id})else{return}
//        scene.lights[index] = light
//    }
//    func setup(){
////        brightness = light.brightness
//        if light.isHue{
//            color = Color(UIColor(hue: CGFloat(light.hue)/360, saturation: CGFloat(light.saturation)/255, brightness: CGFloat(light.brightness)/255, alpha: 1.0))
//            print(color)
//        }else{
//            color = .yellow
//        }
////        sync()
//    }
//    func update(){
//
//        if light.brightness > 0{
//            light.state = true
//        }else if light.brightness == 0{
//            light.state = false
//        }
//        sync()
//    }
//    var brightnessSlider: some View{
//        VerticalSlider(value: $light.brightness, lineColor: $color, onChange: {update()})
//    }
//    var body: some View {
//        VStack{
//            HStack{
//                Spacer()
//                VStack{
//                    Text(light.name)
//                        .font(.title.bold())
//                    if !light.state{
//                        Text("Off")
//                            .foregroundColor(.secondary)
//                    }else{
//                        Text("\(String(Int(light.brightness)))% Brightness")
//                            .foregroundColor(.secondary)
//                    }
//                }
//                Spacer()
//            }.padding(.top)
//            Spacer()
//                brightnessSlider
//            Spacer()
//            Button(action: {editColor.toggle()}){
//                Text("Color")
//                    .padding()
//            }
//        }
//        .padding()
//        .onAppear(perform: setup)
//        .sheet(isPresented: $editColor){
//            EditColor(light: $light, onChange: update())
//
//        }
//    }
//}
////
////struct SceneLightControl_Previews: PreviewProvider {
////    static var previews: some View {
////        SceneLightControl()
////    }
////}
