//
//  DishwasherOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.01.22.
//

import SwiftUI

struct DishwasherOverview: View {
    @EnvironmentObject var updater: UpdateManager
    @State var showStartProgram: Bool = false
    @State var showProgramOverview: Bool = false
    
    func getTime() -> String{
        let time = secondsToHoursMinutesSeconds(seconds: updater.status.dishwasher.timeRemaining)
        
        
        if time.0 != 0{
            return "\(time.0)h \(time.1)min"
        }else{
            return "\(time.1)min"
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                Button(action: {showProgramOverview.toggle()}){
                    MainControl(icon: AnyView(
                        Image(systemName: "arrow.triangle.capsulepath")
                            .font(.title2)
                    ), title: "\(String(updater.status.laundry.compactMap({$0.cyclesToday}).reduce(0, +))) Cycles", caption: "today")
                }
                .sheet(isPresented: $showProgramOverview){
                    DishwasherStatus()
                }
                if DishwasherKit().getOperationState(status: updater.status.dishwasher.operationState) == .Running{
                    MainControl(icon: AnyView(
                        HStack{
                            Label(getTime(), systemImage: "timer")
                            
                        }
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        
                            
                    ), title: "Running", caption: updater.status.dishwasher.activeProgram)
                }
        
            }
        }
        .sheet(isPresented: $showStartProgram){
            LaundryView()
        }
        
    }
}

struct DishwasherOverview_Previews: PreviewProvider {
    static var previews: some View {
        DishwasherOverview()
    }
}
