//
//  LaundryOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 21.09.21.
//

import SwiftUI

struct LaundryOverview: View {
    @EnvironmentObject var updater: UpdateManager
    @State var animate: Bool = false
    @State var showDetails: Bool = false
    
    
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
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(updater.status.laundry){device in
                    if device.activeCycle{
                        Button(action: {showDetails.toggle()}){
                            MainControl(icon: AnyView(
                                Image("laundry")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color("primary"), .clear)
                                    .rotationEffect(Angle(degrees: animate ? 360 : 0))
                                    .font(.title2)
                            ), title: device.name, caption: "\(getRunTime(unix: device.cycleStarted))")
                        }
                    }
                }
            
                MainControl(icon: AnyView(
                    Image(systemName: "arrow.triangle.capsulepath")
                        .font(.title2)
                ), title: "\(String(updater.status.laundry.compactMap({$0.cyclesToday}).reduce(0, +))) Cycles", caption: "today")
            }
        }
        .sheet(isPresented: $showDetails){
            LaundryView()
        }
//        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: animate)
                            
        .onAppear(perform: {
            DispatchQueue.main.async {
                withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 0.7, damping: 0.8, initialVelocity: 1).repeatForever(autoreverses: true)){
                    animate.toggle()
                }
            }
            
        })
        
        
    }
}

struct LaundryOverview_Previews: PreviewProvider {
    static var previews: some View {
        LaundryOverview()
    }
}
