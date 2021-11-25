//
//  ContentView.swift
//  HomeTV
//
//  Created by David Bohaumilitzky on 16.06.21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: ServerData
    @EnvironmentObject var updater: Updater
    var body: some View {
        ScrollView{
            LightList()
                .padding()
                
                .onAppear(perform: {updater.startUpdateLoop()})
        }
        
//            .environmentObject(sever)
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
