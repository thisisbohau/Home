//
//  helpers.swift
//  Home
//
//  Created by David Bohaumilitzky on 29.04.21.
//

import Foundation
import SwiftUI

struct CircleGauge: View{
    var maxValue: CGFloat
    @Binding var value: Int
    var label: String
    var color: Color
    var stroke: CGFloat
    var font: Font
    
    
    func getTrim() -> CGFloat{
        let trim = (1/maxValue * CGFloat(value))
//        print("trim: \(trim)")
        return trim
        
    }
    
    var body: some View{
        VStack{
            Spacer()
            ZStack (alignment: .bottom){
                Circle()
//                    .trim(from: 0, to: 0.6)
                    .stroke(Color.gray, lineWidth: stroke)
                    
                    .opacity(0.3)
                    .rotationEffect(.degrees(-90))
                    .frame(alignment: .bottom)
                Circle()
                    .trim(from: 0, to: getTrim())
                    .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                    .shadow(color: color, radius: 10, x: 0, y: 0)
    //                .animation(.linear(duration: 0.3))
                    .animation(.linear(duration: 0.3), value: 30)
                    .rotationEffect(.degrees(-90))
                    .frame(alignment: .bottom)
                .overlay(
                    Text(label)
                        .font(font)
//                        .padding(.bottom)
                )
            }
        }

//        .padding().frame(width: 200, height: 200)
    }
}

struct Gauge: View{
    var maxValue: CGFloat
    @Binding var value: Int
    var label: String
    var color: Color
    var stroke: CGFloat
    var font: Font
    
    
    func getTrim() -> CGFloat{
        if value < 0{
            let trim = (0.6/maxValue * CGFloat(value * -1))
            return trim
        }else{
            let trim = (0.6/maxValue * CGFloat(value * 1))
            return trim
        }
        
//        print("trim: \(trim)")
        
        
    }
    
    var body: some View{
        VStack{
            Spacer()
            ZStack (alignment: .top){
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(Color.gray, lineWidth: stroke)
                    
                    .opacity(0.3)
                    .rotationEffect(.degrees(-200))
                    .frame(alignment: .bottom)
                Circle()
                    .trim(from: 0, to: getTrim())
                    .stroke(color, style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                    .shadow(color: color, radius: 8, x: 0, y: 0)
    //                .animation(.linear(duration: 0.3))
                    .animation(.linear(duration: 0.3), value: 30)
                    .rotationEffect(.degrees(160))
                    .frame(alignment: .bottom)
                .overlay(
                    Text(label)
                        .font(font)
                        .padding(.bottom)
                )
            }
        }

//        .padding().frame(width: 200, height: 200)
    }
}
struct ListBoxItem: ViewModifier{
    var isSelected: Bool?
    func body(content: Content) -> some View {
        if isSelected ?? false{
            content
                .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 2)
        }else{
        content
            .padding()
                .background(.thinMaterial)
                .foregroundColor(.primary)
                .cornerRadius(13)
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 2)
        }
    }
}
struct BoxBackground: ViewModifier{
    var isSelected: Bool?
    func body(content: Content) -> some View {
        if isSelected ?? false{
            content
                .padding()
                    .background(Color.accentColor)
                    .cornerRadius(13)
                    .padding()
        }else{
        content
            .padding()
                .background(.regularMaterial)
                .cornerRadius(13)
                .padding()
        }
    }
}
struct SecondaryBoxBackground: ViewModifier{
    func body(content: Content) -> some View {
        content
            .padding()
//            .background(Color.secondary.opacity(0.5))
//            .background(Color.black)
            .background(.thinMaterial)
            .cornerRadius(13)
            
//            .padding()
    }
}

struct RectangleButtonStyle: ButtonStyle {
    var color: Color
    @State var animate: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .secondary.opacity(0.7) : .white)
            .padding([.leading, .trailing])
            .padding([.top, .bottom], 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
                    .frame(height: 50)
        )
        .foregroundColor(.primary)
    }
}

struct RectangleButtonStyleAnimate: ButtonStyle {
    var color: Color
    @State var animate: Bool = false
    @Binding var animateTo: Bool
    
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .secondary.opacity(0.7) : .white)
            .padding([.leading, .trailing])
            .padding([.top, .bottom], 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .trim(from: !animate ? 0 : 0.9, to: !animate ? 0.03 : 1)
                            .stroke(Color.accentColor, lineWidth: animateTo ? 3 : 0)
                            
                            .frame(height: 50)
                        
                    )
        )
        .foregroundColor(.primary)
        .onAppear(perform: {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)){
                animate.toggle()
            }
        })
    }
}


struct RectangleBorderButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .secondary.opacity(0.7) : color)
            .padding([.leading, .trailing])
            .padding([.top, .bottom], 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(color, lineWidth: 2)
                    .frame(height: 46)
        )
        .foregroundColor(.primary)
    }
}
/// Use this method to apply different scale factors or frame size for iPad and iPhone
/// - Parameters:
///   - iPhoneSize: the size to use for iPhone
///   - iPadSize: the size to user for iPad
/// - Returns: depending on the current device the correct size
func sizeOptimizer(iPhoneSize: CGFloat, iPadSize: CGFloat) -> CGFloat{
    if UIDevice.current.userInterfaceIdiom == .pad{
        return iPadSize
    }else{
        return iPhoneSize
    }
}

func currentDeviceIsPhone() -> Bool{
    if UIDevice.current.userInterfaceIdiom != .pad{
        return true
    }else{
        return false
    }
}

//struct GaugePreview: PreviewProvider {
//    static var previews: some View {
//        Button(action: {}){
//            Text("TEST")
//        }.buttonStyle(RectangleButtonStyle(color: .orange))
//    }
//}
