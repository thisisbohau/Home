//
//  SmartCircleGauge.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.01.22.
//

import SwiftUI

struct SmartCircleGauge: View {
    var currentInterval: Int
    var initialInterval: Int
    var accentColor: Color
    var secondaryColor: Color
    var stroke: CGFloat
    var background: Color?
  
    func getTrim() -> CGFloat{
        let trim = (1/CGFloat(initialInterval) * CGFloat(currentInterval))
        return trim
        
    }
    var body: some View{
        ZStack {
            Circle()
                .fill(background ?? .clear)
            Circle()
                .stroke(secondaryColor, lineWidth: stroke)
                
             
                
            Circle()
                .trim(from: 0, to: getTrim())
                .stroke(accentColor, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                .animation(.linear(duration: 0.3), value: currentInterval)
                .rotationEffect(.degrees(-90))
        }
    }
}


