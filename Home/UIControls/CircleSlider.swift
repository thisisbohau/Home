//
//  CircleSlider.swift
//  Home
//
//  Created by David Bohaumilitzky on 24.06.21.
//

import SwiftUI

struct CircleSlider: View {
    var progressColors: [Color]
//    var secondaryColor: Color
    @Binding var value: Float
    var maxValue: CGFloat
    var size: CGFloat
    @State var progress : CGFloat = 0
    @State var angle : Double = 0
    
    func setup(){
        let current = value/Float(maxValue)
        let Angle = 252*current
        angle = Double(Angle)
        progress = CGFloat(Angle/360)
    }
    var body: some View{
        
        VStack{
            ZStack{
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.secondary.opacity(0.3),style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(Angle(degrees: 145))
                    

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(LinearGradient(colors: progressColors, startPoint: .trailing, endPoint: .leading), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(Angle(degrees: 145))
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .offset(x: size / 2)
                    .rotationEffect(.init(degrees: angle))
                    .gesture(DragGesture().onChanged(onDrag(value:)))
                    .rotationEffect(Angle(degrees: 145))
                
//                Text("$" + String(progress.description))
//                    .font(.largeTitle)
//                    .fontWeight(.heavy)
            }
        }
        .onAppear(perform: setup)
    }
    
    func onDrag(value: DragGesture.Value){
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // since atan2 will give from -180 to 180...
        // eliminating drag gesture size
        // size = 55 => Radius = 27.5...
        
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        
        // converting to angle...
        
        var angle = radians * 180 / .pi
        
        // simple technique for 0 to 360...
        
        // eg = 360 - 176 = 184...
        if angle < 0{angle = 360 + angle}
        
        withAnimation(Animation.linear(duration: 0.15)){
            
            // progress...
            
            let progress = angle / 360
            if progress > 0.7{
                self.progress = 0.7
                self.angle = Double(252)
                self.value = Float(maxValue)
            }else{
                if angle != 0{
                    self.progress = progress
                    self.angle = Double(angle)
                    self.value = Float(maxValue * (progress*1.3))
                }
            }
            
        }
    }
}

//struct CircleSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleSlider()
//    }
//}
