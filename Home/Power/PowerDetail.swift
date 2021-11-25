//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by David Bohaumilitzky on 03.09.21.
//

import SwiftUI

struct PowerDetail: View {
    @EnvironmentObject var updater: Updater
    @State var barHeight: CGFloat = 7
    
    @State var batteryFeedPercent: Float = 0
    @State var homeFeedPercent: Float = 0
    @State var gridFeedPercent: Float = 0
    @State var solarToHome: Int = 0
    @State var maxWidth: CGFloat = 0.9
    @State var selfSustained: Bool = false
    @State var gridOutage: Bool = false
    @State var noSolar: Bool = false
    
    
    func update(){
        batteryFeedPercent = Float(updater.status.power.solar.batteryCharging)/Float(updater.status.power.solar.dailyProduction)
        if updater.status.power.solar.gridFeed < 2000{
            gridFeedPercent = 0.0
        }else{
            gridFeedPercent = Float(updater.status.power.solar.gridFeed)/Float(updater.status.power.solar.dailyProduction)
        }
        
        homeFeedPercent = 1 - batteryFeedPercent - gridFeedPercent
        
        let solarGeneration = updater.status.power.solar.combinedProduction
        let gridFeed = updater.status.power.powerSplit.grid < 0 ? updater.status.power.powerSplit.grid * -1 : 0
        let batteryCharge = updater.status.power.powerSplit.battery > 0 ? updater.status.power.powerSplit.battery : 0
        solarToHome = solarGeneration - gridFeed - batteryCharge
        
        if updater.status.power.metrics.autarkie > 98{
            selfSustained = true
        }else{
            selfSustained = false
        }
        
        if updater.status.power.powerOutage?.outage ?? false{
            gridOutage = true
        }else{
            gridOutage = false
        }
        
        if updater.status.power.solar.combinedProduction < 10{
            noSolar = true
        }else{
            noSolar = false
        }
        print(gridFeedPercent)
        
        
    }
    var body: some View {
        GeometryReader{proxy in
            HStack{
                Spacer()
                
                
                VStack(alignment: .leading){
                    
                    
                    VStack(alignment: .leading){
                        Text("Power")
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                        
                        if selfSustained{
                            Text("100% self sustained")
                                .foregroundStyle(.secondary)
                        }
                        if updater.status.power.powerSplit.battery < 0{
                            Text("\(updater.status.power.metrics.batteryBackupMinutes)min battery backup left")
                                .foregroundStyle(.secondary)
                        }
                        if gridOutage{
                            Text("Grid Outage")
                                .foregroundColor(.yellow)
                        }
                            
                        //MARK: Live Statistics
                        if !gridOutage{
                        VStack(alignment: .leading){
                            Text("Live Statistics")
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 10)
                            VStack(alignment: .leading){
                                ScrollView(.horizontal, showsIndicators: false){
                                    //                                VStack{
                                    //                                    Spacer()
                                    HStack(alignment: .top){
                                        Spacer()
                                        //MARK: Home
                                        VStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(.white)
                                                    .overlay(Image("homeIcon")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.blue))
                                                    .scaledToFit()
                                            }.frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6), height: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6))
                                            
                                            Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.combinedUsage))
                                                .font(.title.bold())
                                            if solarToHome > 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: solarToHome)) from")
                                                    Image(systemName: "sun.max.fill")
                                                    
                                                }
                                            }
                                            if updater.status.power.powerSplit.battery < 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery)) from")
                                                    Image(systemName: "battery.100")
                                                    
                                                }
                                            }
                                            if updater.status.power.powerSplit.grid > 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid)) from")
                                                    Image("gridIcon")
                                                    
                                                }
                                            }
                                        }.padding([.leading, .trailing])
                                        Spacer()
                                        //MARK: Solar
                                        if !noSolar{
                                        VStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(.white)
                                                    .overlay(
                                                        Image(systemName: "sun.max.fill")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.orange)
                                                    )
                                                    .scaledToFit()
                                                
                                            }.frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6), height: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6))
                                            
                                            Text(PowerKit().formatUsage(value: updater.status.power.solar.combinedProduction))
                                                .font(.title.bold())
                                            if updater.status.power.powerSplit.battery > 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery)) to")
                                                    Image(systemName: "battery.100")
                                                    
                                                }
                                            }
                                            if solarToHome > 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: solarToHome)) to")
                                                    Image("homeIcon")
                                                    
                                                }
                                            }
                                            if updater.status.power.powerSplit.grid < 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid)) to")
                                                    Image("gridIcon")
                                                    
                                                }
                                            }
                                        }.padding([.leading, .trailing])
                                        
                                        Spacer()
                                        }
                                        //MARK: Battery
                                        VStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(.white)
                                                    .overlay(
                                                        Image(systemName: "battery.75")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.green)
                                                    )
                                                    .scaledToFit()
                                                VStack{
                                                    HStack{
                                                        
                                                        Text("\(updater.status.power.batteryState)%")
                                                            .font(.caption.bold())
                                                            .padding(12)
                                                            .background(.green)
                                                            .clipShape(Circle())
                                                            .foregroundColor(.white)
                                                            
//                                                            .ignoresSafeArea()
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }.offset(x: -10)
                                            }.frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6), height: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6))
                                            
                                            Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery))
                                                .font(.title.bold())
                                            if !noSolar{
                                                if updater.status.power.powerSplit.battery > 0{
                                                    HStack{
                                                        Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery)) from")
                                                        Image(systemName: "sun.max.fill")
                                                        
                                                    }
                                                }
                                            }
                                            if updater.status.power.powerSplit.battery < 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.battery)) to")
                                                    Image("homeIcon")
                                                    
                                                }
                                            }
                                        }.padding([.leading, .trailing])
                                        Spacer()
                                        //MARK: Grid
                                        VStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(.white)
                                                    .overlay(
                                                        Image("gridIcon")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.yellow)
                                                    )
                                                    .scaledToFit()
                                            }.frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6), height: proxy.size.width/sizeOptimizer(iPhoneSize: 5, iPadSize: 6))
                                            
                                            Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid))
                                                .font(.title.bold())
                                            if !noSolar{
                                                if updater.status.power.powerSplit.grid < 0{
                                                    HStack{
                                                        Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid)) from")
                                                        Image(systemName: "sun.max.fill")
                                                        
                                                    }
                                                }
                                            }
                                            if updater.status.power.powerSplit.grid > 0{
                                                HStack{
                                                    Text("\(PowerKit().formatUsage(value: updater.status.power.powerSplit.grid)) to")
                                                    Image("homeIcon")
                                                    
                                                }
                                            }
                                        }.padding([.leading, .trailing])
                                        Spacer()
                                    }
                                    //                                    Spacer()
                                    //                                }
                                    Spacer()
                                }.padding(.top)
                            }.frame(width: proxy.size.width*maxWidth, height: 250, alignment: .top)
                        }.padding(.top, 10)
                    }else{
                        VStack(alignment: .leading){
                            HStack{
                                Spacer()
                                VStack{
                                    Text(String(updater.status.power.powerOutage?.minutesRemaining ?? 0))
                                        .foregroundStyle(.primary)
                                        .font(.largeTitle.bold())
                                    Text("minutes of power backup remaining")
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }.padding()
                                HStack{
                                    Spacer()
                                    VStack{
                                        Text(PowerKit().formatUsage(value: updater.status.power.powerSplit.combinedUsage))
                                            .font(.title.bold())
                                        
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Current Usage")
                                            .multilineTextAlignment(.center)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 1, height: 55)
                                        .cornerRadius(30)
                                    Spacer()
                                    VStack{
                                        Text(PowerKit().formatUsage(value: updater.status.power.powerOutage?.kwRemaining ?? Int(0.0)))
                                            .font(.title.bold())
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Battery")
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }.frame(width: proxy.size.width*maxWidth)
                            
                            
                        }
                    }
                        if currentDeviceIsPhone(){
                            HStack{
                                VStack(alignment: .leading){
                                    Text("Today")
                                        .font(.title2.bold())
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 10)
                                    //                            HStack{
                                    //                        Spacer()
                                    VStack(alignment: .leading){
                                        Text(PowerKit().formatUsage(value: updater.status.power.solar.dailyProduction))
                                            .font(.title.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.center)
                                        Text("Solar Production")
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                        
                                    }
                                    
                                    VStack(alignment: .leading){
                                        Text(PowerKit().formatUsage(value: updater.status.power.metrics.usageToday))
                                            .font(.title.bold())
                                        
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Home Usage")
                                            .multilineTextAlignment(.center)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                    VStack(alignment: .leading){
                                        
                                        Text("\(String(updater.status.power.batteryState))%")
                                            .font(.title.bold())
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Battery State")
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    
                                }
                                Spacer()
                            }.frame(width: proxy.size.width*maxWidth)
                            
                        }else{
                            
                            VStack(alignment: .leading){
                                Text("Today")
                                    .font(.title2.bold())
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                                HStack{
                                    //                        Spacer()
                                    VStack{
                                        Text(PowerKit().formatUsage(value: updater.status.power.solar.dailyProduction))
                                            .font(.title.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.center)
                                        Text("Solar Production")
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                        
                                    }
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 1, height: 55)
                                        .cornerRadius(30)
                                    Spacer()
                                    VStack{
                                        Text(PowerKit().formatUsage(value: updater.status.power.metrics.usageToday))
                                            .font(.title.bold())
                                        
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Home Usage")
                                            .multilineTextAlignment(.center)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 1, height: 55)
                                        .cornerRadius(30)
                                    Spacer()
                                    VStack{
                                        Text("\(String(updater.status.power.batteryState))%")
                                            .font(.title.bold())
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                        Text("Battery State")
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                }.frame(width: proxy.size.width*maxWidth)
                            }
                        }
                        
                        VStack(alignment: .leading){
                            Text("Destinations")
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 10)
                            HStack{
                                HStack{
                                    Image(systemName: "battery.75")
                                        .foregroundColor(.green)
                                    Text("\(Int(batteryFeedPercent.isNaN ? 0 : batteryFeedPercent*100))%")
                                        .bold()
                                        .foregroundStyle(.primary)
                                }.foregroundStyle(.secondary).font(.title2)
                                
                                HStack{
                                    Rectangle()
                                        .frame(width: 1, height: 35)
                                        .cornerRadius(30)
                                    Image("homeIcon")
                                        .foregroundColor(.blue)
                                    Text("\(Int(homeFeedPercent.isNaN ? 0 : homeFeedPercent * 100))%")
                                        .bold()
                                        .foregroundStyle(.primary)
                                }.foregroundStyle(.secondary).font(.title2)
                                
                                HStack{
                                    Rectangle()
                                        .frame(width: 1, height: 35)
                                        .cornerRadius(30)
                                    Image("gridIcon")
                                        .foregroundColor(.yellow)
                                    Text("\(Int(gridFeedPercent*100))%")
                                        .bold()
                                        .foregroundStyle(.primary)
                                }.foregroundStyle(.secondary).font(.title2)
                            }.padding(.bottom, 10)
                            
                            HStack{
                                HStack{
                                    Spacer()
                                }
                                .frame(width: proxy.size.width * maxWidth * CGFloat(batteryFeedPercent), height: barHeight)
                                .background(Color.green)
                                
                                HStack{
                                    Spacer()
                                }
                                .frame(width: proxy.size.width * maxWidth * CGFloat(homeFeedPercent), height: barHeight)
                                .background(Color.blue)
                                
                                if gridFeedPercent != 0{
                                    HStack{
                                        Spacer()
                                    }
                                    .frame(width: proxy.size.width * maxWidth * CGFloat(gridFeedPercent), height: barHeight)
                                    .background(Color.yellow)
                                }
                                
                                
                            }
                            .cornerRadius(15)
                        }.padding(.top)
                        
                        
                    }.frame(width: proxy.size.width*maxWidth).padding()
                    
                    
                    Spacer()
                }
                .padding(.top)
                .animation(.easeInOut)
                Spacer()
            }
        }
        .onChange(of: updater.lastUpdated, perform: {_ in update()})
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PowerDetail()
    }
}
