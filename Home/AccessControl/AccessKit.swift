//
//  Accesskit.swift
//  Home
//
//  Created by David Bohaumilitzky on 26.12.21.
//

import Foundation
import UIKit
import Security
import CoreLocation

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

class AccessKit{
    func setServerAddress(address: String){
        let _ = Keychain.save(key: "SeverAddress", data: address.data(using: .utf8) ?? Data())
    }
    func getServerAddress() -> String{
        let address = Keychain.load(key: "SeverAddress") ?? Data()
        return String(data: address, encoding: .utf8) ?? ""
    }
    func getWelcomeDisplay(currentUser: Device) -> String{
        if currentUser.role == 3{
            return "Welcome Home"
        }else{
            return "Hello \(currentUser.name)"
        }
    }
    func sessionStart(){
        Task{
            print("Starting session. Contacting server...")
            let response = await getDeviceList()
            if response.1{
                guard let currentDevice = response.0.first(where: {$0.id == getDeviceToken()}) else{
                    print("No registered device found. Aborting execution")
                    return
                }
                let session = Session(id: UUID().uuidString, name: currentDevice.name, deviceToken: currentDevice.id, date: Date().timeIntervalSince1970.description, role: currentDevice.role)
               
                var sessionString = ""
                let encoder = JSONEncoder()
                do{
                    let data = try encoder.encode(session)
                    sessionString = String(data: data, encoding: .utf8) ?? ""
                }catch{
                    print("session entry couldn't be converted. aborting.")
                    return
                }
                
                var queries = [URLQueryItem]()
                queries.append(URLQueryItem(name: "action", value: "sessionStart"))
                queries.append(URLQueryItem(name: "deviceToken", value: getDeviceToken()))
                queries.append(URLQueryItem(name: "accessToken", value: getAccessKey()))
                queries.append(URLQueryItem(name: "session", value: sessionString))
                
                let _ = try? await RequestManager().makeAccessRequest(queries: queries)
                
            }else{
                print("No session device could be fetched. Continuing with last known values from device storage.")
                
            }
        }
    }
    func getDeviceList() async -> ([Device], Bool) {
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "requestDeviceList"))
        queries.append(URLQueryItem(name: "deviceToken", value: getDeviceToken()))
        queries.append(URLQueryItem(name: "accessToken", value: getAccessKey()))
        
        let data1 = try? await RequestManager().makeAccessRequest(queries: queries)
        
        guard let dataC = data1 else{
            print("No response from server")
            return ([Device](), false)
        }
        let decoder = JSONDecoder()
        do{
            let StringData = dataC.data(using: .utf8) ?? Data()
            let Status = try decoder.decode([Device].self, from: StringData)
            return (Status, true)
        }catch{
            print("Unable to decode device list. \(error.localizedDescription)")
            return ([Device](), false)
        }
    }

    func getAccessKey() -> String{
        let key = String(data: Keychain.load(key: "AccessKey") ?? Data(), encoding: .utf8) ?? ""
        return key
    }
    func getDeviceName() -> String{
        let key = String(data: Keychain.load(key: "DeviceName") ?? Data(), encoding: .utf8) ?? ""
        return key
    }
    func getFCMToken() -> String{
        
        return String(data: Keychain.load(key: "FCMToken") ?? Data(), encoding: .utf8) ?? ""
    }
    func getDeviceToken() -> String{
        let key = String(data: Keychain.load(key: "DeviceIdentifierToken") ?? Data(), encoding: .utf8) ?? ""
        if key == ""{
            let token = UIDevice.current.identifierForVendor!.uuidString
            let _ = Keychain.save(key: "DeviceIdentifierToken", data: token.data(using: .utf8) ?? Data())
            print("DeviceToken generated and saved in keychain: \(token)")
            return token
        }else{
            return key
        }
    }
    func sendActivationCode(role: Int){
        Task{
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "requestLogin"))
        queries.append(URLQueryItem(name: "deviceToken", value: getDeviceToken()))
        queries.append(URLQueryItem(name: "role", value: role.description))
        
        let _ = try? await RequestManager().makeAccessRequest(queries: queries)
        }
    }
    
    func activateDevice(code: String, name: String, role: Int) async -> Bool {
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "addDevice"))
        queries.append(URLQueryItem(name: "deviceToken", value: getDeviceToken()))
        queries.append(URLQueryItem(name: "verificationCode", value: code))
        queries.append(URLQueryItem(name: "deviceName", value: name))
        queries.append(URLQueryItem(name: "role", value: role.description))
        queries.append(URLQueryItem(name: "fcmToken", value: getFCMToken()))
        
        let response = try? await RequestManager().makeAccessRequest(queries: queries)

        if response != "Login failed"{
            let saved = Keychain.save(key: "AccessKey", data: response?.data(using: .utf8) ?? Data())
            print("New AccessKey generated: \(response ?? "--"). Saved in keychain: \(saved.description)")
            return true
        }else{
            return false
        }
    }
    
    func getRoleDescription(role: Int) -> String{
        switch role{
        case 0:
            return "Administrator"
        case 1:
            return "Visitor"
        case 2:
            return "Participant"
        case 3:
            return "Display"
        default:
            return "Participant"
        }
    }
}
