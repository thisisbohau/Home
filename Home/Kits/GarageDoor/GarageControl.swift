
//
//  NukiControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

struct GarageControl: View {
    @EnvironmentObject var updater: UpdateManager
    @State var calcStatus: GarageDoor = GarageDoor(state: false, latch: Blind(id: "", name: "", position: 0, moving: false), openedAt: "")
    @State var setState: Bool = false
    
    @State var waitingForUpdate: Bool = true
    @State var setupComplete: Bool = false
    
    @State var toggleWarning: Bool = false
    @State var animate: CGFloat = 1
    @State var animateUnlatch: Bool = false
    @State var animateColor: Color = .blue
    
    @State var viewSize: CGSize = CGSize(width: 100, height: 100)
    
    func setup(){
        calcStatus = updater.status.garage
        setState = calcStatus.state
        
        //set for future animation
        if calcStatus.state{
            animate = 0
            animateColor = .orange
        }else{
            animate = 1
            animateColor = .secondary
        }
        
        setupComplete = true
        waitingForUpdate = false
    }
    
    func updateTerminator(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
            if waitingForUpdate{
                print("GARAGE: Server took too long to respond. Update aborted")
                calcStatus = updater.status.garage
                setState = calcStatus.state
                waitingForUpdate = false
            }
        })
    }
    
    func forceShut(){
        GarageKit().forceShut(garage: calcStatus)
    }
    func toggleGarage(){
        waitingForUpdate = true
        calcStatus.state = setState
        GarageKit().toggleGarage(garage: calcStatus, newState: setState)
        updateTerminator()
    }
    
    func update(){
        if setupComplete{
            let newState = updater.status.garage
            
            if waitingForUpdate{
                if setState == newState.state{
                    calcStatus = newState
                    waitingForUpdate = false
                    print("garage edit successful\(newState)")
                }
            }else{
                calcStatus = newState
                setState = newState.state
            }
        }
    }
    
    func animateWithState(state: Bool){
        if state{
            animate = 0
            animateColor = .orange
        }else{
            animate = 1
            animateColor = .secondary
        }
        withAnimation(.linear, {
            if animate == 0{
                animate = 1
            }else{
                animate = 0
            }
        })
    }

    var openIcon: some View{
        VStack{
            Image("blind.open")
                .font(.largeTitle)
                .foregroundStyle(.primary)
        }
    }
    var closedIcon: some View{
        VStack{
            Image("blind.closed")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View{
        GeometryReader{proxy in
            VStack{
                HStack{
                    VStack{
                        if calcStatus.state{
                            openIcon
                                .foregroundColor(.blue)
                        }else{
                            closedIcon
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text("Garage Door")
                            .font(.title.bold())
                        HStack{
                            Text(calcStatus.state ? "Open" : "Closed")
                            if calcStatus.state{
                                Text(" | ")
                                Image(systemName: "clock.fill")
                                Text("Opened at \(SystemUtility().unixToDate(unix: updater.status.garage.openedAt))")
                            }
                            
                        }.foregroundStyle(.secondary)
                    }
                    Spacer()
                }.padding()
                
                Spacer()
                    SmartToggleSwitch(active: $setState, sliderHeight: proxy.size.height*0.6, sliderWidth: 160, onColor: .blue, onIcon: AnyView(openIcon), offIcon: AnyView(closedIcon))
                    Spacer()
                Button(action: {toggleWarning.toggle()}){
                        VStack{
                            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                .font(.title)
                                .padding(10)
                                .background(
                                    Circle()
                                        .foregroundColor(.blue)
                                )
                            Text("ForceShut")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .padding(.top, 10)
                        }
                        .foregroundColor(.primary)
                    }.padding()
   
            }
            .background(
                Rectangle()
                    .ignoresSafeArea()
                    .frame(width: proxy.size.width, height: animate == 1 ? proxy.size.height : 0)
                    .foregroundColor(animateColor)
                    .overlay(.regularMaterial)
                    .opacity(animate == 1 ? 0 : 1)
            )
            .onAppear(perform: {
                setup()
                viewSize = proxy.size
            })
            .onChange(of: setState, perform: {state in
                animateWithState(state: state)
                toggleGarage()
            })
            .onChange(of: updater.lastUpdated, perform: {_ in
                update()
            })
            .actionSheet(isPresented: $toggleWarning, content: {ActionSheet(title: Text("Force Shut Door?"), message: Text("Activates a repeated close action to forcefully close the door. Only use in emergencies. "), buttons: [.destructive(Text("Force Shut Now")){forceShut()}, .cancel()])})
        }
    }
}





////
////  GarageControl.swift
////  Home
////
////  Created by David Bohaumilitzky on 09.07.21.
////
//
//import SwiftUI
//
//struct GarageControl: View {
//    @EnvironmentObject var updater: UpdateManager
//    @Binding var garage: GarageDoor
////    @State var position: Float = 0
//    @State var color: Color = .teal
//    @State var stateString: String = ""
//
//    func setup(){
//        garage.state = updater.status.garage.state
//
//        if updater.status.garage.state{
//            let openedAt = Date(timeIntervalSince1970: Double(updater.status.garage.openedAt) ?? 0)
//            let openFor = Calendar.current.dateComponents([.minute], from: openedAt, to: Date()).minute ?? 0
//
//            if openFor > 0{
//                stateString = "Open for \(openFor)min"
//            }else{
//                stateString = "Opened just now"
//            }
//        }else{
//            stateString = "Closed"
//        }
//    }
//
//    func toggle(newState: Bool){
//        Task{
//            var queries = [URLQueryItem]()
//            queries.append(URLQueryItem(name: "action", value: "toggle"))
//
//            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.garage, queries: queries)
//        }
//
////        let requestURL = Updater().getRequestURL(directory: directories.garage, queries: queries)
////        Updater().makeActionRequest(url: requestURL){response in
////            print(String(data: response, encoding: .utf8) ?? "")
////        }
//    }
//
//
//
//    var body: some View{
//        VStack{
//            HStack{
//                VStack(alignment: .leading){
//                    Text(garage.latch.name)
//                        .font(.largeTitle.bold())
//                    Text(stateString)
//                        .foregroundStyle(.secondary)
//                }
//                Spacer()
//            }.padding(.top)
//            Spacer()
//            slider
//            Spacer()
//        }
//        .padding()
////        .background(Color("background"))
//        .onAppear(perform: setup)
//        .onChange(of: updater.lastUpdated, perform: {value in setup()})
//
//    }
//
//    var slide: some Gesture{
//        DragGesture(minimumDistance: 10)
//            .onChanged({value in
//                if value.translation.height < 0 {
//                    // up
//                    toggle(newState: true)
//                }
//
//                if value.translation.height > 0 {
//                   //down
//                    toggle(newState: false)
//                }
//            })
//    }
//
//    var slider: some View{
//        GeometryReader{proxy in
//            VStack{
//                Spacer()
//                HStack{
//                    Spacer()
//                    ZStack{
//
//                        Rectangle()
//                            .foregroundColor(Color.gray.opacity(0.3))
//                            .frame(width: 150)
//                            .cornerRadius(36)
//
//                        if garage.state{
//                            VStack{
//                                Rectangle()
//                                    .foregroundColor(Color.orange)
//                                    .frame(width: 150, height: proxy.size.height*0.32)
//                                    .cornerRadius(36)
//                                    .overlay(Image("blind.open").font(.largeTitle).foregroundColor(.white))
//                                Spacer()
//                            }
//                        }else{
//                            VStack{
//                                Spacer()
//                                Rectangle()
//                                    .foregroundColor(Color.gray.opacity(0.3))
//                                    .frame(width: 150, height: proxy.size.height*0.32)
//                                    .cornerRadius(36)
//                                    .overlay(Image("blind.closed").font(.largeTitle).foregroundStyle(.secondary))
//                            }
//                        }
//                    }.frame(height: proxy.size.height*0.70)
//                        .gesture(slide)
//                    Spacer()
//                }
//                Spacer()
//            }
//        }
//    }
//
////    var body: some View {
////        VStack{
////            HStack{
////                Spacer()
////                VStack{
////                    Text(garage.latch.name)
////                        .font(.title.bold())
////                    if !garage.state{
////                        Text("Closed")
////                            .foregroundColor(.secondary)
////                    }else{
////                        Text("\(String(Int(garage.latch.position)))% Open")
////                            .foregroundColor(.secondary)
////                    }
////                }
////                Spacer()
////            }.padding(.top)
////            Spacer()
////        blindPositionSlider
////            Spacer()
////            Text("Opened at: \(IrrigationKit().getLocalTimeFromUnix(unix: garage.openedAt))")
////                .padding()
////        }
////        .padding()
////        .onAppear(perform: setup)
////        .onChange(of: updater.lastUpdated, perform: {value in setup()})
//////        .onChange(of: light.brightness, perform: {value in setup()})
//////        .onChange(of: brightness, perform: {value in update()})
////
////    }
//}
//
////struct GarageControl_Previews: PreviewProvider {
////    static var previews: some View {
////        GarageControl()
////    }
////}
