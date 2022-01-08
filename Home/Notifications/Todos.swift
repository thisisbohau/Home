//
//  Todos.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.01.22.
//

import SwiftUI

struct Todos: View {
    @EnvironmentObject var updater: UpdateManager
    
    var body: some View {
        VStack{
            ForEach(updater.status.laundry){device in
                if device.cycleEnded{
                    ActionRecommendation(icon: AnyView(
                        Image("laundry")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color("secondary"), .clear)
                    ), title: "Empty \(device.name)", caption: "Cycle finished at \(SystemUtility().unixToDate(unix: device.cycleEndedOn))", actionPrompt: "", action: {
                        
                    })
                }
            }
//            ActionRecommendation(icon: AnyView(
//                Image(systemName: "sunset")
//                    .overlay(
//                LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
//                    .mask(Image(systemName: "sunset"))
//                )
//            ), title: "Bedtime Routine", caption: "Adapt lights and blinds, set commute", actionPrompt: "Set", action: {
//                
//            })
        }
    }
}

struct Todos_Previews: PreviewProvider {
    static var previews: some View {
        Todos()
    }
}
