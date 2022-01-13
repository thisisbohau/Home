//
//  AccessoryDetailBlinds.swift
//  Home
//
//  Created by David Bohaumilitzky on 16.08.21.
//

import SwiftUI

struct AccessoryDetailBlinds: View{
    @EnvironmentObject var updater: UpdateManager
    @State var openBlinds: [Blind] = [Blind]()
    @State var closedBlinds: [Blind] = [Blind]()
    @State var selectedFloor: Int = 2
    @State var blindsOpen: Bool = false
    @State var viewSize: CGSize = CGSize(width: 0, height: 0)
    
    @State var animateChanges: Bool = false
    @State var animate: Bool = false
    @State var animateTo: Bool = false
    @State var autoAdaptOn: Bool = false
    
    @State var selectedBlind: Blind = Blind(id: "", name: "", position: 0, moving: false)
    @State var controlBlind: Bool = false
    @State var selectionOptions: [SelectionPoint] = [SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 1, icon: AnyView(Text("EG").rotationEffect(Angle(degrees: 90))), title: ""), SelectionPoint(id: 2, icon: AnyView(Text("OG").rotationEffect(Angle(degrees: 90))), title: "")]
    @State var selectedOption: SelectionPoint = SelectionPoint(id: 0, icon: AnyView(Text("ALL").rotationEffect(Angle(degrees: 90))), title: "")
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Int(sizeOptimizer(iPhoneSize: 3, iPadSize: 6)))
    
    func closeBlind(blind: Blind){
        var modified = blind
        modified.position = 0
        BlindKit().setBlind(blind: modified)
    }
    func controlBlind(blind: Blind){
        selectedBlind = blind
        controlBlind = true
    }
    
    func autoAdapt(){
        Task{
            DispatchQueue.main.async {
                animateTo = true
                autoAdaptOn = true
            }
            
//            await LightKit().autoAdaptLights(lights: activeLights)
            
            DispatchQueue.main.async {
                animateTo = false
            }
        }
        
    }
    
    func closeFloor(){
        animateTo = true
        if selectedFloor == 2{
            BlindKit().closeFloor(floor: 0)
            BlindKit().closeFloor(floor: 1)
        }else{
            BlindKit().closeFloor(floor: selectedFloor)
        }
    }
    func openFloor(){
        animateTo = true
        if selectedFloor == 2{
            BlindKit().openFloor(floor: 0)
            BlindKit().openFloor(floor: 1)
        }else{
            BlindKit().openFloor(floor: selectedFloor)
        }
    }
    func update(){
        switch selectedOption.id{
        case 0:
            selectedFloor = 2
        case 1:
            selectedFloor = 0
        case 2:
            selectedFloor = 1
        default:
            selectedFloor = 2
        }
        if selectedFloor == 2{
            let blinds = updater.status.rooms.flatMap({$0.blinds})
            openBlinds = blinds.filter({$0.position > 2})
            closedBlinds = blinds.filter({$0.position < 2})
        }else{
            let blinds = updater.status.rooms.filter({$0.floor == selectedFloor}).flatMap({$0.blinds})
            openBlinds = blinds.filter({$0.position > 2})
            closedBlinds = blinds.filter({$0.position < 2})
        }
        
        if openBlinds.count > 0{
            blindsOpen = true
        }else{
            blindsOpen = false
            animateTo = false
        }
        
    }
    var topLevelControl: some View{
        HStack{
            Image(blindsOpen ? "blind.open" : "blind.closed")
                .font(.largeTitle)
                .symbolRenderingMode(.multicolor)
            
            VStack(alignment: .leading){
                Text("Blinds")
                    .font(.title.bold())
                
                if openBlinds.count == 0{
                    Text("All Closed")
                        .foregroundStyle(.secondary)
                }else{
                    Text("\(String(Int(openBlinds.count))) \(openBlinds.count == 1 ? "Blind" : "Blinds") Open")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
    
    var main: some View{
        VStack{
            topLevelControl
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)){
                        animate.toggle()
                    }
                })
            sectionControl
            
            VStack{
                //off control
                openBlindList
            }
            VStack{
                //                Text("All")
                //                    .font(.title2.bold())
                //                    .foregroundStyle(.secondary)
                inactiveLightList
            }
            .padding(.top)
            Spacer()
        }
    }
    
    var quickActions: some View{
        HStack{
            Button(action: closeFloor){
                HStack{
                    Image(blindsOpen ? "blind.open" : "blind.closed")
                        .symbolRenderingMode(.multicolor)
                    VStack(alignment: .leading){
                        Text("Close")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("All Blinds")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(blindsOpen ? .black : .secondary)
                    Spacer()
                }
                .padding(10)
                .onCondition(blindsOpen, transform: {view in
                    view.background(.white)
                })
                .onCondition(!blindsOpen, transform: {view in
                    view.background(.regularMaterial)
                })
                .cornerRadius(18)
            }
            Button(action: openFloor){
                HStack{
                    Image(openBlinds.count != updater.status.rooms.flatMap({$0.blinds}).count ? "blind.open" : "blind.closed")
                        .symbolRenderingMode(.multicolor)
                    VStack(alignment: .leading){
                        Text("Open")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        Text("All Blinds")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(openBlinds.count != updater.status.rooms.flatMap({$0.blinds}).count ? .black : .white)
                    Spacer()
                }
                .padding(10)
                .onCondition(openBlinds.count != updater.status.rooms.flatMap({$0.blinds}).count, transform: {view in
                    view.background(.white)
                })
                .onCondition(openBlinds.count == updater.status.rooms.flatMap({$0.blinds}).count, transform: {view in
                    view.background(.regularMaterial)
                })
                .cornerRadius(18)
            }
        }
    }
    var sectionControl: some View{
        VStack(){
            HStack{
                Text("Level")
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
                Spacer()
            }
            VStack{
                SmartSelectionSlider(selectionPoints: $selectionOptions, selectedPoint: $selectedOption, controlSize: 45, availableSpace: viewSize.width*0.9, selectColor: .teal, noBackground: true)
                    .background(.regularMaterial)
                    .cornerRadius(25)
                
            }.rotationEffect(Angle(degrees: -90))
                .frame(height: 45)
            
        }
        .padding([.top, .bottom])
        .padding(.top)
    }
    var openBlindList: some View{
        VStack{
            quickActions
                .onCondition(blindsOpen, transform: {view in
                    view
                        .padding(.bottom)
                })
            if blindsOpen{
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                    ForEach(openBlinds){blind in
                        DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))%", name: blind.name, active: blind.position > 2, offStatus: "Closed", onLongPress: {controlBlind(blind: blind)}, onTap: {closeBlind(blind: blind)})
                    }
                }
            }
        }
        .padding(10)
        .background(.regularMaterial)
        .cornerRadius(25)
    }
    var inactiveLightList: some View{
        VStack{
            ForEach(updater.status.rooms){room in
                if room.blinds.count > 0{
                    VStack{
                        HStack{
                            Text(room.name)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10){
                            ForEach(room.blinds){blind in
                                DeviceControl(type: .Blind, status: "\(String(Int(blind.position)))%", name: blind.name, active: blind.position > 2, offStatus: "Closed", onLongPress: {controlBlind(blind: blind)}, onTap: {closeBlind(blind: blind)})
                            }
                        }
                    }.animation(nil, value: animate)
                }
            }
        }
    }
    var body: some View {
        GeometryReader{proxy in
            ScrollView(showsIndicators: false){
                main
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onChange(of: updater.lastUpdated, perform: {_ in update()})
            .onChange(of: selectedOption.id, perform: {_ in update()})
            .onAppear(perform: update)
            .sheet(isPresented: $controlBlind){
                BlindControl(blind: $selectedBlind)
            }
            .onAppear(perform: {viewSize = proxy.size})
        }
        
        .padding()
        .padding(.top)
        
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .trim(from: !animate ? 0 : 0.9, to: !animate ? 0.03 : 1)
                .stroke(animateTo  ? .teal : .clear , lineWidth: 3)
                .foregroundStyle(.secondary)
                .ignoresSafeArea()
        )
    }
}



//{
//    @EnvironmentObject var updater: UpdateManager
//    @State var closedBlinds: [Blind] = [Blind]()
//    @State var egSelected: Bool = true
//
//    @State var selectedBlind: Blind = Blind(id: "", name: "", position: 0, moving: false)
//    @State var controlBlind: Bool = false
//
//    func closeBlind(blind: Blind){
//        var newBlind = blind
//        newBlind.position = 0
//        BlindKit().setBlind(blind: newBlind)
//    }
//    func controlBlind(blind: Blind){
//        selectedBlind = blind
//        controlBlind = true
//    }
//
//    func update(){
//        let blinds = updater.status.rooms.filter({$0.floor == (egSelected ? 0 : 1)}).flatMap({$0.blinds})
//        closedBlinds = blinds.filter({$0.position > 10})
//    }
//    var body: some View {
//        ScrollView{
//            VStack{
//            HStack{
//                Spacer()
//                VStack{
//                    VStack{
//                    Image("blind.open")
//                        .renderingMode(.original)
//                        .font(.system(size: 70))
//                        .shadow(color: .teal, radius: 15, x: 0, y: 0)
//                    }.frame(height: 80).padding()
//                Text("Open Blinds")
//                    .font(.largeTitle.bold())
//                    .padding(10)
//                }
//                Spacer()
//            }.padding(.bottom)
//                HStack{
//                    HStack{
//                        Button(action: {egSelected = true}){
//                            Text("EG")
//                                .frame(width: 65, height: 35)
//                                .foregroundColor(egSelected ? .white : .secondary)
//                                .background(egSelected ? .teal : .gray.opacity(0.3))
//                                .cornerRadius(30)
//                                .padding(.leading, 10)
//                        }
//                        Spacer()
//                        Button(action: {egSelected = false}){
//                            Text("OG")
//                                .frame(width: 65, height: 35)
//                                .foregroundColor(!egSelected ? .white : .secondary)
//                                .background(!egSelected ? .teal : .gray.opacity(0.3))
//                                .cornerRadius(30)
//                                .padding(.trailing, 10)
//                        }
//                    }
//                    .frame(width: 150, height: 45)
////                    .background(Color.gray.opacity(0.3))
//                    .background(.regularMaterial)
//                    .cornerRadius(30)
//                    Spacer()
//                }
//            VStack{
//                ForEach(closedBlinds){blind in
//                    HStack{
//                        Text(blind.name)
//                            .bold()
//                            Spacer()
//                        Button(action: {closeBlind(blind: blind)}){
//                            Text("Close")
//                                .foregroundColor(.teal)
//                        }
//                    }.font(.headline)
//                        .onLongPressGesture {
//                            controlBlind(blind: blind)
//                        }
//                        .padding([.top, .bottom], 10)
//                    Divider()
//                }
//                HStack{
//                    Text("For extended controls long tap blind.")
//                        .foregroundColor(.secondary)
//                        .font(.callout)
//                        .padding([.top, .bottom], 10)
//                    Spacer()
//                }
//            }
//            .padding([.top, .bottom], 10)
//
//            .padding([.leading, .trailing])
//            .background(.regularMaterial)
//            .cornerRadius(13)
//            Spacer()
//        }
//            .padding()
//            .padding(.top)
//            .onChange(of: updater.lastUpdated, perform: {_ in update()})
//            .onChange(of: egSelected, perform: {_ in update()})
//            .sheet(isPresented: $controlBlind){
//                BlindControl(blind: $selectedBlind)
//            }
//        }
//    }
//}

struct AccessoryDetailBlinds_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryDetailBlinds()
    }
}
