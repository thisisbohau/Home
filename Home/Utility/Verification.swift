//
//  Verification.swift
//  Home
//
//  Created by David Bohaumilitzky on 26.09.21.
//

import Foundation
import Security
import SwiftUI

struct Credentials: View{
    @State var serverIP: String = ""
    @State var password: String = ""
    @State var nickName: String = ""
    @State var update: Bool = false
    
    func setup(){
        serverIP = String(data: Keychain.load(key: "HomeAdress") ?? Data(), encoding: .utf8) ?? "Not set"
        password = String(data: Keychain.load(key: "HomePassword") ?? Data(), encoding: .utf8) ?? ""
        nickName = String(data: Keychain.load(key: "UserName") ?? Data(), encoding: .utf8) ?? ""
    }
    func save(){
        let _ = Keychain.save(key: "HomeAdress", data: serverIP.data(using: .utf8) ?? Data())
        let _ = Keychain.save(key: "HomePassword", data: password.data(using: .utf8) ?? Data())
        let _ = Keychain.save(key: "UserName", data: nickName.data(using: .utf8) ?? Data())
        update = false
        setup()
    }
    var body: some View{
        Section(header: Text("Home Credentials"), footer: Text("Sever IP-Address, device token and identifier")){
            VStack(alignment: .leading){
                Text("Home Adress:")
                    .bold()
                Text(serverIP)
                    .foregroundColor(.secondary)
            }.padding(10)
            
            VStack(alignment: .leading){
                Text("Device Token:")
                    .bold()
                Text("\(String(data: Keychain.load(key: "DeviceToken") ?? Data(), encoding: .utf8) ?? "")")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }.padding(10)
            VStack(alignment: .leading){
                Text("Device Identifier:")
                    .bold()
                Text("\(UIDevice.current.identifierForVendor!.uuidString)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }.padding(10)
            Button(action: {update.toggle()}){
                Text("Update Credentials")
                    .padding(.leading, 10)
            }
        }.sheet(isPresented: $update, onDismiss: save){
            VStack{
                HStack{
                    Spacer()
                    Text("Credentials")
                        .font(.largeTitle.bold())
                    Spacer()
                }.padding(.top)
                Spacer()
                Form{
                    Section(header: Text("Add Home Address and Secure Password. Do not share this information.")){
                        TextField("Home Address", text: $serverIP)
                        SecureField("Password", text: $password)
                    }
                    Section(header: Text("This name will be used for personalized notifications and actions.")){
                        TextField("Preferred user Name", text: $nickName)
                    }
                    Section{
                        Text("Device Token and identifier are unique to your device and cannot be changed. We may collect your devices name along with model name and wifi configuration.")
                            .padding([.top, .bottom], 10)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(action: save){
                    HStack{
                        Spacer()
                        Text("Update")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
            }.padding()
        }
        .onAppear(perform: setup)
    }
}
class Keychain {

    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}
