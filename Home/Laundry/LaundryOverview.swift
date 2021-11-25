//
//  LaundryOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 21.09.21.
//

import SwiftUI

struct LaundryOverview: View {
    @EnvironmentObject var updater: Updater
    @State var animate: Bool = false
    
    func getRunTime(unix: String) -> String{
        let Unix = Double(unix) ?? 0
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: Unix))
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())

        let seconds =  calendar.dateComponents([.second], from: timeComponents, to: nowComponents).second!
        
        let int = secondsToHoursMinutesSeconds(seconds: seconds)
        if int.0 != 0{
            return String("Running \(int.0)h \(int.1)min")
        }else{
            return String("Running \(int.1)min")
        }
    }
    var body: some View {
        ScrollView(.horizontal){
            HStack{
                ForEach(updater.status.laundry){device in
                    if device.activeCycle{
                        MainControl(icon: AnyView(
                            Image("laundry")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color("primary"), .clear)
                                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: animate)
                                                    .font(.title2)
                                .onAppear(perform: {
                                    animate.toggle()
                                })
                        
                        ), title: device.name, caption: "\(getRunTime(unix: device.cycleStarted))")
                    }
                }
            
                MainControl(icon: AnyView(
                    Image(systemName: "arrow.triangle.capsulepath")
                        .font(.title2)
                ), title: "\(String(updater.status.laundry.compactMap({$0.cyclesToday}).reduce(0, +))) Cycles", caption: "today")
            }
        }
        
    }
}

struct LaundryOverview_Previews: PreviewProvider {
    static var previews: some View {
        LaundryOverview()
    }
}
