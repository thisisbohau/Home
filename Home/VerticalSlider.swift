//
//  VerticalSlider.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.06.21.
//

import SwiftUI

struct VerticalSlider: View {
    @Binding var value: Float
    @Binding var lineColor: Color
    @State var floatValue: Float = 0
    
    @State var lastValue: Float = 0
    
    var onChange: () -> Void
    
    func update(){
        var distance = lastValue.distance(to: floatValue)
        distance = distance < 0 ? distance * -1 : distance
        
        if distance > (floatValue < 10 ? 1 : 9){
            print("distance to last value:\(distance)")
            if floatValue < 2{
                value = 0
            }else{
                value = floatValue
            }
            lastValue = floatValue
            onChange()
        }
    }
    func setup(){
        floatValue = value
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
                                    .frame(width: geometry.size.width * CGFloat((floatValue != 0 ? floatValue : 1)/100))
                            }
                            .frame(height: 120)
                            .cornerRadius(36)
//#if os(tvOS)
                            .gesture(DragGesture(minimumDistance: 0)
                                    
                            .onChanged({ value in
                                
                                let predictedLocation = min(max(0, Float(value.predictedEndLocation.x / geometry.size.width * 100)), 100)
                                self.floatValue = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
//                                print("brightness\(value)")
                                print("new value")
                                
                                
                                
                                if predictedLocation.distance(to: floatValue) > 15{
                                    print("fast movement, waiting")
                                }else{
                                    print("updating")
                                    update()
                                }
                                
//                                if Calendar.current.dateComponents([.second], from: lastPush, to: Date()).second ?? 0 > 1{
//                                    update()
//                                    lastPush = Date()
//                                }
                            })
                            .onEnded({value in
                                update()
                            }))
                        Spacer()
                    }
                }.frame(width: 350, height: 250)
            }
        }.rotationEffect(.init(degrees: -90), anchor: .center).frame(width: 160, height: 370)
            .onAppear(perform: setup)
            .onChange(of: value, perform: {value in setup()})
    }
}

//struct VerticalSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        VerticalSlider()
//    }
//}
