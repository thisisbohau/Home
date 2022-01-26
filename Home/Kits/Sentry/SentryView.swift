//
//  SentryView.swift
//  SentryView
//
//  Created by David Bohaumilitzky on 22.08.21.
//

import SwiftUI

struct SentryView: View {
    @EnvironmentObject var updater: UpdateManager
    @State var animate: Bool = false
    @State var unlocked: Bool = false
    @State var activeRooms: [Room] = [Room]()
    
    func resetAndTurnOff(){
//        Biometrics().authenticate(completion: {state in
            SentryKit().turnOffSentry()
//        })
    }
    
    func resetSentry(){
//        Biometrics().authenticate(completion: {state in
            SentryKit().resetSentry()
//        })
    }
    func update(){
        activeRooms.removeAll()
        for room in updater.status.sentry.motionInRooms{
            if let room = updater.status.rooms.first(where: {$0.id == room}){
                activeRooms.append(room)
            }
        }
    }
    var body: some View {
        VStack{
            if updater.status.sentry.sentryTriggered{
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Image("sentry")
                            .renderingMode(.original)
                            .overlay(Image(systemName: "exclamationmark").font(.body.bold()))
//                            .foregroundColor(.white)
                            .font(.system(size: 50))
                            .padding()
                            .background(
                                ZStack{
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.6 : 0.2))
                                        .scaleEffect(animate ? 0.9 : 1.7, anchor: .center)
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.2 : 0.6))
                                        .scaleEffect(animate ? 1.7 : 0.9, anchor: .center)
                                    Circle()
                                        .foregroundStyle(.regularMaterial)
//                                        .foregroundColor(.pink)
                                }
                            )
                            
                        Spacer()
                    }.padding()
                    Text("SENTRY TRIGGERED")
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text("Sentry triggered the alarm. Lockdown has been activated and will remain active until you disable it.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        Spacer()
                    HStack{
                        
                        VStack(alignment: .leading){
                            Text("Live View")
                                .font(.title.bold())
                        if !unlocked{
                            
                            Button(action: {
                                Biometrics().authenticate(completion: {state in
                                    if state{
                                        unlocked = true
                                    }
                                })
                            }){
                                HStack{
                                    Spacer()
                                    Label("Unlock Live View", systemImage: "lock")
                                        .font(.body.bold())
                                    Spacer()
                                }
                                
                            }.buttonStyle(RectangleButtonStyle(color: Color.pink))
                        }else{
                                ForEach(activeRooms){room in
                                    HStack{
                                        Text(room.name)
                                        Spacer()
                                        Text("Motion Detected")
                                            .foregroundColor(.secondary)
                                    }.padding([.bottom], 10)
                                    Divider()
                                    
                                }
                                if activeRooms.isEmpty{
                                    Text("Currently, no motion has been detected ")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                        .padding(10)
                                    Divider()
                                }
                            }
//                            Spacer()
                            Button(action: resetSentry){
                                HStack{
                                    Spacer()
                                    Text("All Clear")
                                        .font(.body.bold())
                                    Spacer()
                                }
                                
                            }.buttonStyle(RectangleBorderButtonStyle(color: Color.gray))
                        }.padding(.top, 10)
                        Spacer()
                    }
              
                }
                .padding()
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true), {
                        animate.toggle()
                    })
                })
            }else if updater.status.sentry.alarmState{
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Image("sentry")
                            .renderingMode(.original)
//                            .foregroundColor(.white)
                            .font(.system(size: 50))
                            .padding()
                            .background(
                                ZStack{
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.6 : 0.2))
                                        .scaleEffect(animate ? 0.9 : 1.7, anchor: .center)
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.2 : 0.6))
                                        .scaleEffect(animate ? 1.7 : 0.9, anchor: .center)
                                    Circle()
                                        .foregroundStyle(.regularMaterial)
//                                        .foregroundColor(.pink)
                                }
                            )
                            
                        Spacer()
                    }.padding()
                    Text("ALARM STATE")
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text("Sentry has detected suspicious activity in one room.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        Spacer()
                    HStack{
                        VStack(alignment: .leading){
                            Text("Live view")
                                .font(.title.bold())
                            
                            if !unlocked{
                            Button(action: {
                                Biometrics().authenticate(completion: {state in
                                    if state{
                                        unlocked = true
                                    }
                                })
                            }){
                                HStack{
                                    Spacer()
                                    Label("Unlock Live View", systemImage: "lock")
                                        .font(.body.bold())
                                    Spacer()
                                }
                                
                            }.buttonStyle(RectangleButtonStyle(color: Color.pink))
                        }else{
                                ForEach(activeRooms){room in
                                    HStack{
                                        Text(room.name)
                                        Spacer()
                                        Text("Motion detected")
                                            .foregroundColor(.secondary)
                                    }.padding([.bottom], 10)
                                    
                                    
                                }
                                if activeRooms.isEmpty{
                                    Text("Currently, no motion has been detected ")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                        .padding(10)
                                    Divider()
                                }
                            }
                            
                        }.padding(.top, 10)
                        Spacer()
                    }
//                    Spacer()
                    Button(action: resetSentry){
                        HStack{
                            Spacer()
                            Text("All Clear")
                                .font(.body.bold())
                            Spacer()
                        }
                        
                    }.buttonStyle(RectangleBorderButtonStyle(color: Color.gray))
              
                }
                .padding()
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true), {
                        animate.toggle()
                    })
                })
            }else{
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Image("sentry")
                            .renderingMode(.original)
//                            .foregroundColor(.white)
                            .font(.system(size: 50))
                            .padding()
                            .background(
                                ZStack{
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.6 : 0.2))
                                        .scaleEffect(animate ? 0.9 : 1.2, anchor: .center)
                                    Circle()
                                        .foregroundColor(.pink.opacity(animate ? 0.2 : 0.6))
                                        .scaleEffect(animate ? 1.2 : 0.9, anchor: .center)
                                    Circle()
                                        .foregroundStyle(.regularMaterial)
//                                        .foregroundColor(.pink)
                                }
                            )
                            
                        Spacer()
                    }.padding()
//                    Spacer()
                    Text("SENTRY ACTIVATED")
                        .font(.title).bold()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text("Protected by Home")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        Spacer()
                    Button(action: resetAndTurnOff){
                        HStack{
                            Spacer()
                            Text("Turn Off Sentry")
                                .font(.body.bold())
                            Spacer()
                        }
                        
                    }.buttonStyle(RectangleBorderButtonStyle(color: Color.gray))
                        .padding(.top, 10)
                }
                .padding()
//                .modifier(BoxBackground()).shadow(radius: 3)
                .onAppear(perform: {
                    withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), {
                        animate.toggle()
                    })
                })
            }
        }
        .onChange(of: updater.lastUpdated, perform: {_ in update()})
    }
}

struct SentryView_Previews: PreviewProvider {
    static var previews: some View {
        SentryView()
    }
}
