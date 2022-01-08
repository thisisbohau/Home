//
//  WeatherAdaption.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

struct WeatherAdaption: View {
    @EnvironmentObject var updater: UpdateManager
    
    func toggleAdaption(){
        SwitchKit().toggle(id: updater.status.weather.weatherAdaption.id)
    }
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                VStack{
                    Image(systemName: updater.status.weather.weatherAdaption.state ? "aqi.medium" : "pause.fill")
                        .font(.system(size: 60))
                        .padding().padding(.top)
                        .foregroundColor(.teal)
                    Text(updater.status.weather.weatherAdaption.state ? "Active" : "Paused")
                        .font(.largeTitle.bold())
                }
                Spacer()
            }.padding()
            if updater.status.weather.weatherAdaption.state{
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
            Button(action: toggleAdaption){
                HStack{
                    Spacer()
                    Text(updater.status.weather.weatherAdaption.state ? "Pause Weather Adaption" : "Activate Weather Adaption")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding()
    }
}

struct WeatherAdaption_Previews: PreviewProvider {
    static var previews: some View {
        WeatherAdaption()
    }
}
