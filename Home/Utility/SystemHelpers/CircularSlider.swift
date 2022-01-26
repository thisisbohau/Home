//
//  CircularSlider.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.06.21.
//

import SwiftUI

struct CircularSlider : View {
    var max: CGFloat
    var size: CGFloat
    @Binding var value: Int
//    @State var size = UIScreen.main.bounds.width - 100
    @State var progress : CGFloat = 0
    @State var angle : Double = 0
    
    var body: some View{
        
        VStack{
            
            ZStack{
                Circle()
//                    .trim(from: 0, to: 0.7)
                    .stroke(Color.secondary.opacity(0.3),style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(Angle(degrees: -90))
                    

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(LinearGradient(colors: [.teal, .blue], startPoint: .trailing, endPoint: .leading), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .frame(width: size, height: size)
//                    .rotationEffect(Angle(degrees: 145))
                    .rotationEffect(.init(degrees: -90))
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .offset(x: size / 2)
                    .rotationEffect(.init(degrees: angle))
                    .gesture(DragGesture().onChanged(onDrag(value:)))
                    .rotationEffect(.init(degrees: -90))
//                    .rotationEffect(Angle(degrees: 145))
                
                
                Circle()
                    .stroke(Color("stroke"),style: StrokeStyle(lineWidth: 55, lineCap: .round, lineJoin: .round))
                    .frame(width: size, height: size)
                
                // progress....
                
//                Circle()
//                    .trim(from: 0, to: progress)
//                    .stroke(Color.green,style: StrokeStyle(lineWidth: 55, lineCap: .butt))
//                    .frame(width: size, height: size)
//                    .rotationEffect(.init(degrees: -90))
                
                // Inner Finish Curve...
//
//                Circle()
//                    .fill(Color("stroke"))
//                    .frame(width: 55, height: 55)
//                    .offset(x: size / 2)
//                    .rotationEffect(.init(degrees: -90))
                
                // Drag Circle...
                
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 55, height: 55)
//                    .offset(x: size / 2)
//                    .rotationEffect(.init(degrees: angle))
//                // adding gesture...
//                    .gesture(DragGesture().onChanged(onDrag(value:)))
//                    .rotationEffect(.init(degrees: -90))
//
//                // sample $200
//                Text("$" + String(format: "%.0f", progress * 200))
//                    .font(.largeTitle)
//                    .fontWeight(.heavy)
            }
        }
    }
    
    func onDrag(value: DragGesture.Value){
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // since atan2 will give from -180 to 180...
        // eliminating drag gesture size
        // size = 55 => Radius = 27.5...
        
        let radians = atan2(vector.dy - 27.5, vector.dx - 27.5)
        
        // converting to angle...
        
        var angle = radians * 180 / .pi
        
        // simple technique for 0 to 360...
        
        // eg = 360 - 176 = 184...
        if angle < 0{angle = 360 + angle}
        
        withAnimation(Animation.linear(duration: 0.15)){
            
            // progress...
            let progress = angle / 360
            self.progress = progress
            self.value = Int(max*progress)
            self.angle = Double(angle)
        }
    }
}
