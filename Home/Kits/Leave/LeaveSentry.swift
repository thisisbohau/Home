//
//  LeaveSentry.swift
//  Home
//
//  Created by David Bohaumilitzky on 24.07.21.
//

import SwiftUI

struct LeaveSentry: View {
    @Binding var page: Int
    @EnvironmentObject var updater: UpdateManager
    @State var showWindowWarning: Bool = false
    
    var useSentry: Bool
    
    func sentry(){
        if useSentry{
            SwitchKit().set(id: 25324, newValue: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
            if updater.status.rooms.flatMap({$0.windows}).filter({$0.state == true}).count > 0{
                showWindowWarning = true
            }else{
                page += 1
            }
        }
    }
    
    var windowWarning: some View{
        VStack{
            HStack{
                Spacer()
                VStack{
                    Image(systemName: "exclamationmark.shield")
                        .font(.system(size: 85))
                        .foregroundColor(.pink)
                    
                    Text("\(String(updater.status.rooms.flatMap({$0.windows}).filter({$0.state == true}).count)) Windows open")
                        .font(.largeTitle.bold())
                        .padding(.top)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }.padding(.top).padding()
            
            Text("Close the following windows to continue:")
                .font(.headline)
//                .padding(.top)
            List{
                
                ForEach(updater.status.rooms.filter({$0.openWindow == true})){window in
                    Text(window.name)
                        .bold()
                        .padding(10)
                }
            }
            
            Spacer()
            HStack{
                Text("Leaving windows open poses a serious security risk.")
                    .foregroundStyle(.secondary)
                    .padding(.leading)
                Spacer()
            }
            
            Button(action: {}){
                HStack{
                    Spacer()
                    Text("Skip and leave windows open")
                        .font(.body.bold())
                    Spacer()
                }
                
                
            }.buttonStyle(RectangleButtonStyle(color: Color.pink))
                .padding(10)
        }
//        .padding()
    }
    var body: some View{
        VStack{
            if showWindowWarning{
                windowWarning
            }else{
                main
            }
        }
    }
    var main: some View {
        VStack{
            HStack{
                Spacer()
                Text("Security Check")
                    .font(.largeTitle.bold())
                Spacer()
            }.padding()
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(3)
                .padding()
            Text("Analyzing sensor data in progress")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }.padding()
        .onAppear(perform: sentry)
    }
}

//struct LeaveSentry_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaveSentry()
//    }
//}
