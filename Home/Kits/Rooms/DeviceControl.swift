//
//  DeviceControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import Foundation
import SwiftUI

enum DeviceType{
    case LightBulbMono
    case LightBulbDynamic
    case Blind
    case Heating
    case Cooling
    case Summary
    case Window
}

func getTempDeviceIcon(isAC: Bool, currentTemp: Float) -> AnyView{
    var body: some View{
        Text(String(Int(!currentTemp.isNaN ? currentTemp : 0.0)))
            .font(.custom("SF Mono", size: 13).weight(.medium))
//            .padding(9)
            .frame(width: 30, height: 30)
            .background(TadoKit().getTempColor(temp: currentTemp))
            .clipShape(Circle())
            .padding(1.5)
    }
    return AnyView(body)
}
func getDeviceIcon(type: DeviceType, state: Bool, accent: Color) -> AnyView{
        var icon = "lightbulb"
//        var color: Color = state ? accent : .secondary
        switch type{
        case .LightBulbMono:
            icon = state ? "light.bulb" : "light.bulb.off"
            var body: some View{
                Image(icon)
                    .renderingMode(.original)
                    
            }
            return AnyView(body)
        case .LightBulbDynamic:
            icon = state ? "light.bulb" : "light.bulb.off"
//            color = accent
            var body: some View{
                Image(icon)
                    .renderingMode(.original)
                    
            }
            return AnyView(body)
        case .Blind:
            icon = state ? "blind.open" : "blind.closed"
            var body: some View{
                Image(icon)
                    .renderingMode(.original)
                    .padding(3)
                    
            }
            return AnyView(body)
        case .Summary:
            icon = "summary"
            var body: some View{
                Image(icon)
                    .renderingMode(.original)
                    .padding(3)
                    
            }
            return AnyView(body)
        case .Window:
            icon = state ? "rectangle.portrait.and.arrow.right" : "rectangle.portrait"
            var body: some View{
                Image(icon)
                    .renderingMode(.original)
                    .padding(3)
                    
            }
            return AnyView(body)
            
        default:
            print("No type found, returning default value")
        }
    var body: some View{
        Image(icon)
            .renderingMode(.original)
            
    }
    return AnyView(body)
}
extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: 1.0)
        } else {
            return nil
        }
    }
}

let testRoom = Room(id: 0, name: "David", floor: 0, lights: [Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false), Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false), Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)], blinds: [Blind(id: "hh", name: "Blind name", position: 10, moving: false)], tempDevices: [TempDevice(id: "k", isAC: false, name: "Temp Device", manualMode: false, active: true, openWindow: false, temp: 22.2, setTemp: 22.0, humidity: 34, performance: 50)], type: RoomType(icon: "", color: ""), occupied: false, lastOccupied: "", openWindow: false, windows: [WindowSensor]())

//struct QuickActionControl: View{
//    var title: String
//    var description: String
//    var icon: String
//    var color: Color
//    var onLongPress: ()  -> Void
//    var onTap: ()  -> Void
//    var time: String
////    var useLongTap: Bool
//    
//    @GestureState var press = false
//        
//    @State var edit: Bool = false
//    var longPress: some Gesture {
//        LongPressGesture(minimumDuration: 0.3)
//                .updating($press) { currentstate, gestureState, transaction in
//                    transaction.animation = Animation.easeInOut
//                    gestureState = currentstate
//                }
//                .onEnded(){_ in
//                    onLongPress()
//                }
//        }
//    
//    var body: some View{
//        VStack{
//            HStack{
//                Image(systemName: icon)
//                    .font(.title)
//                    .foregroundColor(color)
//                    .padding(.trailing, 10)
//                VStack(alignment: .leading){
//                    Text(title)
//                        .foregroundColor(.primary)
//                        .bold()
//                    if time != ""{
//                        Text(time)
//                            .foregroundColor(.secondary)
//                            .font(.callout)
//                    }
//                }
//                
//                Spacer()
//               
//            }.padding()
//            
//        }
//        .background(Color.clear)
//        .background(.thinMaterial)
//        .cornerRadius(18)
////        .shadow(radius: 3)
//        .foregroundColor(.primary)
//        .aspectRatio(3.3, contentMode: .fit)
////        .simultaneousGesture(longPress.sequenced(before: TapGesture()))
//        .contextMenu(menuItems: {
//            Button(action: {onLongPress()}){Text("Edit")}
//        })
//        .simultaneousGesture(
//            TapGesture().onEnded({_ in onTap()})
//        )
//        .scaleEffect(press ? 0.8 : 1)
//        .animation(.easeInOut, value: press)
//        .sheet(isPresented: $edit){
////            SceneEditScene(active: $edit, scene: $scene)
//        }
//        
//    }
//    var main: some View{
//        VStack{
//            HStack{
//                Spacer()
//            }
//            Image(systemName: icon)
//                .font(.title)
//                .foregroundColor(.white)
//                .padding()
//                .background(color)
//                .clipShape(Circle())
//                .padding()
//            Text(title)
//                .foregroundColor(.black)
//                .bold()
//                .padding([.bottom])
////            Text(description)
////                .foregroundColor(.gray)
////                .font(.caption)
////                .padding()
////                .padding()
////            Spacer()
//        }.padding([.leading, .trailing, .bottom])
////        .padding(10)
////        .padding()
//        
//        .background(Color.white)
//        .cornerRadius(18)
//        
//        .simultaneousGesture(longPress.sequenced(before: TapGesture()))
//        .simultaneousGesture(
//            TapGesture().onEnded({_ in onTap()})
//        )
//        .scaleEffect(press ? 0.8 : 1)
//        .animation(.easeInOut, value: press)
//        
//    }
//}
struct DeviceControl: View{
//    var activeIcon: String
//    var inactiveIcon: String
    var type: DeviceType
    
//    var color: Color
    var status: String
    var name: String
    var active: Bool
    var offStatus: String
    var running: Bool?
    var selected: Bool?
    var onLongPress: ()  -> Void
    var onTap: ()  -> Void
    
    
//    @GestureState var press = false
    @State var press = false
    
//    var longPress: some Gesture {
//        LongPressGesture(minimumDuration: 0.3)
//                .updating($press) { currentstate, gestureState, transaction in
//                    transaction.animation = Animation.easeInOut
//                    gestureState = currentstate
//                }
//                .onEnded(){_ in
//                    onLongPress()
//                }
//        }
    
    struct stateModifier: ViewModifier{
        var active: Bool
        var Primary: Bool
        func body(content: Content) -> some View {
            if active{
                    if Primary{
                        content
                            .foregroundStyle(.black)
                    }else{
                        content
                            .foregroundStyle(.gray)
                    }
           
            }else{
                if Primary{
                    content
                        .foregroundStyle(.secondary)
                }else{
                    content
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
   
 
    var body: some View{
            VStack(alignment: .leading){
                HStack{
                    if type != .Cooling && type != .Heating{
                        getDeviceIcon(type: type, state: active, accent: .pink)
                    }else{
                        getTempDeviceIcon(isAC: false, currentTemp: Float(status.replacingOccurrences(of: "°", with: "")) ?? 0)
                    }
                    Spacer()
                }.font(.title2).padding(.top, 10)
                Spacer()
                VStack(alignment: .leading){
                    Text(name)
                        .bold()
                        .modifier(stateModifier(active: active, Primary: true))
                        .lineLimit(2)
//                        .minimumScaleFactor(0.7)
                        .padding(.top)
                    
                    Text(active ? status : offStatus)
                        .modifier(stateModifier(active: active, Primary: false))
                        .font(.caption)
                        .lineLimit(1)
//                        .minimumScaleFactor(0.7)
                    
                }
            }
            .padding([.leading, .trailing, .bottom], 10)
            .multilineTextAlignment(.leading)
            .multilineTextAlignment(.leading)
            .aspectRatio(1, contentMode: .fit)
            .background(active ? Color.white : Color.clear)
            .background(.thinMaterial)
            .cornerRadius(18)
            .foregroundColor(.primary)
        
            .overlay(
                VStack{
                    if selected != nil{
                        HStack{
                            Spacer()
                            if selected!{
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.accentColor)
                            }else{
                                Image(systemName: "circle")
                                    .foregroundStyle(.tertiary)
                                    .foregroundColor(.primary)
                            }
                        }.font(.title2).padding(10)
                        Spacer()
                    }
                }
            )
            .onTapGesture {onTap()}
            .onLongPressGesture(minimumDuration: 0.1, perform: {onLongPress()}, onPressingChanged: {_ in
                withAnimation(.easeInOut, {
                    press.toggle()
                })
            })
//            .simultaneousGesture(longPress)
//            .simultaneousGesture(
//                TapGesture().onEnded({_ in onTap()})
//            )
//            .onTapGesture {
//                onTap()
//            }
            .scaleEffect(press ? 0.8 : 1)
            .animation(.easeInOut, value: press)
    }
}
