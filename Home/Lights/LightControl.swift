//
//  LightControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.06.21.
//

import SwiftUI
//import ColorPickerRing
extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

struct LightControl: View{
    @Binding var light: Light
    @EnvironmentObject var updater: Updater
    @State var colorControl: Bool = false
    
    @State var color = Color.pink
    @State var colorRGB: RGB = RGB(r: 0, g: 0, b: 0)
    @State var hue: Float = 0
    @State var brightness: Float = 0
    @State var saturation: Float = 0
    
    @State var wheelBrightness: CGFloat = 1
    @State var updateBlocked: Bool = false
    
    @State var modified: String = Date().description
    @State var changeBlocked: Bool = false
    @State var presets: [ColorPreset] = [ColorPreset]()
    @State var selectedPreset: Int = 0
    @State var editPreset: Bool = false
    
    let columns: [GridItem] = Array(repeating: .init(.fixed(65)), count: 3)
    
    func selectPreset(preset: ColorPreset){
        if selectedPreset == preset.id{
            editPreset = true
        }else{
            selectedPreset = preset.id
            var modified = light
            modified.hue = Float(preset.hue*360)
            modified.brightness = brightness
            modified.saturation = Float(preset.saturation*100)
            modified.state = true
            LightKit().setLight(light: modified)
        }
    }
    func blockUpdate(){
        updateBlocked = true
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            updateBlocked = false
        }
    }
    func update(){
        if !updateBlocked && changeBlocked == false{
            //update tasks
            hue = light.hue
            brightness = light.brightness
            saturation = light.saturation
            
            light = updater.status.rooms.flatMap({$0.lights}).first(where: {$0.id == light.id}) ?? light
            
            if light.type == "HUEC" || light.type == "NEOC"{
                color = Color(hue: Double(hue)/360, saturation: Double(saturation/100), brightness: 1)
            }else{
                color = .yellow
            }
            
            if light.brightness == 0{
                light.state = false
            }
        }
        
        presets = LightKit().getPresets()
    }
    
    func updateColorPreview(){
        changeBlocked = true
        blockUpdate()
        light.brightness = brightness
        color = Color(red: colorRGB.r, green: colorRGB.g, blue: colorRGB.b)
        changeBlocked = false
        
    }
    func setup(){
        changeBlocked = true
        hue = light.hue
        brightness = light.brightness
        saturation = light.saturation
        
        colorRGB = HSV.toRGB(h: CGFloat(hue)/360, s: CGFloat(saturation)/100, v: CGFloat(brightness)/100)
        print("Color")
        print(colorRGB)
        if light.type == "HUEC" || light.type == "NEOC"{
            color = Color(hue: Double(hue)/360, saturation: Double(saturation/100), brightness: 1)
        }else{
            color = .yellow
        }
        changeBlocked = false
        
    }
    func updateChanges(){
        
//        let hsv = rgbToHue(r: colorRGB.r, g: colorRGB.g, b: colorRGB.b)
//        hue = Float(colorRGB.hsv.h)
//        saturation = Float(colorRGB.hsv.s)
//        brightness = Float(hsv.b)
        
        if !changeBlocked{
        var modified = light
        modified.hue = Float(colorRGB.hsv.h)
        modified.brightness = brightness
        modified.saturation = Float(colorRGB.hsv.s * 100)
        
        if brightness > 1{
            modified.state = true
        }else{
            modified.state = false
        }
        let preset = ColorPreset(id: selectedPreset, hue: CGFloat(modified.hue/360), saturation: CGFloat(modified.saturation/100), brightness: 1)
        LightKit().savePreset(preset: preset)
        LightKit().setLight(light: modified)
        
        updateColorPreview()
        }

    }
    func toggleLight(state: Bool){
        light.state = state
        var modified = light
        modified.state = state
        
        LightKit().setLight(light: modified)
        
       blockUpdate()
    }

    var brightnessSlider: some View{
        VStack{
            if light.type == "HUEC" || light.type == "NEOC"{
                VerticalSlider(value: $brightness, lineColor: $color, onChange: {updateChanges()})
            }else{
                VerticalSlider(value: $brightness, lineColor: $color, onChange: {updateChanges()})
            }
        }
    }
    var presetSelector: some View{
        LazyVGrid(columns: columns){
            ForEach(presets){preset in
                Button(action: {selectPreset(preset: preset)}){
                    VStack{
                        if preset.saturation == 0 && preset.hue == 0{
                            Circle()
                                .padding(5)
                                .frame(width: preset.id == selectedPreset ? 55 : 70, height: preset.id == selectedPreset ? 55 : 70)
                                .foregroundColor(Color(UIColor.tertiarySystemBackground))
                                .overlay(
                                    Circle()
                                        .stroke(Color(UIColor.tertiarySystemBackground), lineWidth: preset.id == selectedPreset ? 4 : 0)
                                )
                                .overlay(
                                    Text(preset.id == selectedPreset ? "Edit" : "")
                                        .font(.caption.bold())
                                        .foregroundColor(Color(UIColor.systemBackground))
                                )
                               
                        }else{
                            Circle()
                                .padding(5)
                                .frame(width: preset.id == selectedPreset ? 55 : 70, height: preset.id == selectedPreset ? 55 : 70)
                                .foregroundColor(Color(hue: preset.hue, saturation: preset.saturation, brightness: preset.brightness))
                                .overlay(
                                    Circle()
                                        .stroke(Color(hue: preset.hue, saturation: preset.saturation, brightness: preset.brightness), lineWidth: preset.id == selectedPreset ? 4 : 0)
                                )
                                .overlay(
                                    Text(preset.id == selectedPreset ? "Edit" : "")
                                        .font(.caption.bold())
                                        .foregroundColor(Color(UIColor.systemBackground))
                                )
                        }
                    }.foregroundColor(.primary)
                    
           
                    
                }
                
                
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
            ColorPicker(radius: 300, rgbColour: $colorRGB, brightness: $wheelBrightness)
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
            if light.isHue{
                presetSelector
                        .padding(.top)
            }
//            Button(action: {colorControl.toggle()}){
//                Text("Color")
//            }
            
            Spacer()
        }
        .onChange(of: colorRGB.hsv.h, perform: {_ in updateChanges()})
        .padding()
        .onAppear(perform: setup)
        .onChange(of: modified, perform: {time in updateChanges()})
        .onChange(of: updater.lastUpdated, perform: {_ in update()})
        .sheet(isPresented: $editPreset){
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
