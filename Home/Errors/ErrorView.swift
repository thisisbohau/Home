//
//  ErrorView.swift
//  ErrorView
//
//  Created by David Bohaumilitzky on 25.08.21.
//

import SwiftUI

struct ErrorView: View{
    @EnvironmentObject var updater: Updater
    @State var showDetail: Bool = false
    
    var body: some View{

        VStack{
            HStack{
                Spacer()
                VStack{
                    VStack{
                        Image(systemName: "exclamationmark.icloud")
                        .renderingMode(.original)
                        .font(.system(size: 70))
                        .shadow(color: .yellow, radius: 15, x: 0, y: 0)
                    }.frame(height: 80).padding()
                Text("Connection Failed")
                    .font(.largeTitle.bold())
                    .padding(10)
                }
                Spacer()
            }.padding([.top, .bottom])
            HStack{
                Text(updater.errorDescription)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .modifier(BoxBackground())
            Spacer()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
