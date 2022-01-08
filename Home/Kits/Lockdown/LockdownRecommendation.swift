//
//  LockdownRecommendation.swift
//  Home
//
//  Created by David Bohaumilitzky on 22.07.21.
//

import SwiftUI

struct LockdownRecommendation: View {
    @Binding var lockdown: Lockdown
    
    var body: some View {
        HStack(alignment: .top){
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.pink)
                .font(.title)
                .padding(.trailing)
            VStack(alignment: .leading){
                Text("Lockdown recommended")
                    .font(.title3).bold()
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("Reason: \(lockdown.reason)")
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .padding([.top, .bottom], 10)
                
                Button(action: {
                    LockdownKit().activateLockdown()
                }){
                    HStack{
                        Spacer()
                        Text("Activate Lockdown")
                            .bold()
                            .foregroundColor(.pink)
                            .padding()
                        Spacer()
                    }
                }
                Text("Home might autonomously trigger lockdown if conditions worsen.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
            }
            
            Spacer()
        }.modifier(BoxBackground()).shadow(radius: 3)
    }
}

//struct LockdownRecommendation_Previews: PreviewProvider {
//    static var previews: some View {
//        LockdownRecommendation()
//    }
//}
