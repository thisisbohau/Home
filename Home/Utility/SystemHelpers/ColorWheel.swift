//
//  ColorWheel.swift
//  Home
//
//  Created by David Bohaumilitzky on 21.06.21.
//

import Foundation
import SwiftUI
import UIKit
import CoreImage

func rgbToHue(r:CGFloat,g:CGFloat,b:CGFloat) -> (h:CGFloat, s:CGFloat, b:CGFloat) {
let minV:CGFloat = CGFloat(min(r, g, b))
let maxV:CGFloat = CGFloat(max(r, g, b))
let delta:CGFloat = maxV - minV
var hue:CGFloat = 0
if delta != 0 {
if r == maxV {
   hue = (g - b) / delta
}
else if g == maxV {
   hue = 2 + (b - r) / delta
}
else {
   hue = 4 + (r - g) / delta
}
hue *= 60
if hue < 0 {
   hue += 360
}
}
let saturation = maxV == 0 ? 0 : (delta / maxV)
let brightness = maxV
return (h:hue/360, s:saturation, b:brightness)
}
    
func atan2To360(_ angle: CGFloat) -> CGFloat {
    var result = angle
    if result < 0 {
        result = (2 * CGFloat.pi) + angle
    }
    return result * 180 / CGFloat.pi
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}


/// This UIViewRepresentable uses `CIHueSaturationValueGradient` to draw a circular gradient with the RGB colour space as a CIFilter.
struct CIHueSaturationValueGradientView: UIViewRepresentable {
    
    /// Radius to draw
    var radius: CGFloat
    
    /// The brightness/value of the wheel.
    @Binding var brightness: CGFloat
    
    /// Image view that will hold the rendered CIHueSaturationValueGradient.
    let imageView = UIImageView()
    
    func makeUIView(context: Context) -> UIImageView {
        /// Render CIHueSaturationValueGradient and set it to the ImageView that will be returned.
        imageView.image = renderFilter()
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        /// When the view updates eg. brightness changes, a new CIHueSaturationValueGradient will be generated.
        uiView.image = renderFilter()
    }
    
    /// Generate the CIHueSaturationValueGradient and output it as a UIImage.
    func renderFilter() -> UIImage {
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": CGColorSpaceCreateDeviceRGB(),
            "inputDither": 0,
            "inputRadius": radius * 0.4,
            "inputSoftness": 0,
            "inputValue": brightness
        ])!
        
        /// Output as UIImageView
        let image = UIImage(ciImage: filter.outputImage!)
        return image
    }
}

struct CIHueSaturationValueGradientView_Previews: PreviewProvider {
    static var previews: some View {
        CIHueSaturationValueGradientView(radius: 350, brightness: .constant(1))
            .frame(width: 350, height: 350)
    }
}


/// Struct that holds red, green and blue values. Also has a `hsv` value that converts it's values to hsv.
struct RGB {

    var r: CGFloat // Percent [0,1]
    var g: CGFloat // Percent [0,1]
    var b: CGFloat // Percent [0,1]
    
    static func toHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> HSV {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSV(h: 0, s: 0, v: max) }
        guard max > 0 else { return HSV(h: -1, s: 0, v: v) } // Undefined, achromatic grey
        let s = delta / max
        
        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }
        
        let h = hue(max, delta) * 60 // In degrees
        
        return HSV(h: (h < 0 ? h+360 : h) , s: s, v: v)
    }
    
    var hsv: HSV {
        return RGB.toHSV(r: self.r, g: self.g, b: self.b)
    }
}

/// Struct that holds hue, saturation, value values. Also has a `rgb` value that converts it's values to hsv.
struct HSV {
    var h: CGFloat // Angle in degrees [0,360] or -1 as Undefined
    var s: CGFloat // Percent [0,1]
    var v: CGFloat // Percent [0,1]
    
    static func toRGB(h: CGFloat, s: CGFloat, v: CGFloat) -> RGB {
        if s == 0 { return RGB(r: v, g: v, b: v) } // Achromatic grey
        
        let angle = (h >= 360 ? 0 : h)
        let sector = angle / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        
        let p = v * (1 - s)
        let q = v * (1 - (s * f))
        let t = v * (1 - (s * (1 - f)))
        
        switch(i) {
        case 0:
            return RGB(r: v, g: t, b: p)
        case 1:
            return RGB(r: q, g: v, b: p)
        case 2:
            return RGB(r: p, g: v, b: t)
        case 3:
            return RGB(r: p, g: q, b: v)
        case 4:
            return RGB(r: t, g: p, b: v)
        default:
            return RGB(r: v, g: p, b: q)
        }
    }
    
    var rgb: RGB {
        return HSV.toRGB(h: self.h, s: self.s, v: self.v)
    }
    
}

struct ColorWheel: View {

    var radius: CGFloat
    @Binding var rgbColour: RGB
    @Binding var brightness: CGFloat
    @State var knobSize : CGFloat = 25
    
    var body: some View {
        /*
        DispatchQueue.main.async {
            self.rgbColour = HSV(h: self.rgbColour.hsv.h, s: self.rgbColour.hsv.s, v: self.brightness).rgb
        }*/
        
        /// Geometry reader so we can know more about the geometry around and within the view.
        return GeometryReader { geometry in
            ZStack {
                
                /// The colour wheel. See the definition.
                CIHueSaturationValueGradientView(radius: self.radius, brightness: self.$brightness)
                    /// Smoothing out of the colours.
                    .blur(radius: 10)
                    /// The outline.
                    .overlay(
                        Circle()
                            .size(CGSize(width: self.radius, height: self.radius))
                            .stroke(Color.clear, lineWidth: 10)
                            /// Inner shadow.
                          
                    )
                    /// Clip inner shadow.
                    .clipShape(
                        Circle()
                            .size(CGSize(width: self.radius, height: self.radius))
                    )
                    /// Outer shadow.
                    
                
                /// This is not required and actually makes the gradient less "accurate" but looks nicer. It's basically just a white radial gradient that blends the colours together nicer. We also slowly dissolve it as the brightness/value goes down.
                RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.8*Double(self.brightness)), .clear]), center: .center, startRadius: 0, endRadius: self.radius/2 - 10)
                    .blendMode(.screen)
                    
                
                /// The little knob that shows selected colour.
                Circle()
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: (self.radius/2 - 10) * self.rgbColour.hsv.s)
                    .rotationEffect(.degrees(-Double(self.rgbColour.hsv.h)))
                    .foregroundColor(Color.init(red: Double(self.rgbColour.r-0.08), green: Double(self.rgbColour.g-0.08), blue: Double(self.rgbColour.b-0.08)))
                
            }
            /// The gesture so we can detect touches on the wheel.
            
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged{ value in
                       
                        
                        /// Work out angle which will be the hue.
                        let y = geometry.frame(in: .global).midY - value.location.y
                        let x = value.location.x - geometry.frame(in: .global).midX
                        
                        /// Use `atan2` to get the angle from the center point then convert than into a 360 value with custom function(find it in helpers).
                        let hue = atan2To360(atan2(y, x))
                        
                        /// Work out distance from the center point which will be the saturation.
                        let center = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)
                        
                        /// Maximum value of sat is 1 so we find the smallest of 1 and the distance.
                        let saturation = min(distance(center, value.location)/(self.radius/2), 1)
                        
                        /// Convert HSV to RGB and set the colour which will notify the views.
                        self.rgbColour = HSV(h: hue, s: saturation, v: self.brightness).rgb
                    }
            )
        }
        /// Set the size.
        .frame(width: self.radius, height: self.radius)
    }
}
