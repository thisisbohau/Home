//
//  LaundryView.swift
//  LaundryView
//
//  Created by David Bohaumilitzky on 16.09.21.
//

import SwiftUI

struct LaundryView: View {
    @EnvironmentObject var updater: UpdateManager
    
    func update(){
        
    }
    var body: some View {
        VStack{
            Spacer()
            HStack{
                ForEach(updater.status.laundry){device in
                    HStack{
                        Spacer()
                        VStack{
                            Text(device.name)
                                .font(.largeTitle.bold())
                                .padding()
                            if device.activeCycle{
                                Text("Started at \(IrrigationKit().getLocalTimeFromUnix(unix:device.cycleStarted))")
                                    .font(.title)
                                Text(PowerKit().formatUsage(value: device.powerUsage))
                                    .foregroundStyle(.secondary)
                            }
                            VStack{
                                Text("\(device.cyclesToday) cycles today")
                                    .foregroundStyle(.secondary)
                                Text("\(String(format:"%.1f", device.consumptionToday))kWh today")
                                    .foregroundStyle(.secondary)
                            }.padding(.top)
                        }
                        Spacer()
                    }
                }
            }
            Spacer()
        }
    }
}

struct LaundryView_Previews: PreviewProvider {
    static var previews: some View {
        LaundryView()
    }
}
