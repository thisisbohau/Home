//
//  Timer.swift
//  Home
//
//  Created by David Bohaumilitzky on 07.05.21.
//

import Foundation
import SwiftUI

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
  return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

struct TimerGauge: View {
    var timeRemaining: Int
    var startDuration: Int
    var color: Color
    var stroke: CGFloat
    var font: Font
    
    func format() -> String{
        let (_,m,s) = secondsToHoursMinutesSeconds(seconds: timeRemaining)
        return "\(m):\(s)"
    }
  
    func getTrim() -> CGFloat{
        let trim = (1/CGFloat(startDuration) * CGFloat(timeRemaining))
        print("trim: \(trim)")
        return trim
        
    }
    var body: some View{
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: stroke)
                .opacity(0.3)
            Circle()
                .trim(from: 0, to: getTrim())
                .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
//                .animation(.linear(duration: 0.3))
                .animation(.linear(duration: 0.3), value: timeRemaining)
                .rotationEffect(.degrees(-90))
            .overlay(
                Text(format())
                .font(font)
            )
        }
    }
}


struct TimerView: View {
    @Binding var seconds: Int
    @Binding var duration: Int
    
//    func end(){
//        
////        notifications().invalidateNotificationForId(id: "Timer")
//    }
    var body: some View{
        GeometryReader{geo in
//            VStack(alignment: .leading){
//                Text("Just a sec.")
//                    .font(.largeTitle)
//                    .bold()
//                    .padding(.top)
//                Text("Good job. Before you continue wait until the timer has finished. Take a break, or do something else, we'll send you a notification when you can continue.")
//                    .foregroundColor(Color.secondary)
//                Spacer()
//            }.padding()
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    TimerGauge(timeRemaining: seconds, startDuration: duration, color: .orange, stroke: 8, font: .largeTitle)
                        .frame(width: geo.size.width/2, height: geo.size.width/2, alignment: .center)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

