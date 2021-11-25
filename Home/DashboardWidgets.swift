//
//  DashboardWidgets.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.07.21.
//

import SwiftUI
import CoreGraphics


struct Widget: View{
    var view: AnyView
    var title: String
    
    var body: some View{
        VStack(alignment: .leading){
            Text(title)
                .font(.title.bold())
                .padding([.leading, .top])
            view
                .shadow(radius: 3)
        }
    }
}

struct CriticalNotifications: View{
    @EnvironmentObject var updater: Updater
    var body: some View{
        VStack{
            if updater.status.lockdown.triggered{
                LockdownActive(lockdown: $updater.status.lockdown)
            }else if updater.status.lockdown.recommenced{
                Widget(view: AnyView(LockdownRecommendation(lockdown: $updater.status.lockdown)), title: "Critical Incident")
            }
            
            if !updater.status.notifications.isEmpty{
                Widget(view: AnyView(NotificationList()), title: "Notifications")
            }
            if updater.status.sentry.active{
                SentryView()
            }
            
        }
    }
}
struct DashboardWidgets: View {
    @EnvironmentObject var updater: Updater
    var proxy: CGSize
    @State var leave: Bool = false
    
    var body: some View {
        VStack(alignment: .leading){
            CriticalNotifications()
//            PresenceOverview(proxy: proxy)
            SceneOverview()
            
            
            Widget(view: AnyView(PowerOverview(screenWidth: proxy.width)), title: "Power")
//            Widget(view: AnyView(WeatherOverview()), title: "Weather")
            Widget(view: AnyView(IrrigationRoom()), title: "Irrigation")
            Widget(view: AnyView(MowerOverview()), title: "Mower")
            Widget(view: AnyView(PoolOverview()), title: "Pool")

        }
    }
}

//struct DashboardWidgets_Previews: PreviewProvider {
//    static var previews: some View {
//        DashboardWidgets()
//    }
//}
