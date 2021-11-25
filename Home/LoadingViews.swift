//
//  loadingViews.swift
//  Home
//
//  Created by David Bohaumilitzky on 05.06.21.
//

import Foundation
import SwiftUI

struct CircularWaveProgressView: View {
    var radius: CGFloat
    var hideCircle: Bool?
    @State var shouldAnimate: Bool = false
    
    var body: some View {
            Circle()
                .fill(hideCircle ?? false ? .clear : .accentColor)
//            .opacity(shouldAnimate ? 0.0 : 1)
//            .opacity(0.2)
            
            .frame(width: radius, height: radius)
            .overlay(
                ZStack {
//                    Circle()
//                        .stroke(Color.accentColor, lineWidth: 100)
//                        .scaleEffect(shouldAnimate ? 0.5 : 0)
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 1 : 0)
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 1.5 : 0)
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 2 : 0)
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 100)
                        .scaleEffect(shouldAnimate ? 2.5 : 0)
                   
                }
                .opacity(shouldAnimate ? 0.0 : 0.3)
//                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: false))
                
        )
        
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: false), {
                self.shouldAnimate = true
            })
            
        }
    }
}
