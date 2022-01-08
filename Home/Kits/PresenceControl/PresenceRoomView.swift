//
//  PresenceRoomView.swift
//  Home
//
//  Created by David Bohaumilitzky on 12.08.21.
//

import SwiftUI

struct PresenceRoomView: View {
    @Binding var room: Room
    @Binding var active: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                VStack{
                    Image("bulb.test")
                        .renderingMode(.original)
                        .font(.system(size: 60))
                        .padding().padding(.top)
                        .foregroundColor(.teal)
                    Text(room.occupied ? "Active" : "Paused")
                        .font(.largeTitle.bold())
                }
                Spacer()
            }.padding()
            if room.occupied{
                Text("The following systems may be paused, skipped, or activated autonomously:")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                VStack(alignment: .leading){
                    Text("Irrigation")
                        .font(.title3.bold())
                    Text("Lawn Mowing")
                        .font(.title3.bold())
                    Text("Battery Charging")
                        .font(.title3.bold())
                    Text("Alarm system")
                        .font(.title3.bold())
                    Text("Automatic lockdown")
                        .font(.title3.bold())
                }
            }else{
                Text("Home is currently working independently of weather conditions. All systems are active and home will return to normal operation after 24h.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            Spacer()
            Text("Weather adaption responses to changes in precipitation, temperature and light conditions using real time data from your weather station.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            Button(action: {active.toggle()}){
                HStack{
                    Spacer()
                    Text("Done")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding()
    }
}

//struct PresenceRoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        PresenceRoomView()
//    }
//}
