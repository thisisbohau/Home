//
//  DogModeOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.11.21.
//

import SwiftUI

struct DogModeOverview: View {
    @EnvironmentObject var updater: Updater
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                VStack{
                    Image(systemName: "pawprint")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .padding()
                    Text(updater.status.dogMode.active ? "DogMode\nActive" : "DogMode\nInactive")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                }
                Spacer()
                
                
            }
                .padding(.top)
            Spacer()
            if updater.status.dogMode.active || updater.status.dogMode.state == 1{
                Image("light.bulb")
                    .renderingMode(.original)
                    .font(.system(size: 50))
                    .background(
                        Circle()
                            .foregroundColor(.yellow.opacity(updater.status.dogMode.state == 2 ? 0.5 : 1))
                            .blur(radius: updater.status.dogMode.state == 2 ? 25 : 35)
                    )
            }else{
                Image("light.bulb.off")
                    .renderingMode(.original)
                    .font(.system(size: 50))
            }
            if updater.status.dogMode.active{
                if updater.status.dogMode.state != 1{
                    Text(updater.status.dogMode.state == 2 ? "Dimmed": "Full brightness")
                        .font(.title3.bold())
                        .padding()
                    Spacer()
                    Text(updater.status.dogMode.state == 2 ? "Priority lights are dimmed, making up for lost natural light" : "Priority lights are on full brightness, insuring maximum comfort.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding([.leading, .trailing])
                }else{
                    Text("Ambient light used")
                        .font(.title3.bold())
                        .padding()
                    Spacer()
                    Text("Available natural light is currently keeping Home well lit.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding([.leading, .trailing])
                }
                }else{
                        Spacer()
                    }
            
        }
        .padding()
        .background(Color("background").ignoresSafeArea())
    }
}

struct DogModeOverview_Previews: PreviewProvider {
    static var previews: some View {
        DogModeOverview()
    }
}
