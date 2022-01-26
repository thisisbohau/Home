//
//  NFC.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.07.21.
//

import Foundation
import CoreNFC

class RoomTagKit: ObservableObject{
    @Published var roomDetected: Bool = false
//    @Published var detectedRoom: Room = Room(id: 0, name: "", floor: 0, lights: [Light](), blinds: [Blind](), tempDevices: [TempDevice](), type: RoomType(icon: "", color: ""), occupied: false, lastOccupied: "")
    @Published var detectedRoomId: Int = 0
    
    func parseTag(url: URL, rooms: [Room]){
        print("URL received: \(url.description)")
        guard let components = URLComponents(string: url.absoluteString) else{
            print("URL components not found")
            return}
        
        if components.path == "/roomTag/"{
            guard let roomId = components.queryItems?.first(where: {$0.name == "room"})else{
                print("URL: room not found")
                return}
            
            print("URL opening room")
//            guard let room = rooms.first(where: {$0.id == Int(roomId.value ?? "") ?? 0})else{
//                print("Room Tag scan failed. no matching room")
//                roomDetected = false
//                return
//            }
            roomDetected = true
            detectedRoomId = Int(roomId.value ?? "") ?? 0
            
            print("Room Tag scan complete\(detectedRoomId)")
        }
    }
}
class URLParser{
    func createURL(directories: [String], parameters: [URLQueryItem]) -> URL{
        var components = URLComponents()
        components.path = "/\(directories.joined(separator: "/"))/"
        components.scheme = "home"
        components.queryItems = parameters
        let url: URL = components.url ?? URL(string: "home://")!
        print(url.description)
        return url
    }
}

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate{
    @Published var selectedRoom: String = ""
    @Published var roomDetected: Bool = false
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Scanning for NFC tag failed with errors: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NFC tag detected")
        
        for messageIndex in 0 ..< messages.count {
             
             let message = messages[messageIndex]
             print("\tMessage \(messageIndex) with length \(message.length)")
             
             for recordIndex in 0 ..< message.records.count {
                 
                 let record = message.records[recordIndex]
                 print("\t\tRecord \(recordIndex)")
                 print("\t\t\tidentifier: \(String(describing: String(data: record.identifier, encoding: .utf8)))")
                 print("\t\t\ttype: \(String(describing: String(data: record.type, encoding: .utf8)))")
                 print("\t\t\tpayload: \(String(describing: String(data: record.payload, encoding: .utf8)))")
                 
//                 let tagURL = URL(string: String(data: record.payload, encoding: .utf8) ?? "") ?? URL(string: "home://")!
//                 guard let components = URLComponents(string: tagURL.absoluteString) else{
//                     print("URL components not found")
//                     return}
//                 
//                 if components.path == "/roomTag/"{
//                     guard let roomId = components.queryItems?.first(where: {$0.name == "room"})else{
//                         print("URL: room not found")
//                         return}
//                     selectedRoom = roomId.value ?? ""
//                     roomDetected = true
//                 }
                 
                 
             }
         }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
  
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Can not write to more than one tag.")
            return
        }
        let currentTag = tags.first!
        
        session.connect(to: currentTag) { error in
            
            guard error == nil else {
                session.invalidate(errorMessage: "Connection to RoomTag failed")
                return
            }
            
            currentTag.readNDEF(){message, error in
                guard let record = message?.records.first else{return}
                    
                    
                    print("\t\tRecord \(record)")
                    print("\t\t\tidentifier: \(String(describing: String(data: record.identifier, encoding: .utf8)))")
                    print("\t\t\ttype: \(String(describing: String(data: record.type, encoding: .utf8)))")
                    print("\t\t\tpayload: \(String(describing: String(data: record.payload, encoding: .utf8)))")
                    
                    let tagURL = URL(string: String(data: record.payload, encoding: .utf8) ?? "") ?? URL(string: "home://")!
                    guard let components = URLComponents(string: tagURL.absoluteString) else{
                        print("URL components not found")
                        return}
                    
                    if components.path == "/roomTag/"{
                        guard let roomId = components.queryItems?.first(where: {$0.name == "room"})else{
                            print("URL: room not found")
                            return}
                        self.selectedRoom = roomId.value ?? ""
                        self.roomDetected = true
                    }
                
                    
                    
                
            }
        }
    }
    
    
    override init(){
        guard NFCReaderSession.readingAvailable else {
            return
        }
    }
    
    func startScanning(){
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold near RoomTag to scan"
        session.begin()
    }
}

class NFCProgrammer: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate{
    @Published var selectedRoom: String = ""
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Scanning for NFC tag failed with errors: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NFC tag detected")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        //create a action url with the selected Room and write to nfc tag
        let url = URLParser().createURL(directories: ["roomTag"], parameters: [URLQueryItem(name: "room", value: selectedRoom)]).absoluteString
        
        let uriPayloadFromString = NFCNDEFPayload.wellKnownTypeURIPayload(
            string: url
        )!

        let message = NFCNDEFMessage.init(
            records: [
                uriPayloadFromString
            ]
        )
        
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Can not write to more than one tag.")
            return
        }
        let currentTag = tags.first!
        
        session.connect(to: currentTag) { error in
            
            guard error == nil else {
                session.invalidate(errorMessage: "Connection to RoomTag failed")
                return
            }
            
            currentTag.queryNDEFStatus { status, capacity, error in
                
                guard error == nil else {
                    session.invalidate(errorMessage: "RoomTag status couldn't be determined")
                    return
                }
                
                switch status {
                case .notSupported: session.invalidate(errorMessage: "RoomTag is not supported.")
                case .readOnly:     session.invalidate(errorMessage: "RoomTag is only readable.")
                case .readWrite:

                    currentTag.writeNDEF(message) { error in
                        
                        if error != nil {
                            session.invalidate(errorMessage: "Error while programming RoomTag.")
                        } else {
                            session.alertMessage = "RoomTag programmed."
                            session.invalidate()
                        }
                    }
                    
                @unknown default:   session.invalidate(errorMessage: "Unknown status of tag.")
                }
            }
        }
    }
    
    override init(){
        guard NFCReaderSession.readingAvailable else {
            return
        }
        
    
    }
    
    func startScanning(){
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold near RoomTag to scan"
        session.begin()
    }
}
