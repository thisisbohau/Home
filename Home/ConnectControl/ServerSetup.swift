//
//  ServerSetup.swift
//  Home
//
//  Created by David Bohaumilitzky on 26.12.21.
//

import SwiftUI

struct ServerSetup: View {
    @State var input: String = "Ask your system administrator for login data."
    @EnvironmentObject var updater: UpdateManager
    
    init() {
         UITextView.appearance().backgroundColor = .clear
     }
    
    func set(){
        AccessKit().setServerAddress(address: input)
        updater.showDeviceSetup = true
        updater.showServerSetup = false
    }
    var body: some View {
        VStack{
            Text("Server Setup")
                .font(.largeTitle.bold())
            
            Spacer()
            Image("homeIcon")
                .font(.system(size: 80))
                .foregroundColor(Color("secondary"))
            Spacer()
            
            TextEditor(text: $input)
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(15)
                .padding(.top)
            
            Spacer()
            
            Button(action: {set()}){
                HStack{
                    Spacer()
                    Text("Set Server")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
}

struct ServerSetup_Previews: PreviewProvider {
    static var previews: some View {
        ServerSetup()
    }
}
