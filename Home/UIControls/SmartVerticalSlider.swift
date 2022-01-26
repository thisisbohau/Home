//
//  VerticalSlider.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.06.21.
//

import SwiftUI

struct SmartVerticalSlider: View {
    @Binding var displayedValue: Int
    @Binding var setTo: Int
    @Binding var lineColor: Color
    @State var brightnessPosition: Int = 0
    @State var isDragging: Bool = false
    @State var highVelocity = false
    @State var lastValue: Int = 0
    @State private var previousDragValue: DragGesture.Value?

     func calcDragVelocity(previousValue: DragGesture.Value, currentValue: DragGesture.Value) -> Double {
         let timeInterval = currentValue.time.timeIntervalSince(previousValue.time)
         let diffYInTimeInterval = Double(currentValue.translation.height - previousValue.translation.height)
         let velocityY = diffYInTimeInterval / timeInterval
         return velocityY
     }
    
    func pushRemoteChange(){
        if isDragging{
            print("Remote update blocked, dragging")
        }else{
            print("value remotely updated")
            brightnessPosition = displayedValue
        }
    }
    
    var onChange: () -> Void

    func updateWithValue(value: Float){
        var distance = lastValue.distance(to: Int(value))
        distance = distance < 0 ? distance * -1 : distance
        
        if distance > 1{
            lastValue = Int(value)
            if setTo != Int(value){
                if setTo.distance(to: Int(value)) > 2 || setTo.distance(to: Int(value)) < -2{
                    setTo = Int(value)
                    print("VALUE: \(Int(value))")
                    onChange()
                }
            }
        }
    }

    func setup(){
        lastValue = Int(displayedValue)
        brightnessPosition = Int(displayedValue)
        
    }
    var body: some View {
        VStack{
            HStack{
                GeometryReader { geometry in
                    VStack{
                        Spacer()
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .foregroundColor(Color.gray.opacity(0.3))
                                Rectangle()
                                    .foregroundColor(lineColor)
                                    .frame(width: geometry.size.width * CGFloat(Float(brightnessPosition > 2 ? brightnessPosition : 0)/100))
                            }
                            .frame(height: 120)
                            .cornerRadius(36)
                            .gesture(DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                isDragging = true
                                var speed = 0.0
                                if let previousValue = self.previousDragValue {
                                    // calc velocity using currentValue and previousValue
                                    speed = calcDragVelocity(previousValue: previousValue, currentValue: value)
                                    print("drag velocity: \(speed)")
                                }
                                // save previous value
                                self.previousDragValue = value
                                let value = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                                if speed > 30 || speed < -30{
                                    //high velocity
                                    highVelocity = true
                                    brightnessPosition = Int(value)
                                    
                                }else if highVelocity == false{
                                    brightnessPosition = Int(value)
                                    updateWithValue(value: value)
                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                                    if speed == 0{
                                        highVelocity = false
                                    }
                                }
                            })
                            .onEnded({value in
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                                    isDragging = false
                                    displayedValue = brightnessPosition
                                })
                                highVelocity = false
                                let value = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                                updateWithValue(value: value)
                            }))
                        Spacer()
                    }
                }.frame(width: 350, height: 250)
            }
        }
            .rotationEffect(.init(degrees: -90), anchor: .center).frame(width: 160, height: 370)
            .onAppear(perform: setup)
            .onChange(of: displayedValue, perform: {value in pushRemoteChange()})
    }
}

//struct VerticalSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        VerticalSlider()
//    }
//}
