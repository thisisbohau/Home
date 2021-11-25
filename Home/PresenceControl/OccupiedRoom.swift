//
//  OccupiedRoom.swift
//  Home
//
//  Created by David Bohaumilitzky on 31.10.21.
//

import SwiftUI

struct OccupiedRoom: View {
    @Binding var room: Room
    
    var body: some View {
        VStack{
        HStack{
            Spacer()
            VStack{
                VStack{
                Image(systemName: "person.wave.2.fill")
                        .foregroundColor(room.occupied ? .teal : .secondary)
                    .font(.system(size: 70))
                    .shadow(color: .teal, radius: room.occupied ? 15 : 0, x: 0, y: 0)
                }.frame(height: 80).padding()
                Text(room.occupied ? "Now Occupied" : "Not Occupied")
                .font(.largeTitle.bold())
                .padding(room.occupied ? 10 : 0)
                if !room.occupied{
                    Text("Last occupied: \(IrrigationKit().getLocalTimeFromUnix(unix: room.lastOccupied))")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }.padding(.bottom)
            if room.occupied{
                Text("Based on sensor data and geofence status, Home has determined that \(room.name) is currently occupied.")
                    .multilineTextAlignment(.center)
            }else{
                Text("Based on sensor data and geofence status, Home has determined that \(room.name) is currently empty.")
                    .multilineTextAlignment(.center)
            }
                
        Spacer()
            Text("Important: The Occupied state is not a definite indication that no one is present. Pets and moving objects may interfere with the accuracy of the Occupied signal.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .font(.caption)
            
    }
        .padding()
        .padding(.top)


    }
}

