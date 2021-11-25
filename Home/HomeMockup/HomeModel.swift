//
//  HomeModel.swift
//  HomeModel
//
//  Created by David Bohaumilitzky on 29.08.21.
//

import SwiftUI

struct LightOnOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.42818*width, y: 0.69032*height))
        path.addLine(to: CGPoint(x: 0.44646*width, y: 0.7157*height))
        path.addLine(to: CGPoint(x: 0.41073*width, y: 0.72644*height))
        path.addLine(to: CGPoint(x: 0.41441*width, y: 0.69452*height))
        return path
    }
}

struct GridConsumptionOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.89737*width, y: 0.76145*height))
        path.addLine(to: CGPoint(x: 0.7811*width, y: 0.70094*height))
        path.addLine(to: CGPoint(x: 0.7798*width, y: 0.67042*height))
        path.addLine(to: CGPoint(x: 0.78275*width, y: 0.6717*height))
        path.addLine(to: CGPoint(x: 0.78396*width, y: 0.69802*height))
        path.addLine(to: CGPoint(x: 0.89845*width, y: 0.7576*height))
        path.addLine(to: CGPoint(x: 0.89737*width, y: 0.76145*height))
        path.closeSubpath()
        return path
    }
}

struct PowerConsumptionOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.53566*width, y: 0.68892*height))
        path.addLine(to: CGPoint(x: 0.53497*width, y: 0.68495*height))
        path.addLine(to: CGPoint(x: 0.63612*width, y: 0.65338*height))
        path.addLine(to: CGPoint(x: 0.6314*width, y: 0.54934*height))
        path.addLine(to: CGPoint(x: 0.79201*width, y: 0.4974*height))
        path.addLine(to: CGPoint(x: 0.79206*width, y: 0.5683*height))
        path.addLine(to: CGPoint(x: 0.78903*width, y: 0.56684*height))
        path.addLine(to: CGPoint(x: 0.78911*width, y: 0.50254*height))
        path.addLine(to: CGPoint(x: 0.63461*width, y: 0.55255*height))
        path.addLine(to: CGPoint(x: 0.63933*width, y: 0.65659*height))
        path.addLine(to: CGPoint(x: 0.53566*width, y: 0.68892*height))
        path.closeSubpath()
        return path
    }
}

struct SolarProductionOverlay: Shape {
    func path(in rect: CGRect) -> Path {
         var path = Path()
         let width = rect.size.width
         let height = rect.size.height
         path.move(to: CGPoint(x: 0.79816*width, y: 0.57163*height))
         path.addLine(to: CGPoint(x: 0.7979*width, y: 0.53084*height))
         path.addLine(to: CGPoint(x: 0.81497*width, y: 0.52541*height))
         path.addLine(to: CGPoint(x: 0.81319*width, y: 0.46274*height))
         path.addLine(to: CGPoint(x: 0.81622*width, y: 0.46187*height))
         path.addLine(to: CGPoint(x: 0.81808*width, y: 0.52862*height))
         path.addLine(to: CGPoint(x: 0.80094*width, y: 0.53411*height))
         path.addLine(to: CGPoint(x: 0.8012*width, y: 0.5728*height))
         path.addLine(to: CGPoint(x: 0.79816*width, y: 0.57163*height))
         path.closeSubpath()
         path.move(to: CGPoint(x: 0.26402*width, y: 0.36284*height))
         path.addLine(to: CGPoint(x: 0.74369*width, y: 0.20529*height))
         path.move(to: CGPoint(x: 0.74373*width, y: 0.20552*height))
         path.addLine(to: CGPoint(x: 0.74365*width, y: 0.20511*height))
         path.addLine(to: CGPoint(x: 0.26398*width, y: 0.36267*height))
         path.addLine(to: CGPoint(x: 0.26406*width, y: 0.36307*height))
         path.addLine(to: CGPoint(x: 0.74373*width, y: 0.20552*height))
         path.closeSubpath()
         path.move(to: CGPoint(x: 0.29619*width, y: 0.42259*height))
         path.addLine(to: CGPoint(x: 0.77941*width, y: 0.26317*height))
         path.move(to: CGPoint(x: 0.77946*width, y: 0.26335*height))
         path.addLine(to: CGPoint(x: 0.77937*width, y: 0.26294*height))
         path.addLine(to: CGPoint(x: 0.29615*width, y: 0.42236*height))
         path.addLine(to: CGPoint(x: 0.29624*width, y: 0.42277*height))
         path.addLine(to: CGPoint(x: 0.77946*width, y: 0.26335*height))
         path.closeSubpath()
         path.move(to: CGPoint(x: 0.32837*width, y: 0.48229*height))
         path.addLine(to: CGPoint(x: 0.8151*width, y: 0.32129*height))
         path.move(to: CGPoint(x: 0.8151*width, y: 0.32153*height))
         path.addLine(to: CGPoint(x: 0.81501*width, y: 0.32112*height))
         path.addLine(to: CGPoint(x: 0.32828*width, y: 0.48211*height))
         path.addLine(to: CGPoint(x: 0.32837*width, y: 0.48252*height))
         path.addLine(to: CGPoint(x: 0.8151*width, y: 0.32153*height))
         path.closeSubpath()
         path.move(to: CGPoint(x: 0.3605*width, y: 0.54204*height))
         path.addLine(to: CGPoint(x: 0.85069*width, y: 0.37959*height))
         path.move(to: CGPoint(x: 0.85073*width, y: 0.37982*height))
         path.addLine(to: CGPoint(x: 0.85065*width, y: 0.37941*height))
         path.addLine(to: CGPoint(x: 0.36046*width, y: 0.54187*height))
         path.addLine(to: CGPoint(x: 0.36054*width, y: 0.54228*height))
         path.addLine(to: CGPoint(x: 0.85073*width, y: 0.37982*height))
         path.closeSubpath()
         path.move(to: CGPoint(x: 0.63846*width, y: 0.17062*height))
         path.addLine(to: CGPoint(x: 0.81479*width, y: 0.46257*height))
         path.move(to: CGPoint(x: 0.81492*width, y: 0.46245*height))
         path.addLine(to: CGPoint(x: 0.63859*width, y: 0.17051*height))
         path.addLine(to: CGPoint(x: 0.63833*width, y: 0.1708*height))
         path.addLine(to: CGPoint(x: 0.81466*width, y: 0.46274*height))
         path.addLine(to: CGPoint(x: 0.81492*width, y: 0.46245*height))
         path.closeSubpath()
         return path
     }
 }


struct HomeModel: View {
    @EnvironmentObject var updater: Updater
    @State var solar: [Color] = [.green, .clear]
    @State var cycle: Bool = false
//    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    @State var gridFeed: Bool = false
    
    func update(){
        if updater.status.power.powerSplit.grid < 0{
            gridFeed = true
        }else{
            gridFeed = false
        }
    }
    var accessories: some View{
        ZStack{
            Image(updater.status.nuki.state ? "HomeOpenDoor" : "HomeClosedDoor")
                .resizable()
                .scaledToFit()
            
            Image(updater.status.rooms.flatMap({$0.blinds}).filter({$0.position > 90}).count != 0 ? "HomeBlindsOpen" : "HomeBlindsClosed")
                .resizable()
                .scaledToFit()
            
            Image(updater.status.garage.state ? "HomeOpenGarage" : "HomeGarageClosed")
                .resizable()
                .scaledToFit()
        }
    }
    var body: some View {
        ZStack{
            Image("HomeBackground")
                .resizable()
                .scaledToFit()
            accessories
            
            //MARK: Solar
//            if updater.status.power.solar.combinedProduction != 0{
                ZStack{
                    Color.green.opacity(0.3)
                    if cycle{
                        LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
    //                    Color.green.opacity(cycle ? 0.6 : 1)
                            .blur(radius: 30)
                            .transition(.move(edge: .top))
    //                    LinearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottom)
                    }else{
                        Color.clear
                            
                            .transition(.move(edge: .bottom))
    //                    LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
                    }
                }
                .mask(SolarProductionOverlay())
                .contentShape(SolarProductionOverlay())
                .clipped()
//            }
            //MARK: Power Consumptions
                ZStack{
                    Color.green.opacity(0.3)
                    if cycle{
                        LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
                            .rotationEffect(Angle(degrees: 90))
    //                    Color.green.opacity(cycle ? 0.6 : 1)
                            .blur(radius: 30)
                            .transition(.move(edge: .trailing))
    //                    LinearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottom)
                    }else{
                        Color.clear
                            
                            .transition(.move(edge: .bottom))
    //                    LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
                    }
                }
                
                .mask(PowerConsumptionOverlay())
//                .contentShape(PowerConsumptionOverlay())
                .clipped()
                .contentShape(PowerConsumptionOverlay())

            
            //MARK: Grid Consumption
            ZStack{
                gridFeed ?
                Color.green.opacity(0.3)
                :
                Color.orange.opacity(0.3)
                if cycle{
                    LinearGradient(colors: [.clear, gridFeed ? .green : .orange], startPoint: .top, endPoint: .bottom)
                       
//                    Color.green.opacity(cycle ? 0.6 : 1)
                        .blur(radius: 30)
                        .transition(.move(edge: gridFeed ? .leading : .trailing))
//                    LinearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottom)
                }else{
                    Color.clear
                        
                        .transition(.move(edge: .bottom))
//                    LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
                }
            }
            .mask(GridConsumptionOverlay())
            .contentShape(GridConsumptionOverlay())
            .clipped()
            
            //MARK: Lights
            if updater.status.rooms.flatMap({$0.lights}).filter({$0.state == true}).count > 1{
                ZStack{
                    Color.yellow
                        .opacity(0.6)
                        
    //                LinearGradient(colors: [.yellow, .clear], startPoint: .top, endPoint: .bottom)
    //                    .blur(radius: 20)
    //                if cycle{
    //                    LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
    //
    ////                    Color.green.opacity(cycle ? 0.6 : 1)
    //                        .blur(radius: 30)
    //                        .transition(.move(edge: .leading))
    ////                    LinearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottom)
    //                }else{
    //                    Color.clear
    //
    //                        .transition(.move(edge: .bottom))
    ////                    LinearGradient(colors: [.clear, .green], startPoint: .top, endPoint: .bottom)
    //                }
                }
    //            .mask(LightOnOverlay() )
                .mask(LightOnOverlay())
                .contentShape(LightOnOverlay())
                .clipped()
                .blur(radius: 3)
            }

            
            
//            SolarOverlay()
//                .overlay(
//
//
//
//
//                ).clipped()

//
//                .onReceive(timer, perform: {_ in
//
//                    if cycle{
//                        withAnimation(.linear(duration: 2), {
//                            solar = [.pink, .blue]
//                        })
//                    }else{
//                        withAnimation(.linear(duration: 2), {
//                        solar = [.green, .yellow]
//                        })
//                    }
//                    cycle.toggle()
//
////                    withAnimation(.linear(duration: 2), {
//
////                    })
////                    withAnimation(.linear(duration: 2), {
////                        solar = [.green, .yellow]
////                    })
//
//
//                })
            
            Image("light.overlay")
                .resizable()
                .scaledToFit()
            
                .onAppear(perform: {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false), {
                            cycle.toggle()
                        })
                    }
                })
                .onChange(of: updater.lastUpdated, perform: {_ in update()})
        }
    }
}

struct HomeModel_Previews: PreviewProvider {
    static var previews: some View {
        HomeModel()
    }
}
