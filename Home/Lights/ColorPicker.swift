//
//  ColorPicker.swift
//  ColorPicker
//
//  Created by David Bohaumilitzky on 07.09.21.
//

import SwiftUI


struct ColorPicker: View {
    var radius: CGFloat
    @Binding var rgbColour: RGB
    @Binding var brightness: CGFloat
    var body: some View {
        
        DispatchQueue.main.async {
            self.rgbColour = HSV(h: self.rgbColour.hsv.h, s: self.rgbColour.hsv.s, v: self.brightness).rgb
        }
        
        return GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [
                            Color(hue: 1.0, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.9, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.8, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.7, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.6, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.5, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.4, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.3, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.2, saturation: 1.0, brightness: 0.9),
                            Color(hue: 0.1, saturation: 1.0, brightness: 0.9)
                            
                        ]), center: .center)
                    )
                    .blur(radius: 12)
                    .frame(width: radius, height: radius)
                    
                    .rotationEffect(Angle(degrees: -20))
                    
                RadialGradient(gradient: Gradient(colors: [Color.white, .clear]), center: .center, startRadius: 0, endRadius: self.radius)
                                    .blendMode(.screen)

                    .clipShape(
                        Circle()
                            .size(CGSize(width: self.radius, height: self.radius))
                    )
 
                Circle()
                    .frame(width: 10, height: 10)
                    .offset(x: (self.radius/2 - 10) * self.rgbColour.hsv.s)
                    .rotationEffect(.degrees(-Double(self.rgbColour.hsv.h)))
                
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in

                        let y = geometry.frame(in: .global).midY - value.location.y
                        let x = value.location.x - geometry.frame(in: .global).midX

                        let hue = atan2To360(atan2(y, x))

                        let center = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)

                        let saturation = min(distance(center, value.location)/(self.radius/2), 1)
                
                        self.rgbColour = HSV(h: hue, s: saturation, v: self.brightness).rgb
                    }
            )
        }
        /// Set the size.
        .frame(width: self.radius, height: self.radius)
    }
}
