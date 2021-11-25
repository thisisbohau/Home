//
//  WeatherView.swift
//  Home
//
//  Created by David Bohaumilitzky on 28.06.21.
//

import SwiftUI

struct WeatherView: View {
    @Binding var weather: Weather
    
    var indicator: some View{
        ZStack{
            HStack{
                LinearGradient(colors: [.mint, .orange], startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
            }.frame(width: 100, height: 10).cornerRadius(30)
            HStack{
                Circle()
                    .frame(width: 15, height: 15)
                    
                Spacer()
            }.offset(x: CGFloat(100*(weather.currentTemp/weather.hight)))
        }.frame(width: 100).cornerRadius(30)
       
    }
    var rainIndicator: some View{
        ZStack{
            HStack{
                LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
            }.frame(width: 100, height: 10).cornerRadius(30)
            HStack{
                Circle()
                    .frame(width: 15, height: 15)
                    
                Spacer()
            }.offset(x: weather.rainCurrent != 0 ? CGFloat(100*(weather.rainCurrent/weather.rainToday)) : 0)
        }.frame(width: 100).cornerRadius(30)
    }
    
    var body: some View {
        VStack{
            HStack(alignment: .bottom){
            Spacer()
        VStack{
            
                
                Image(systemName: WeatherKit().getWeatherIcon(condition: weather.condition))
                    .font(.system(size: 60, weight: .light))
                    .padding(.top)
                    .frame(height: 90)
                Text(WeatherKit().getWeatherDescription(condition: weather.condition))
                    .foregroundStyle(.secondary)
                    .font(.title3)
                        .padding(.top, 10)
                    .foregroundStyle(.secondary)
                Text("\(weather.currentTemp.description)°")
                .font(.custom("SF Mono", size: weather.condition == 5 ? 40 : 60).weight(.medium))
                    .padding(.top)
                HStack{
                    Text(Int(weather.low).description)
                        .bold()
                        .foregroundStyle(.secondary)
                            indicator
                    Text(Int(weather.hight).description)
                        .bold()
                        .foregroundStyle(.primary)
                }
            Spacer()
        }
                if weather.condition == 5{
                    
                    Spacer()
                    VStack{
                        Image(systemName: "drop")
                            .font(.system(size: 60, weight: .light))
                            .padding(.top)
                            .frame(height: 90)
                            
                        Text("Precipitation")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .padding(.top, 10)
                            .foregroundStyle(.secondary)

                        Text("\(String(format:"%.1f", weather.rainCurrent))mm")
                            .font(.custom("SF Mono", size: weather.condition == 5 ? 40 : 60).weight(.medium))
                            .padding(.top)
                        HStack{
                            Text(Int(0).description)
                                .bold()
                                .foregroundStyle(.secondary)
                                    rainIndicator
                            Text(Int(weather.rainToday).description)
                                .bold()
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                    }
                }
            Spacer()
            }
            Spacer()
            Text("Last Updated \(IrrigationKit().getLocalTimeFromUnix(unix: weather.lastUpdate))")
                .foregroundStyle(.secondary)
                .padding()
//            HStack(alignment: .top){
////                VStack(alignment: .leading){
//
//                    HStack(alignment: .top){
//
//                        Spacer()
//
//                    }.padding([.top, .bottom, .leading])
//
//    //                    .font(.system(size: 50).bold())
//    //                    .padding(.top)
//                        .foregroundStyle(.primary)
//
//
//
//
//
//
////                }
//                Spacer()
    //            VStack{
    //                Image(systemName: WeatherKit().getWeatherIcon(condition: weather.status.weather.condition))
    //                    .font(.system(size: 60, weight: .light))
    //                    .padding()
    ////                    .padding(.top)
    //                    .foregroundStyle(.secondary)
    //            }
    //            Spacer()
            }
    
    
        .padding()
        .padding(.top)
        .background(LinearGradient(colors: WeatherKit().getWeatherColors(condition: weather.condition), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
