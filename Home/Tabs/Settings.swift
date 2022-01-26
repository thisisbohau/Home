//
//  Settings.swift
//  Home
//
//  Created by David Bohaumilitzky on 28.12.21.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var updater: UpdateManager
    @State var showRoomTag: Bool = false
    @State var showServerSettings: Bool = false
    
    func setLockdownScene(id: Int){
        SwitchKit().setInt(id: 18747, newValue: id)
    }
    
    var roomTags: some View{
        VStack{
            HStack{
                Spacer()
                Text("Room Tags")
                    .font(.title.bold())
                Spacer()
            }.padding(.top)
        
            Button(action: {
                showRoomTag.toggle()
            }){
                Text("Program Tag")
                    .padding([.leading, .trailing], 13)
                    .padding([.top, .bottom], 7)
                    .background(Color.accentColor)
                    .foregroundColor(.black)
                    .cornerRadius(30)
                    .padding(.top, 10)
            }
            
            Text("Quickly access room specific controls by holding your device near the light switch")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
        }
        .padding()
        .background(Color("fill").foregroundStyle(.secondary))
        .cornerRadius(15)
    }
    
    var calendar: some View{
        CalendarSettings()
        .padding()
        .background(Color("fill").foregroundStyle(.secondary))
        
        .cornerRadius(15)
    }
    var people: some View{
        VStack{
            HStack{
                Spacer()
                Text("People")
                    .font(.title.bold())
                Spacer()
            }.padding(.top)
            PeopleView()
        }
        .padding()
        .background(Color("fill").foregroundStyle(.secondary))
        .cornerRadius(15)
    }
    
    var morning: some View{
            VStack{
                HStack{
                    Spacer()
                    Text("Morning")
                        .font(.title.bold())
                    Spacer()
                }.padding(.top)
                
                Menu(content: {
                    ForEach(updater.status.scenes){scene in
                        Button(action: {
                            SwitchKit().setInt(id: 43017, newValue: scene.id)
                        }){
                            Text(scene.name)
                        }
                    }
                }, label: {
                    Text("Morning Routine")
                        .padding([.leading, .trailing], 13)
                        .padding([.top, .bottom], 7)
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(30)
                        .padding(.top, 10)
                })
                Menu(content: {
                    ForEach(updater.status.scenes){scene in
                        Button(action: {
                            SwitchKit().setInt(id: 33079, newValue: scene.id)
                        }){
                            Text(scene.name)
                        }
                    }
                }, label: {
                    Text("Bedtime Routine")
                        .padding([.leading, .trailing], 13)
                        .padding([.top, .bottom], 7)
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(30)
                        .padding(.top, 10)
                })
                
                Text("Set up your morning and bedtime routines.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
            }
            .padding()
            .background(Color("fill").foregroundStyle(.secondary))
            .cornerRadius(15)
        }
    
    var lockdown: some View{
            VStack{
                HStack{
                    Spacer()
                    Text("Lockdown")
                        .font(.title.bold())
                    Spacer()
                }.padding(.top)
                
                Menu(content: {
                    ForEach(updater.status.scenes){scene in
                        Button(action: {setLockdownScene(id: scene.id)}){
                            Text(scene.name)
                        }
                    }
                }, label: {
                    Text("Set Scene")
                        .padding([.leading, .trailing], 13)
                        .padding([.top, .bottom], 7)
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(30)
                        .padding(.top, 10)
                })
                
                Text("This scene will run anytime lockdown is activated. Blinds will be closed automatically on activation.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
            }
            .padding()
            .background(Color("fill").foregroundStyle(.secondary))
            .cornerRadius(15)
        }
    
    var user: some View{
        
            HStack{
                Spacer()
                VStack{
            VStack{
                Image("homeIcon")
                    .font(.title)
                    .foregroundColor(Color("fill"))
                    .padding()
            }
            .padding()
            .background(Circle().foregroundColor(updater.currentDevice.home ? .accentColor : Color("secondaryFill")))
            .padding(.top)
            Text(updater.currentDevice.home ? "At Home" : "Away")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
                    
            VStack{
                Text(updater.currentDevice.name)
                    .font(.title.bold())
                Text("\(AccessKit().getRoleDescription(role: updater.currentDevice.role)) | You")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                if updater.currentDevice.lat != 10{
                    HStack{
                        Image(systemName: "location.fill.viewfinder")
                        Text("Location Monitoring active")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
                }
                
            }.padding([.top, .bottom])
            
            }
                Spacer()
        }
        .padding()
        .background(Color("fill").foregroundStyle(.secondary))
        .cornerRadius(15)
    }
    
    var server: some View{
        VStack{
            HStack{
                Spacer()
                Text("Home Server")
                    .font(.title.bold())
                Spacer()
            }.padding(.top)
       
            
            if updater.error{
                HStack{
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.red)
                        .padding(5)
                    VStack(alignment: .leading){
                        Text("Critical issue")
                            .font(.headline)
                        Text(updater.errorDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading)
                    Spacer()
                }.padding(.bottom)
            }else if updater.started{
                HStack{
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.green)
                        .padding(5)
                    VStack(alignment: .leading){
                        Text("Online")
                            .font(.headline)
                        Text("Everything looks good")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading)
                    Spacer()
                }.padding(.bottom).padding(.top)
            }
            
//            HStack{
//                Circle()
//                    .frame(width: 15, height: 15)
//                    .foregroundColor(.orange)
//                    .padding(5)
//                VStack(alignment: .leading){
//                    Text("1 Issue")
//                        .font(.headline)
//                    Text("1 non critical error")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                }
//                .padding(.leading)
//                Spacer()
//            }.padding(.bottom)
            
            
            HStack{
                Spacer()
                Button(action: {showServerSettings.toggle()}){
                    Text("Settings")
                        .padding(10)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color("fill").foregroundStyle(.secondary))
        .cornerRadius(15)
    }
    var body: some View {
        NavigationView{
            ScrollView{
                user
                people
                    .padding(.top, 5)
                server
                    .padding(.top, 5)
                
                if updater.currentDevice.role != 1{
                    VStack{
                        LocationSettings()
                            .scaledToFit()
                        //                    .padding()
                            .cornerRadius(15)
                            .padding(.top, 5)
                        morning
                            .padding(.top, 5)
                        calendar
                            .padding(.top, 5)
                        lockdown
                            .padding(.top, 5)
                        roomTags
                            .padding(.top, 5)
                        HStack{
                            Spacer()
                        }
                        Spacer()
                            .navigationTitle("Settings")
                    }
                    
                    
                }else{
                    HStack{
                        Spacer()
                        Text("You are a visitor. Access can be revoked anytime. You cannot make any changes or set a home geofence.")
                            .font(.caption)
                            .padding()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .navigationTitle("Settings")
                }
            }
            .padding()
            .background(Color("background").ignoresSafeArea())
            .sheet(isPresented: $showServerSettings){
                ServerSettings()
            }
            .sheet(isPresented: $showRoomTag){
                RoomTagSetup()
            }
            
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
