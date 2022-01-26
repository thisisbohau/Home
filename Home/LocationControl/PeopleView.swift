//
//  peopleView.swift
//  Home
//
//  Created by David Bohaumilitzky on 28.12.21.
//

import SwiftUI

struct PeopleView: View {
    @EnvironmentObject var updater: UpdateManager
    
    var body: some View {
        ForEach(updater.status.devices){device in
            HStack{
               Image("homeIcon")
                    .foregroundColor(device.home ? .accentColor : .secondary)
                    .padding(5)
                VStack(alignment: .leading){
                    Text(device.name)
                        .font(.headline)
                    if device.role == 1{
                        Text("Visitor | No location available")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }else{
                        Text(device.home ? "Is at Home" : "Away since \(SystemUtility().unixToDate(unix: device.lastHome))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading)
                Spacer()
            }.padding(.bottom).padding(.top)
        }
    }
}

struct peopleView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}
