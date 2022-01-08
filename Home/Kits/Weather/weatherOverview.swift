//
//  weatherOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 22.09.21.
//

import SwiftUI

struct WeatherOverview: View {
    @Binding var weather: Weather
    
    var indicator: some View{
        ZStack{
            HStack{
                LinearGradient(colors: [.mint, .orange], startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
            }.frame(width: 50, height: 10).cornerRadius(30)
            HStack{
                Circle()
                    .frame(width: 15, height: 15)
                    
                Spacer()
            }.offset(x: CGFloat(50*(weather.currentTemp/weather.hight)))
        }.frame(width: 50).cornerRadius(30)
       
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                MainControl(icon: AnyView(
                    Image(systemName: WeatherKit().getWeatherIcon(condition: weather.condition))
                        .font(.title2)
                        .foregroundColor(WeatherKit().getWeatherColor(condition: weather.condition))
                ), title: WeatherKit().getWeatherDescription(condition: weather.condition), caption: "Updated: \(IrrigationKit().getLocalTimeFromUnix(unix: weather.lastUpdate))")
                MainControl(icon: AnyView(
                    HStack{
                        Text(Int(weather.low).description)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .fixedSize()
                                indicator
                        Text(Int(weather.hight).description)
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                            .fixedSize()
                    }
                ), title: "\(weather.currentTemp.description)°", caption: "Current Temperature")
                MainControl(icon: AnyView(
                    Image(systemName: weather.weatherAdaption.state ? "aqi.medium" : "pause.fill")
                        .font(.title2)
                ), title: weather.weatherAdaption.state ? "Active" : "Paused", caption: "Weather Adaption")
//
//
//                Image(systemName: WeatherKit().getWeatherIcon(condition: weather.condition))
//                    .font(.system(size: 60, weight: .light))
//
//                    .frame(height: 90)
//                    .foregroundColor(WeatherKit().getWeatherColor(condition: weather.condition))
//                Text("\(weather.currentTemp.description)°")
//                    .font(.custom("SF Mono", size: 40).weight(.medium))
//                    .padding(.leading, 10)
//
//                Divider()
//                    .padding([.leading, .trailing])
//
//                HStack{
//                    Text(Int(weather.low).description)
//                        .bold()
//                        .foregroundStyle(.secondary)
//                        .fixedSize()
//                            indicator
//                    Text(Int(weather.hight).description)
//                        .bold()
//                        .foregroundStyle(.primary)
//                        .fixedSize()
//                }
//
//                Divider()
//                    .padding([.leading, .trailing])
//
//                if weather.weatherAdaption.state{
//                    HStack{
//                        Image(systemName: "aqi.medium")
//                            .font(.largeTitle)
//                        Text("Adaption\nActive")
//                    }
//                }else{
//                    HStack{
//                        Image(systemName: "pause.fill")
//                            .font(.largeTitle)
//                        Text("Adaption\nInactive")
//                    }.foregroundStyle(.secondary)
//                }
            }
        }
    }
}

//struct weatherOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherOverview()
//    }
//}
