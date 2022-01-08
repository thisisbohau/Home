//
//  ServerSettings.swift
//  Home
//
//  Created by David Bohaumilitzky on 28.12.21.
//

import SwiftUI

struct ServerSettings: View {
    @State var input: String = ""
    @EnvironmentObject var updater: UpdateManager
    
    init() {
         UITextView.appearance().backgroundColor = .clear
     }
    
    func setup(){
        input = AccessKit().getServerAddress()
    }
    
    func set(){
        AccessKit().setServerAddress(address: input)
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
                .frame(height: 200)
            Text("Device Identifier")
                .font(.headline.bold())
                .padding(.top)
            VStack(alignment: .leading){
                HStack{
                Text(AccessKit().getDeviceToken())
                    Spacer()
                }
            }
            .padding(10)
            .background(.thinMaterial)
            .cornerRadius(15)
            Text("This identifier is unique to your device and cannot be changed.\nThe system has also generated a completely unique Access Token. This information is securely stored on your device.")
                .foregroundStyle(.secondary)
                .font(.caption)
           
            
            Spacer()
            
            Button(action: {set()}){
                HStack{
                    Spacer()
                    Text("Apply changes")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
        
            .onAppear(perform: setup)
    }
}

struct ServerSettings_Previews: PreviewProvider {
    static var previews: some View {
        ServerSettings()
    }
}
