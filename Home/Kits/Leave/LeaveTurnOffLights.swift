//
//  LeaveTurnOffLights.swift
//  Home
//
//  Created by David Bohaumilitzky on 24.07.21.
//

import SwiftUI

struct LeaveTurnOffLights: View {
    @Binding var page: Int
    @State var floor: Int = 0
    
    func turnOff(){
        SceneKit().floorOff(floor: 0){success in}
        DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
            floor = 1
            SceneKit().floorOff(floor: 1){success in}
            DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                
                page += 1
            }
        }
//
//        SceneKit().floorOff(floor: 0){success in
//            if success{
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
//                    floor = 1
//                    SceneKit().floorOff(floor: 1){success in
//                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
//                            page += 1
//                        }
//                    }
//                }
//            }
//        }
    }
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(floor == 0 ? "EG" : "OG")
                    .font(.largeTitle.bold())
                Spacer()
            }.padding()
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(3)
                .padding()
            Text("Turning off lights...")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }.padding()
        .onAppear(perform: turnOff)
    }
}

//struct LeaveTurnOffLights_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaveTurnOffLights()
//    }
//}
