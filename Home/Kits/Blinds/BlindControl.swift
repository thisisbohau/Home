//
//  BlindControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.06.21.
//

import SwiftUI

struct BlindControl: View {
    @EnvironmentObject var updater: UpdateManager
    @Binding var blind: Blind
    @State var controlPoints: [SelectionPoint] = [SelectionPoint(id: 0, icon: AnyView(Image("blind.open")), title: "Open | 100%"),
                                                  SelectionPoint(id: 1, icon: AnyView(Image("blind.open")), title: "50%"),
                                                  SelectionPoint(id: 2, icon: AnyView(Image("blind.open")), title: "25%"),
                                                  SelectionPoint(id: 3, icon: AnyView(Image("blind.closed")), title: "Closed | 0%")
    ]
    @State var selectedOption: SelectionPoint = SelectionPoint(id: 0, icon: AnyView(Image("blind.open")), title: "50%")
    @State var calcStatus: Blind = Blind(id: "", name: "", position: 0, moving: false)
    
    @State var position: Int = 0
    @State var color: Color = .teal
    @State var waitingForUpdate: Bool = false
    
    func set(){
        waitingForUpdate = true
        var newPos = 0
        switch selectedOption.id{
        case 0:
            newPos = 100
        case 1:
            newPos = 50
        case 2:
            newPos = 25
        case 3:
            newPos = 0
        default:
            newPos = 100
        }
        var modified = calcStatus
        modified.position = newPos
        BlindKit().setBlind(blind: modified)
        calcStatus = modified
    }
    func setup(){
        print("updating blind\(blind.position)closed")
        position = Int(100-Float(blind.position))
        guard let Blind: Blind = updater.status.rooms.flatMap({$0.blinds}).first(where: {$0.id == blind.id}) else{return}
        calcStatus = Blind
        
    }
    
    func update(){
        guard let Blind: Blind = updater.status.rooms.flatMap({$0.blinds}).first(where: {$0.id == blind.id}) else{return}
        if waitingForUpdate{
            if Blind.position == calcStatus.position{
                waitingForUpdate = false
                print("Blind edit successful")
                calcStatus = Blind
            }
        }else{
            calcStatus = Blind
        }
        
        let openRange = 90...100
        let midRange = 40...89
        let slitRange = 15...39
        let closedRange = 0...14
        
        let actPos = calcStatus.position
        
        if openRange.contains(actPos){
            selectedOption.id = 0
        }else if midRange.contains(actPos){
            selectedOption.id = 1
        }else if slitRange.contains(actPos){
            selectedOption.id = 2
        }else if closedRange.contains(actPos){
            selectedOption.id = 3
        }else{
            selectedOption.id = 1
        }
    }
    var blindPositionSlider: some View{
        SmartVerticalSlider(displayedValue: $position, setTo: $position, lineColor: $color, onChange: {update()})
            .rotationEffect(.init(degrees: -180), anchor: .center)
    }
    
    var topLevelControl: some View{
        HStack{
            Image(calcStatus.position > 3 ? "blind.open" : "blind.closed")
                    .font(.largeTitle)
                    .symbolRenderingMode(.multicolor)
            
            
            VStack(alignment: .leading){
                Text(calcStatus.name)
                    .font(.title.bold())
                
                    if calcStatus.position < 3{
                        Text("Closed")
                            .foregroundStyle(.secondary)
                    }else{
                        Text("\(String(Int(calcStatus.position)))% Open")
                            .foregroundStyle(.secondary)
                    }
                
            }
            Spacer()
        }
        .padding()
    }
    var body: some View {
        GeometryReader{proxy in
        VStack{
            topLevelControl
            Spacer()
            SmartSelectionSlider(selectionPoints: $controlPoints, selectedPoint: $selectedOption, controlSize: 40, availableSpace: proxy.size.height*0.5, selectColor: .teal)
                
//        blindPositionSlider
            Spacer()
        }
        .padding()
        .onAppear(perform: setup)
        .onChange(of: updater.lastUpdated, perform: {value in update()})
        .onChange(of: selectedOption.id, perform: {_ in set()})
        }
//        .onChange(of: light.brightness, perform: {value in setup()})
//        .onChange(of: brightness, perform: {value in update()})
        
    }
}

//struct BlindControl_Previews: PreviewProvider {
//    static var previews: some View {
//        BlindControl()
//    }
//}
