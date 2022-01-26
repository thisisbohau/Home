//
//  HomeView.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.05.21.
//

import SwiftUI
import AVFoundation
import AVKit

struct StatusItem: View{
    var active: Bool
    var onDescription: String
    var offDescription: String
    var icon: AnyView
    var onTap: () -> Void
    var useFill: Bool?
    
    var iconWithBackground: some View{
        VStack{
            if active{
                icon
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(useFill ?? false ? Color("fill") : Color.white)
                    .clipShape(Circle())
            }else{
                icon
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    var body: some View{
        Button(action: onTap){
            VStack{
                iconWithBackground
                Text(active ? onDescription : offDescription)
                    .lineLimit(2)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize()
            }
        }.padding([.trailing]).foregroundColor(.primary)
    }
}
struct somesdsd: ShapeStyle{
    
}
struct SolarOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.46767*width, y: 0.76026*height))
        path.addLine(to: CGPoint(x: 0.39846*width, y: 0.78741*height))
        path.addLine(to: CGPoint(x: 0.39846*width, y: 0.61378*height))
        path.addLine(to: CGPoint(x: 0.46767*width, y: 0.58663*height))
        path.addLine(to: CGPoint(x: 0.46767*width, y: 0.76026*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.51726*width, y: 0.21304*height))
        path.addLine(to: CGPoint(x: 0.27408*width, y: 0.27889*height))
        path.addLine(to: CGPoint(x: 0.36109*width, y: 0.45432*height))
        path.addLine(to: CGPoint(x: 0.59211*width, y: 0.38081*height))
        path.addLine(to: CGPoint(x: 0.51726*width, y: 0.21304*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.44549*width, y: 0.52864*height))
        path.addLine(to: CGPoint(x: 0.40848*width, y: 0.43294*height))
        path.addLine(to: CGPoint(x: 0.40338*width, y: 0.43754*height))
        path.addLine(to: CGPoint(x: 0.43956*width, y: 0.53107*height))
        path.addLine(to: CGPoint(x: 0.43956*width, y: 0.58384*height))
        path.addLine(to: CGPoint(x: 0.44549*width, y: 0.58176*height))
        path.addLine(to: CGPoint(x: 0.44549*width, y: 0.52864*height))
        path.closeSubpath()
        return path
    }
}

//struct HomeView: View{
//    @EnvironmentObject var updater: UpdateManager
//    @EnvironmentObject var appState: AppState
//
//    func selectRoom(room: Room){
//        appState.activeRoom = room
//        appState.activeTab = 4
//    }
//
//    var body: some View{
//        if UIDevice.current.userInterfaceIdiom == .pad{
//            ZStack{
//                VStack{
//                    Dashboard()
//                }
//                VStack{
//                    Spacer()
//                    LeaveButton()
//
//
//                }.padding()
//            }
//
//        }else{
//            NavigationView{
//                ZStack{
//                    VStack{
//                        Dashboard()
//                    }
//                    VStack{
//                        Spacer()
//                        HStack{
//
//                            LeaveButton()
//
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//}

//struct Dashboard: View {
//    @EnvironmentObject var updater: UpdateManager
//    @State var showErrorPage: Bool = false
//    @ObservedObject var nfc = NFCReader()
//    @State var openRoom: Bool = false
//    @State var room: Room = Room(id: 0, name: "", floor: 0, lights: [Light](), blinds: [Blind](), tempDevices: [TempDevice](), type: RoomType(icon: "", color: ""), occupied: false, lastOccupied: "", openWindow: false, windows: [WindowSensor]())
//    
//    var body: some View {
//        GeometryReader{proxy in
//            ScrollView{
//                
//                if updater.error{
//                    ErrorView()
//                }
//                HomeModel()
//                AccessoryOverview()
//                DashboardWidgets(proxy: proxy.size)
//                Spacer(minLength: 150)
//            }
//            .sheet(isPresented: $openRoom){
//                RoomView(room: $room)
//            }
//            .background(.background)
//        }
//        
//    }
//}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
