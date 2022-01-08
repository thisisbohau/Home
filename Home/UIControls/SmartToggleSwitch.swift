//
//  ToggleSwitch.swift
//  Home
//
//  Created by David Bohaumilitzky on 14.12.21.
//

import SwiftUI

struct SmartToggleSwitch: View {
    @Binding var active: Bool
    var sliderHeight: CGFloat
    var sliderWidth: CGFloat
    var onColor: Color
    var onIcon: AnyView
    var offIcon: AnyView
    
    @State var sliderOffset: CGFloat = 0
    
    func setup(){
        if active{
            sliderOffset = 0
        }else{
            sliderOffset = sliderHeight/2
        }
        
    }
    
    var onToggle: some View{
        HStack{
            Spacer()
            VStack{
                Spacer()
                onIcon
                Spacer()
            }
            Spacer()
        }
        .background(onColor)
        .cornerRadius(36)
        .padding()
    }
    var offToggle: some View{
        HStack{
            Spacer()
            VStack{
                Spacer()
                offIcon
                Spacer()
            }
            Spacer()
        }
        .background(Color.gray)
        .cornerRadius(36)
        .padding()
    }
    
    var body: some View {
        GeometryReader{proxy in
            VStack{
                HStack{
                    Spacer()
                }
                Spacer()
            }
            .frame(height: sliderHeight)
            .background(.regularMaterial)
            .cornerRadius(50)
            
            VStack{
                if active{
                    onToggle
                }else{
                    offToggle
                }
            }
            .animation(.linear(duration: 0.1), value: active)
            .frame(height: (sliderHeight/2))
            
            .offset(y: sliderOffset)
            .gesture(DragGesture(minimumDistance: 5)
                .onChanged({location in
                    let calcOffset = location.location.y
                    let tresh = sliderHeight/2
                    if calcOffset > tresh{
                        sliderOffset = tresh
                    }else if calcOffset < 0{
                        sliderOffset = 0
                    }else{
                        sliderOffset = calcOffset
                    }
                
                if calcOffset > sliderHeight/2*0.5{
                        active = false
                    }else{
                        active = true
                    }
                
                })
                .onEnded({location in
                withAnimation(.linear(duration: 0.1)){
                    let calcOffset = location.location.y
                    let tresh = sliderHeight/2
                    if calcOffset > sliderHeight/2*0.5{
                        sliderOffset = tresh
                        active = false
                    }else{
                        sliderOffset = 0
                        active = true
                    }
                }
                    
                })
            )
            .onChange(of: active, perform: {_ in setup()})
            .onAppear(perform: {
                setup()
            })
        }
        .frame(width: sliderWidth, height: sliderHeight)
    }
}

//struct ToggleSwitch_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack{
//            Spacer()
//            ToggleSwitch()
//            Spacer()
//        }.frame(width: 230)
//
//    }
//}
