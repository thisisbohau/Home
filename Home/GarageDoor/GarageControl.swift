//
//  GarageControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

struct GarageControl: View {
    @EnvironmentObject var updater: Updater
    @Binding var garage: GarageDoor
//    @State var position: Float = 0
    @State var color: Color = .teal
    @State var stateString: String = ""

    func setup(){
        garage.state = updater.status.garage.state
        
        if updater.status.garage.state{
            let openedAt = Date(timeIntervalSince1970: Double(updater.status.garage.openedAt) ?? 0)
            let openFor = Calendar.current.dateComponents([.minute], from: openedAt, to: Date()).minute ?? 0
            
            if openFor > 0{
                stateString = "Open for \(openFor)min"
            }else{
                stateString = "Opened just now"
            }
        }else{
            stateString = "Closed"
        }
    }
    
    func toggle(newState: Bool){
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "toggle"))
        
                       
        let requestURL = Updater().getRequestURL(directory: directories.garage, queries: queries)
        Updater().makeActionRequest(url: requestURL){response in
            print(String(data: response, encoding: .utf8) ?? "")
        }
    }
    

    
    var body: some View{
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(garage.latch.name)
                        .font(.largeTitle.bold())
                    Text(stateString)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }.padding(.top)
            Spacer()
            slider
            Spacer()
        }
        .padding()
//        .background(Color("background"))
        .onAppear(perform: setup)
        .onChange(of: updater.lastUpdated, perform: {value in setup()})
            
    }
    
    var slide: some Gesture{
        DragGesture(minimumDistance: 10)
            .onChanged({value in
                if value.translation.height < 0 {
                    // up
                    toggle(newState: true)
                }

                if value.translation.height > 0 {
                   //down
                    toggle(newState: false)
                }
            })
    }
    
    var slider: some View{
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
                        
                        if garage.state{
                            VStack{
                                Rectangle()
                                    .foregroundColor(Color.orange)
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image("blind.open").font(.largeTitle).foregroundColor(.white))
                                Spacer()
                            }
                        }else{
                            VStack{
                                Spacer()
                                Rectangle()
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image("blind.closed").font(.largeTitle).foregroundStyle(.secondary))
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
    
//    var body: some View {
//        VStack{
//            HStack{
//                Spacer()
//                VStack{
//                    Text(garage.latch.name)
//                        .font(.title.bold())
//                    if !garage.state{
//                        Text("Closed")
//                            .foregroundColor(.secondary)
//                    }else{
//                        Text("\(String(Int(garage.latch.position)))% Open")
//                            .foregroundColor(.secondary)
//                    }
//                }
//                Spacer()
//            }.padding(.top)
//            Spacer()
//        blindPositionSlider
//            Spacer()
//            Text("Opened at: \(IrrigationKit().getLocalTimeFromUnix(unix: garage.openedAt))")
//                .padding()
//        }
//        .padding()
//        .onAppear(perform: setup)
//        .onChange(of: updater.lastUpdated, perform: {value in setup()})
////        .onChange(of: light.brightness, perform: {value in setup()})
////        .onChange(of: brightness, perform: {value in update()})
//
//    }
}

//struct GarageControl_Previews: PreviewProvider {
//    static var previews: some View {
//        GarageControl()
//    }
//}
