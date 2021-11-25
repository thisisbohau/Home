//
//  LightList.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.06.21.
//

import SwiftUI

struct BoxList: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(Color(UIColor.gray))
            .cornerRadius(13)
            .shadow(color: .secondary.opacity(0.1), radius: 3, x: 0, y: 5)
            .padding([.leading, .trailing])
            .padding(5)
    }
}

struct LightList: View {
    @EnvironmentObject var home: Updater
    
    func toggleLight(light: Light){
        LightKit().toggleLight(light: light)
    }
    var body: some View {
        VStack(alignment: .leading){
            ForEach(home.status.rooms){room in
                VStack(alignment: .leading){
                    Text(room.name)
                        .font(.title.bold())
                        .padding(.leading)
                    ForEach(room.lights){light in
                        Button(action: {toggleLight(light: light)}){
                            HStack{
                                Image(systemName: "lightbulb.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(light.state ? .yellow : .secondary)
                                VStack(alignment: .leading){
                                    Text(light.name)
                                        .foregroundColor(.primary)
                                        .font(.title2.bold())
                                    Text(light.state ? "ON | \(light.brightness)" : "OFF")
                                        .foregroundColor(.primary)
                                }
                                Spacer()

                            }.modifier(BoxList())
                        }
                    }
                }
            }
        }
    }
}

struct LightList_Previews: PreviewProvider {
    static var previews: some View {
        LightList()
    }
}
