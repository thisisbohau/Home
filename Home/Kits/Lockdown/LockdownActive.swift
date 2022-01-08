//
//  LockdownActive.swift
//  Home
//
//  Created by David Bohaumilitzky on 22.07.21.
//

import SwiftUI

struct LockdownActive: View {
    @Binding var lockdown: Lockdown
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.pink)
                    .font(.system(size: 80))
                    .padding()
                Spacer()
            }
            Text("Lockdown active")
                .font(.title).bold()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Text("Reason: \(lockdown.reason)")
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding([.top, .bottom], 10)
            
            Button(action: {
                LockdownKit().deactivateLockdown()
            }){
                HStack{
                    Spacer()
                    Text("Deactivate Lockdown")
                        .bold()
                        .foregroundColor(.pink)
                        .padding()
                    Spacer()
                }
            }
            Text("Triggered: \(IrrigationKit().getLocalTimeFromUnix(unix: lockdown.triggeredAt))")
                .foregroundStyle(.secondary)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .padding(.top, 10)
        }
        .modifier(BoxBackground()).shadow(radius: 3)
    }
}
