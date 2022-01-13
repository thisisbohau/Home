//
//  WakeUpSetup.swift
//  Home
//
//  Created by David Bohaumilitzky on 07.10.21.
//

import SwiftUI

struct WakeUpSetup: View {
    @State var step: Int = 0
    @Binding var active: Bool
    
    func next(){
        step += 1
    }
    var body: some View{
        VStack{
            switch step{
            case 0:
                main
            case 1:
                WakeUpSettings(active: $active)
            default:
                main
            }
        }
    }
    var main: some View {
        VStack{
            HStack{
                Spacer()
                VStack{
                    Image(systemName: "moon.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.indigo)
                    Text("Bedtime Routine")
                        .font(.largeTitle.bold())
                        .padding(.top)
                }
                Spacer()
            }.padding()
            Spacer()
            Text("Set your morning commute, wake up time and more.")
                .foregroundStyle(.secondary)
            Button(action: next){
                HStack{
                    Spacer()
                    Text("Next")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.indigo))

        }.padding()
    }
}

//struct WakeUpSetup_Previews: PreviewProvider {
//    static var previews: some View {
//        WakeUpSetup()
//    }
//}
