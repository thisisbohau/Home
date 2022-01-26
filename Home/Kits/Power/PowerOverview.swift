//
//  PowerOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 17.06.21.
//

import SwiftUI


struct GaugeItem: View{
    var screenWidth: CGFloat
    var color: Color
    var max: Int
    @Binding var value: Int
    var label: AnyView
    var valueLabel: String
    var isCircle: Bool
    
    var body: some View{
        VStack(alignment: .leading){
            label
            Spacer()
            HStack{
                Spacer()
                if isCircle{
                    CircleGauge(maxValue: CGFloat(max), value: $value, label: valueLabel, color: color, stroke: sizeOptimizer(iPhoneSize: 5, iPadSize: 6), font: .title2)
                        .frame(width: screenWidth/sizeOptimizer(iPhoneSize: 2, iPadSize: 4)*sizeOptimizer(iPhoneSize: 0.50, iPadSize: 0.60), height: screenWidth/sizeOptimizer(iPhoneSize: 2, iPadSize: 4)*sizeOptimizer(iPhoneSize: 0.50, iPadSize: 0.70))
                }else{
                    Gauge(maxValue: CGFloat(max), value: $value, label: valueLabel, color: color, stroke: sizeOptimizer(iPhoneSize: 5, iPadSize: 6), font: .title2)
                    .frame(width: screenWidth/sizeOptimizer(iPhoneSize: 2, iPadSize: 4)*sizeOptimizer(iPhoneSize: 0.60, iPadSize: 0.80), height: screenWidth/sizeOptimizer(iPhoneSize: 2, iPadSize: 4)*sizeOptimizer(iPhoneSize: 0.60, iPadSize: 0.70)).offset(y: 20)
                }
                Spacer()
            }
            Spacer()
//            Text("home")
//                .foregroundStyle(.tertiary)
//                .font(.caption)
        }
        
        .modifier(SecondaryBoxBackground())
        .aspectRatio(0.9, contentMode: .fit)
    }
}

struct PowerOverview: View {
    var screenWidth: CGFloat
    @EnvironmentObject var updater: UpdateManager
    @State var showDetail: Bool = false
    @State var maxWidth: CGFloat = 0.9
    
    var totalUsage: some View{
        VStack(alignment: .leading){
            Spacer()
            HStack{
                Text(PowerKit().formatUsageNoSuffix(value: updater.status.power.metrics.usageToday))
                    .font(.largeTitle.bold())
                    .foregroundColor(.teal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                VStack(alignment: .leading){
                    Text("Home")
                    Text("kW")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Spacer()
            HStack{
                Text(PowerKit().formatUsageNoSuffix(value: updater.status.power.metrics.solarProductionToday))
                    .font(.largeTitle.bold())
                    .foregroundColor(.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                VStack(alignment: .leading){
                    Text("Solar")
                    Text("kW")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Spacer()
        }
        .modifier(SecondaryBoxBackground())
        .aspectRatio(0.9, contentMode: .fit)
    }

    var laundry: some View{
        
            VStack{
                ForEach(updater.status.laundry){device in
                    if device.activeCycle{
                        GaugeItem(screenWidth: screenWidth, color: .pink, max: 3000, value: $updater.status.power.powerSplit.battery, label: AnyView(
                        Label(device.name, systemImage: "hurricane")
                            .foregroundColor(.pink)), valueLabel: PowerKit().formatUsage(value: updater.status.power.powerSplit.battery), isCircle: false
                    )
                    }
                }
            }
        
    }
    
    var body: some View{
//        VStack{
//        GeometryReader{proxy in
        Button(action: {showDetail.toggle()}){
            
//        VStack(alignment: .leading){
//            ScrollView(.horizontal, showsIndicators: false){
////                HStack{
////                    laundry
////                    if updater.status.power.powerSplit.battery != 0{
////                    GaugeItem(screenWidth: screenWidth, color: PowerKit().getBatteryChargingState(usage: updater.status.power.powerSplit.battery) ? .green : .orange, max: 5000, value: $updater.status.power.powerSplit.battery, label: AnyView(
////                        Label(PowerKit().getBatteryChargingState(usage: updater.status.power.powerSplit.battery) ? "Charging" : "Discharging", systemImage: PowerKit().getBatteryChargingState(usage: updater.status.power.powerSplit.battery) ? "battery.100.bolt" : "battery.25")
////                            .foregroundColor(PowerKit().getBatteryChargingState(usage: updater.status.power.powerSplit.battery) ? .green : .orange)), valueLabel: PowerKit().formatUsage(value: updater.status.power.powerSplit.battery), isCircle: false
////                    )
////                    }
////                    if updater.status.power.solar.combinedProduction != 0{
////                    GaugeItem(screenWidth: screenWidth, color: .orange, max: 6000, value: $updater.status.power.solar.combinedProduction, label: AnyView(
////                        Label("Solar", systemImage: "sun.max.fill")
////                            .foregroundColor(.orange)), valueLabel: PowerKit().formatUsage(value: updater.status.power.solar.combinedProduction), isCircle: false
////                    )
////                    }
////                    GaugeItem(screenWidth: screenWidth, color: .teal, max: 10000, value: $updater.status.power.powerSplit.combinedUsage, label: AnyView(
////                        Label("Usage", systemImage: "bolt.fill")
////                            .foregroundColor(.teal)), valueLabel: PowerKit().formatUsage(value: updater.status.power.powerSplit.combinedUsage), isCircle: false
////                    )
////                    if updater.status.power.metrics.autarkie > 90{
////                        GaugeItem(screenWidth: screenWidth, color: .green, max: 100, value: $updater.status.power.metrics.autarkie, label: AnyView(
////                        Label("Independency", systemImage: "leaf.fill")
////                            .foregroundColor(.green)), valueLabel: "\(updater.status.power.metrics.autarkie)%", isCircle: true)
////                    }
////
////
////                    GaugeItem(screenWidth: screenWidth, color: .green, max: 100, value: $updater.status.power.batteryState, label: AnyView(
////                        Label("Battery", systemImage: "battery.75")
////                            .foregroundColor(.green)), valueLabel: "\(updater.status.power.batteryState)%", isCircle: true
////                    )
////                    if updater.status.power.metrics.autarkie < 40{
////                        GaugeItem(screenWidth: screenWidth, color: .orange, max: 100, value: $updater.status.power.metrics.autarkie, label: AnyView(
////                        Label("Independency", systemImage: "leaf.fill")
////                            .foregroundColor(.orange)), valueLabel: "\(updater.status.power.metrics.autarkie)%", isCircle: true)
////                    }
////                    totalUsage
////                }
//            }
//        }.padding([.leading, .trailing])
               
                VStack(alignment: .leading){
                    ScrollView(.horizontal, showsIndicators: false){
                        //                                VStack{
                        //                                    Spacer()
                        HStack(alignment: .top){
//                            Spacer()
                            //MARK: Home
                            MainControl(icon: AnyView(
                                Image("homeIcon")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            ), title: PowerKit().formatUsage(value: updater.status.power.powerSplit.combinedUsage), caption: "Home Usage")
//                            VStack{
//                                ZStack{
//                                    Circle()
//                                        .foregroundColor(.white)
//                                        .overlay(Image("homeIcon")
//                                                    .font(.title)
//                                                    .foregroundColor(.blue))
//                                        .scaledToFit()
//                                }.frame(width: sizeOptimizer(iPhoneSize: 70, iPadSize: 80), height: sizeOptimizer(iPhoneSize: 70, iPadSize: 80))
//
//                                Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.combinedUsage))
//                                    .font(.title3.bold())
//                            }.padding([.leading, .trailing])
//                            Spacer()
                            //MARK: Solar
                            if updater.status.power.solar.combinedProduction > 10{
                                MainControl(icon: AnyView(
                                    Image(systemName: "sun.max.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                ), title: PowerKit().formatUsage(value: updater.status.power.solar.combinedProduction), caption: "Solar Production")
//                            VStack{
//                                ZStack{
//                                    Circle()
//                                        .foregroundColor(.white)
//                                        .overlay(
//                                            Image(systemName: "sun.max.fill")
//                                                .font(.title)
//                                                .foregroundColor(.orange)
//                                        )
//                                        .scaledToFit()
//
//                                }.frame(width: sizeOptimizer(iPhoneSize: 70, iPadSize: 80), height: sizeOptimizer(iPhoneSize: 70, iPadSize: 80))
//
//                                Text(PowerKit().formatUsage(value: updater.status.power.solar.combinedProduction))
//                                    .font(.title3.bold())
//
//                            }.padding([.leading, .trailing])
                            
//                            Spacer()
                            }
                            //MARK: Battery
                            if Int(updater.status.power.powerSplit.battery) != 0{
                                MainControl(icon: AnyView(
                                    Image(systemName: "battery.75")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                ), title: PowerKit().formatUsage(value: updater.status.power.powerSplit.battery), caption: "Battery at \(updater.status.power.batteryState)%")
                            }
                            
//                            VStack{
//                                ZStack{
//                                    Circle()
//                                        .foregroundColor(.white)
//                                        .overlay(
//                                            Image(systemName: "battery.75")
//                                                .font(.title)
//                                                .foregroundColor(.green)
//                                        )
//                                        .scaledToFit()
//                                    VStack{
//                                        HStack{
//
//                                            Text("\(updater.status.power.batteryState)%")
//                                                .font(.caption.bold())
//                                                .padding(8)
//                                                .background(.green)
//                                                .clipShape(Circle())
//                                                .foregroundColor(.white)
//
////                                                            .ignoresSafeArea()
//                                            Spacer()
//                                        }
//                                        Spacer()
//                                    }.offset(x: -10)
//                                }.frame(width: sizeOptimizer(iPhoneSize: 70, iPadSize: 80), height: sizeOptimizer(iPhoneSize: 70, iPadSize: 80))
//
//                                Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery))
//                                    .font(.title3.bold())
//                            }.padding([.leading, .trailing])
//                            Spacer()
                            //MARK: Grid
                            MainControl(icon: AnyView(
                                Image("gridIcon")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            ), title: PowerKit().formatUsage(value: updater.status.power.powerSplit.grid), caption: updater.status.power.powerSplit.grid < 0 ? "Grid Feed" : "Grid Usage")
//                            VStack{
//                                ZStack{
//                                    Circle()
//                                        .foregroundColor(.white)
//                                        .overlay(
//                                            Image("gridIcon")
//                                                .font(.title)
//                                                .foregroundColor(.yellow)
//                                        )
//                                        .scaledToFit()
//                                }.frame(width: sizeOptimizer(iPhoneSize: 70, iPadSize: 80), height: sizeOptimizer(iPhoneSize: 70, iPadSize: 80))
//
//                                Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid))
//                                    .font(.title3.bold())
//
//                            }.padding([.leading, .trailing])
//                            Spacer()
                        }
                        //                                    Spacer()
                        //                                }
//                        Spacer()
                    }
//                    .padding(.top)
                
            }
//                .padding(.top, 10)
                .foregroundStyle(.primary)
                .foregroundColor(.primary)
//        .modifier(BoxBackground())
        }.sheet(isPresented: $showDetail){
            PowerDetail()
        }
//        }
    }
}

//struct PowerOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        PowerOverview()
//    }
//}
