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

struct LightControlMode: Identifiable{
    var id: String
    var show: Bool
}

struct LightControl: View{
    //links
    @Binding var light: Light
    @EnvironmentObject var updater: UpdateManager
    
    //presets
    @State var presets: [ColorPreset] = [ColorPreset]()
    @State var selectedPreset: Int = 0
    
    //status
    //brightness (0-100), saturation (0-255), hue (0-360)
    //the newest status from this light(real state)
    @State var lightStatus: Light = Light(id: "", name: "", isHue: true, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    //this variable might reflect a calculated state
    @State var calcLightStatus: Light = Light(id: "", name: "", isHue: true, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    @State var statusColor: Color = .clear
    @State var statusBrightness: Int = 0
    @State var isGroup: Bool = false
    @State var groupParts: [Light] = [Light]()
    
    //controls
    @State var setBrightness: Int = 0
    @State var setColor: RGB = RGB(r: 0, g: 0, b: 0)
    @State var setState: Bool = false
    @State var wheelBrightness: CGFloat = 1
    
    //flow constraints
    @State var colorControl: Bool = false
    @State var editPreset: Bool = false
    
    //update and response
    //defines a point in time when the last user initiated change happened
    @State var modified: String = Date().description
    //shows if the current light has been initialized with the UI
    @State var setupComplete: Bool = false
    //determines if the UI is waiting for the server to reflect the current state
    @State var waitingForUpdate: Bool = true
    
    @State var x: CGFloat = 0
    @State var count: CGFloat = 0
    @State var screen = UIScreen.main.bounds.width - 30
    @State var op: CGFloat = 0
    @State var data: [LightControlMode] = [LightControlMode(id: "sync", show: true), LightControlMode(id: "single", show: false)]
    @State var studio: Bool = false
    @State var arrowAnimation: Bool = true
    
    @State var animateChanges: Bool = false
    @State var animate: Bool = false
    @State var animateTo: Bool = false
    
    @State var selectedLight: Light = Light(id: "", name: "", isHue: true, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    
    
    //    MARK: Methods
    func updateHeight(value: Int){
        for i in 0..<data.count{
            data[i].show = false
        }
        data[value].show = true
        withAnimation(.linear){
            
            if data[value].id == "single"{
                studio = true
                selectedLight = groupParts.first ?? light
                
            }else{
                studio = false
                selectedLight = light
            }
            newLight()
        }
    }
    
    func setup(){
        //on first appear set the group control as default and use sync mode.
        selectedLight = light
        let Light = light
        //push status to real state
        lightStatus = Light
        calcLightStatus = Light
        setBrightness = Int(Light.brightness)
        setState = calcLightStatus.state
        //            updateColorDisplay()
        setColor = RGB(r: UIColor(statusColor).redValue, g: UIColor(statusColor).greenValue, b: UIColor(statusColor).blueValue)
        setupComplete = true
        waitingForUpdate = false
        presets = LightKit().getPresets()
        
        //check if this instance is a group. if yes update all childs
        if Light.parts?.count ?? 0 > 0{
            isGroup = true
            guard let parts = Light.parts else{
                
                return}
            groupParts = parts
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            animateChanges = true
        })
        
        
    }
    
    func updateTerminator(){
        //if no response is received within 10 seconds of sending the request, reset the state to the last known one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            animateTo = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
            if waitingForUpdate{
                print("Update aborted. Sever took too long to respond.")
                waitingForUpdate = false
                animateTo = false
                calcLightStatus = lightStatus
                updateColorDisplay()
            }
        })
    }
    
    func newLight(){
        waitingForUpdate = false
        update()
        setupComplete = false
        setBrightness = Int(calcLightStatus.brightness)
        setState = calcLightStatus.state
        updateColorDisplay()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            setupComplete = true
        })
        selectedPreset = 0
    }
    func update(){
        if setupComplete{
            var Light = light
            if light.parts?.count ?? 0 > 0{
                Light = updater.status.rooms.flatMap({$0.lights}).first(where: {$0.id == light.id
                })?.parts?.first(where: {$0.id == selectedLight.id}) ?? light
                groupParts = Light.parts ?? groupParts
                
            }else{
                Light = updater.status.rooms.flatMap({$0.lights}).first(where: {$0.id == selectedLight.id}) ?? light
            }
            //push status to real state
            lightStatus = Light
            
            //END OF METHOD
            //if UI is waiting for an update, check if new state is matching the calculated one
            if waitingForUpdate{
                print("system is waiting for update from server. Checking for unity")
                let brightnessDiff = Int(Light.brightness).distance(to: Int(setBrightness))
                let hueDiff = Int(Light.hue).distance(to: Int(calcLightStatus.hue))
                
                if ((hueDiff < 0 ? (hueDiff * (-1)) : hueDiff) < 2){
                    if (brightnessDiff < 0 ? (brightnessDiff * (-1)) : brightnessDiff) < 2{
                        withAnimation(.linear){
                            calcLightStatus = Light
                            updateColorDisplay()
                            waitingForUpdate = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                animateTo = false
                            })
                            
                        }
                        print("Light edit successful")
                        return
                    }
                    
                }
            }else{
                print("updating state from server")
                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    calcLightStatus = Light
                    updateColorDisplay()
                    presets = LightKit().getPresets()
                    return
                })
            }
            
        }
    }
    
    func updateColorDisplay(){
        if selectedLight.type == "HUEC" || selectedLight.type == "NEOC" || selectedLight.type == "NANO" || isGroup{
            statusColor = Color(hue: Double(calcLightStatus.hue)/360, saturation: Double(calcLightStatus.saturation/255), brightness: 1)
        }else{
            statusColor = .yellow
        }
        calcLightStatus.state = calcLightStatus.brightness > 1 ? true : false
        selectedLight.state = calcLightStatus.state
        statusBrightness = Int(calcLightStatus.brightness)
    }
    
    let columns: [GridItem] = Array(repeating: .init(.fixed(65)), count: 3)
    
    func selectPreset(preset: ColorPreset){
        
        if selectedPreset == preset.id{
            editPreset = true
        }else{
            waitingForUpdate = true
            selectedPreset = preset.id
            var modified = light
            modified.id = selectedLight.id
            modified.hue = Float(preset.hue*360)
            modified.saturation = Float(preset.saturation*255)
            modified.state = true
            
            calcLightStatus.hue = modified.hue
            calcLightStatus.saturation = modified.saturation
            
            LightKit().setColor(light: modified)
            
            updateTerminator()
            updateColorDisplay()
        }
    }
    
    func setColorTo(){
        if setupComplete{
            waitingForUpdate = true
            var modified = selectedLight
            modified.id = selectedLight.id
            modified.hue = Float(setColor.hsv.h)
            modified.brightness = Float(setBrightness)
            modified.saturation = Float(setColor.hsv.s * 255)
            modified.state = true
            
            let preset = ColorPreset(id: selectedPreset, hue: CGFloat(modified.hue/360), saturation: CGFloat(modified.saturation/255), brightness: 1)
            LightKit().savePreset(preset: preset)
            LightKit().setColor(light: modified)
            updateTerminator()
            updateColorDisplay()
            
            guard let Index = groupParts.firstIndex(where: {$0.id == selectedLight.id}) else{return}
            groupParts[Index] = modified
        }
    }
    func setBrightnessTo(){
        if setupComplete{
            waitingForUpdate = true
            calcLightStatus.brightness = Float(setBrightness)
            selectedLight.state = calcLightStatus.state
            selectedLight.brightness = Float(setBrightness)
            var modified = selectedLight
            modified.id = selectedLight.id
            modified.brightness = Float(setBrightness)
            modified.state = setBrightness > 3 ? true : false
            LightKit().setBrightness(light: modified)
            updateTerminator()
        }
    }
    
    func setStateTo(){
        if setupComplete{
            waitingForUpdate = true
            calcLightStatus.state = setState
            selectedLight.state = calcLightStatus.state
            calcLightStatus.brightness = setState ? 100 : 0
            var modified = selectedLight
            modified.id = selectedLight.id
            modified.state = setState
            modified.brightness = setState ? 100 : 0
            LightKit().setBrightness(light: modified)
            
            updateTerminator()
        }
    }

    //    MARK: Brightness Slider
    var brightnessSlider: some View{
        VStack{
            if selectedLight.type == "NANO" || selectedLight.type == "HUEC" || selectedLight.type == "NEOC"{
                SmartVerticalSlider(displayedValue: $statusBrightness, setTo: $setBrightness, lineColor: $statusColor, onChange: {})
            }else{
                SmartVerticalSlider(displayedValue: $statusBrightness, setTo: $setBrightness, lineColor: $statusColor, onChange: {})
            }
        }
    }
    
    //    MARK: Color Presets
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
    
    
    //    MARK: Color Selector
    var colorSelector: some  View{
        VStack{
            HStack{
                Spacer()
                VStack{
                    Text(selectedLight.name)
                        .font(.title.bold())
                    if !selectedLight.reachable{
                        Text("Not responding")
                            .foregroundColor(.pink)
                    }else{
                        if !selectedLight.state{
                            Text("Off")
                                .foregroundColor(.secondary)
                        }else{
                            Text("\(String(Int(selectedLight.brightness)))% Brightness")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }.padding(.top)
            Spacer()
            ColorPicker(radius: 300, rgbColour: $setColor, brightness: $wheelBrightness, modified: $modified)
            Spacer()
        }
        .padding()
        .background(
            statusColor.overlay(.regularMaterial)
        )
    }
    
    //    MARK: SyncMode
    var syncModeTab: some View{
        HStack{
            Button(action: {arrowAnimation.toggle()}){
                Image(selectedLight.state ? "light.bulb" : "light.bulb.off")
                    .font(.largeTitle)
                    .symbolRenderingMode(.multicolor)
            }
            
            VStack(alignment: .leading){
                Text(selectedLight.name)
                    .font(.title.bold())
                if !selectedLight.reachable{
                    Text("Not responding")
                        .foregroundColor(.pink)
                }else{
                    if !selectedLight.state{
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }else{
                        Text("\(String(Int(calcLightStatus.brightness)))% | SyncMode")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if isGroup{
                if arrowAnimation{
                    Spacer()
                }
                VStack{
                    Image(systemName: "arrow.left")
                        .font(.title2)
                    Text("Drag for\nStudio")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }.foregroundStyle(.secondary)
                if !arrowAnimation{
                    Spacer()
                }
            }else{
                Spacer()
            }
        }
    }
    //    MARK: StudioMode
    var studioModeTab: some View{
        HStack{
            Button(action: {arrowAnimation.toggle()}){
                Image(selectedLight.state ? "light.bulb" : "light.bulb.off")
                    .font(.largeTitle)
                    .symbolRenderingMode(.multicolor)
            }
            
            VStack(alignment: .leading){
                Text(selectedLight.name)
                    .font(.title.bold())
                if !selectedLight.reachable{
                    Text("Not responding")
                        .foregroundColor(.pink)
                }else{
                    if !selectedLight.state{
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }else{
                        Text("\(String(Int(calcLightStatus.brightness)))% | StudioMode")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
    //    MARK: Mode Selector
    var modeSelector: some View{
        GeometryReader{proxy in
            VStack{
                HStack(spacing: 0){
                    ForEach(data){i in
                        VStack{
                            if i.id == "sync"{
                                syncModeTab
                            }else{
                                studioModeTab
                            }
                        }.padding([.leading, .bottom])
                            .frame(width: proxy.size.width)
                            .offset(x: self.x)
                            .highPriorityGesture(DragGesture()
                                                    .onChanged({(value) in
                                if value.translation.width > 0{
                                    self.x = value.location.x
                                }else{
                                    self.x = value.location.x - self.screen
                                    
                                }
                            })
                                                    .onEnded({ (value) in
                                if value.translation.width > 0{
                                    if value.translation.width > ((self.screen - 80)/2) && Int(self.count) != 0{
                                        self.count -= 1
                                        self.updateHeight(value: Int(self.count))
                                        self.x = -((self.screen + 15) * self.count)
                                    }else{
                                        self.x = -((self.screen + 15) * self.count)
                                    }
                                }else{
                                    if -value.translation.width > ((self.screen - 80) / 2) && Int(self.count) != (self.data.count - 1){
                                        self.count += 1
                                        self.updateHeight(value: Int(self.count))
                                        self.x = -((self.screen + 15) * self.count)
                                    }else{
                                        self.x = -((self.screen + 15) * self.count)
                                    }
                                }
                            })
                            )
                    }
                }
                .frame(width: proxy.size.width)
                .offset(x: op.self)
                .padding(.bottom)
                .onAppear(perform: {
                    self.screen = proxy.size.width
                    self.op = ((self.screen + 15) * CGFloat(self.data.count / 2)) - (self.data.count % 2 == 0 ? ((self.screen + 15) / 2) : 0)
                    let selected = data.firstIndex(where: {$0.show}) ?? 0
                    self.data[selected].show = true
                    
                    self.x = -((self.screen + 15) * CGFloat(selected))
                    
                })
            }
            .padding(.top)
        }
    }
    var topLevelControl: some View{
        HStack{
            VStack(alignment: .leading){
                Text(selectedLight.name)
                    .font(.title.bold())
                if !selectedLight.reachable{
                    Text("Not responding")
                        .foregroundColor(.pink)
                }else{
                    if !selectedLight.state{
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }else{
                        Text("\(String(Int(calcLightStatus.brightness)))% | SyncMode")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
    //    MARK: Body
    var body: some View{
        GeometryReader{proxy in
            VStack{
                if isGroup{
                    modeSelector
                        .padding()
                }else{
                    
                    syncModeTab
                        .padding()
                    Spacer()
                }
                if selectedLight.isDimmable{
                    VStack{
                        HStack{
                            if studio{
                                LightPartSelector(lights: $groupParts, selected: $selectedLight, groupLight: light)
                                    .frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 2, iPadSize: 3))
                            }
                            Spacer()
                            brightnessSlider
                            Spacer()
                        }
                        .transition(.slide)
                        .padding([.leading, .trailing])
                        if light.isHue && light.type != "HUED"{
                            presetSelector
                                .padding(.top)
                        }
                    }
                }else{
                    SmartToggleSwitch(active: $setState, sliderHeight: proxy.size.height*0.6, sliderWidth: 160, onColor: .yellow, onIcon: AnyView(Image("light.bulb")
                            .font(.largeTitle)
                            .foregroundStyle(.primary)), offIcon: AnyView(Image("light.bulb").font(.largeTitle)
                            .foregroundStyle(.secondary)))
                }
                
                Spacer()
            }
        }
        .onAppear(perform: setup)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 0.7, damping: 0.8, initialVelocity: 1).repeatForever(autoreverses: true)){
                    arrowAnimation.toggle()
                }
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)){
                animate.toggle()
            }
        })
        .onChange(of: updater.lastUpdated.description, perform: {_ in update()})
        .onChange(of: selectedLight.id, perform: {_ in newLight()})
        .onChange(of: setBrightness, perform: {_ in setBrightnessTo()})
        .onChange(of: modified, perform: {_ in setColorTo()})
        .onChange(of: setState, perform: {_ in setStateTo()})
        .sheet(isPresented: $editPreset){
            colorSelector
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .trim(from: !animate ? 0 : 0.9, to: !animate ? 0.03 : 1)
                .stroke(animateTo  ? statusColor : .clear , lineWidth: 3)
                .foregroundStyle(.secondary)
                .ignoresSafeArea()
        )
    }
}
