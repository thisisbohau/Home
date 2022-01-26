//
//  NewDeviceAccess.swift
//  Home
//
//  Created by David Bohaumilitzky on 26.12.21.
//

import SwiftUI

struct NewDeviceAccess: View {
    @Binding var show: Bool
    @State var step: Int = 0
    @State var codeInput: String = ""
    @State var name: String = ""
    @State var role: Int = 2
    
    func sendCode(){
        AccessKit().sendActivationCode(role: role)
    }
    func activate(){
        Task{
            let success = await AccessKit().activateDevice(code: codeInput, name: name, role: role)
    //        AccessKit().activateDevice(code: codeInput, name: name, role: role, completion: {success in
            DispatchQueue.main.async {
                if success{
                    step += 1
                    
                }else{
                    step = 4
                }
            }
           
        }
//        })
    }
    
    var error: some View{
        VStack{
            Text("Upps")
                .font(.largeTitle.bold())
            
            Spacer()
            Image(systemName: "xmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.red)
            Text("The activation code was invalid, or AccessControl has blocked your request. Try again or contact the system Administrator")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top)
            Spacer()
            Button(action: {step = 1}){
                HStack{
                    Spacer()
                    Text("Try again")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
    var credentials: some View{
        VStack{
            Text("About You")
                .font(.largeTitle.bold())
            
            Spacer()
            TextField("Name", text: $name)
                 .padding(10)
                 .background(.thinMaterial)
                 .cornerRadius(15)
             Text("This name is visible to all participants.")
                 .font(.caption)
                 .foregroundStyle(.secondary)
            
            HStack{
                Button(action: {role = 1}){
                    HStack{
                        VStack(alignment: .leading){
                            Text("Visitor")
                                .font(.title2.bold())
                            Text("Temporary access")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            HStack{
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(role == 1 ? .accentColor : Color("secondary"))
                                    .font(.title3)
                            }
                        }
                        Spacer()
                    }
                    .padding(10)
                    .aspectRatio(0.8, contentMode: .fit)
                    .background(Color("fill"))
                    .cornerRadius(18)
                }
                Button(action: {role = 2}){
                    HStack{
                        VStack(alignment: .leading){
                            Text("Participant")
                                .font(.title2.bold())
                                .multilineTextAlignment(.leading)
                            Text("Access | Location ")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Spacer()
                            HStack{
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(role == 2 ? .accentColor : Color("secondary"))
                                    .font(.title3)
                            }
                        }
                        Spacer()
                    }
                    .padding(10)
                    .aspectRatio(0.8, contentMode: .fit)
                    .background(Color("fill"))
                    .cornerRadius(18)
                }
                
                Button(action: {role = 3}){
                    HStack{
                        VStack(alignment: .leading){
                            Text("Display")
                                .font(.title2.bold())
                            Text("Access Only")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Spacer()
                            HStack{
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(role == 3 ? .accentColor : Color("secondary"))
                                    .font(.title3)
                            }
                        }
                        Spacer()
                    }
                    .padding(10)
                    .aspectRatio(0.8, contentMode: .fit)
                    .background(Color("fill"))
                    .cornerRadius(18)
                }
            }
                .padding(.top)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            Text("Select the role of current device. AccessControl will validate your request beforehand")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: {step += 1; sendCode()}){
                HStack{
                    Spacer()
                    Text("Continue")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
    var welcome: some View{
        VStack{
            Text("Hey. Hi. Hello")
                .font(.largeTitle.bold())
            
            Spacer()
            Image("homeIcon")
                .font(.system(size: 80))
                .foregroundColor(Color("secondary"))
            Spacer()
            Button(action: {step += 1}){
                HStack{
                    Spacer()
                    Text("Contine")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
    
    var body: some View {
        switch step{
        case 0:
            welcome
        case 1:
            credentials
        case 2:
            verificationCode
        case 3:
            deviceAdded
        case 4:
            error
        default:
            welcome
        }
    }


    var verificationCode: some View{
        VStack{
            Text("Activation Pending")
                .font(.largeTitle.bold())
            
            Spacer()
           TextField("1 2 3 4", text: $codeInput)
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(20)
                .font(.largeTitle)
            Text("A verification code has been sent to the administrator of Home. This code is only valid for one activation.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: {activate()}){
                HStack{
                    Spacer()
                    Text("Check and register")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
    
    var deviceAdded: some View{
        VStack{
            Text("Welcome Home")
                .font(.largeTitle.bold())
            
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
            Spacer()
            Text("Your device is now registered on the Home Server. If you are a visitor no location data will be collected and sent.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: {show.toggle()}){
                HStack{
                    Spacer()
                    Text("Get Started")
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
        }.padding().padding(.top)
            .background(Color("background").ignoresSafeArea())
    }
}
//struct NewDeviceAccess_Previews: PreviewProvider {
//    static var previews: some View {
//        NewDeviceAccess()
//    }
//}
