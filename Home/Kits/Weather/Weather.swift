//
//  Weather.swift
//  Home
//
//  Created by David Bohaumilitzky on 27.06.21.
//

import SwiftUI

//struct WeatherOverview: View {
//    @EnvironmentObject var weather: Updater
//    @State var showDetail: Bool = false
////    @State var weather: Weather = Weather(currentTemp: 23, low: 13, hight: 32, humidity: 44, condition: 2, rainCurrent: 0, rainToday: 0, lastUpdate: "")
//    
//    var body: some View {
//        VStack{
//            Button(action: {showDetail.toggle()}){
//                main
//            }
//                .sheet(isPresented: $showDetail){
//                    WeatherView(weather: $weather.status.weather)
//                }
//                
//        }
//        .foregroundColor(.primary)
//        .padding()
////        .background(.thinMaterial)
//        .background(LinearGradient(colors: WeatherKit().getWeatherColors(condition: weather.status.weather.condition), startPoint: .topLeading, endPoint: .bottomTrailing).overlay(.ultraThinMaterial))
//        .cornerRadius(13)
//        .padding([.leading, .trailing])
//    }
//    
//    var indicator: some View{
//        HStack{
//            LinearGradient(colors: [.mint, .orange], startPoint: .leading, endPoint: .trailing).ignoresSafeArea()
//        }.frame(width: 100, height: 10).cornerRadius(30)
//    }
//    var main: some View{
//        HStack(alignment: .top){
//            VStack(alignment: .leading){
////                HStack{
////
////                    Text("HOME")
////                        .font(.title2)
////                        .bold()
////                        .foregroundStyle(.secondary)
////                    Spacer()
////                }
//                HStack(alignment: .top){
//                    Image(systemName: WeatherKit().getWeatherIcon(condition: weather.status.weather.condition))
//                        .font(.system(size: 60, weight: .light))
//                        
//    //                    .padding(.top)
//                        .foregroundStyle(.secondary)
//                    Spacer()
//                    if weather.status.weather.condition == 5{
//                        VStack{
//                            Image(systemName: "drop")
//                                .font(.system(size: 50, weight: .light))
//                            Text("\(String(format:"%.1f", weather.status.weather.rainCurrent))mm")
//                        }.foregroundStyle(.secondary)
//                    }
//                }.padding([.top, .bottom, .leading])
//                Text("\(weather.status.weather.currentTemp.description)°")
//                    .font(.custom("SF Mono", size: 60).weight(.medium))
////                    .font(.system(size: 50).bold())
////                    .padding(.top)
//                    .foregroundStyle(.primary)
//                Text(WeatherKit().getWeatherDescription(condition: weather.status.weather.condition))
//                    .foregroundStyle(.secondary)
//                    .font(.title3)
//                
//                HStack{
//                    Text(Int(weather.status.weather.low).description)
//                        .bold()
//                        .foregroundStyle(.secondary)
//                    indicator
//                    Text(Int(weather.status.weather.hight).description)
//                        .bold()
//                        .foregroundStyle(.primary)
//                }.padding(.top)
//                   
//                
//                
//            }
//            Spacer()
////            VStack{
////                Image(systemName: WeatherKit().getWeatherIcon(condition: weather.status.weather.condition))
////                    .font(.system(size: 60, weight: .light))
////                    .padding()
//////                    .padding(.top)
////                    .foregroundStyle(.secondary)
////            }
////            Spacer()
//        }
//        
//    }
//}

//struct Weather_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherOverview()
//    }
//}
