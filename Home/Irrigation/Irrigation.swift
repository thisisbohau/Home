////
////  irrigation.swift
////  Home
////
////  Created by David Bohaumilitzky on 23.04.21.
////
//
//import SwiftUI
//
//struct Irrigation: View {
//    @EnvironmentObject var data: ServerData
//    @ObservedObject var converter = Irrigation()
//    @State var status = Irrigation().systemStatus
//    @State var planner: Bool = false
////    func saveArray(){
////        let array = [irrigationSystem(controlValveActive: false, zones: [irrigationZone(id: "", active: false)], pumpStatus: false, refillActive: false, active: false, minutesRemaining: 0, secondsRemaining: 0, fault: false)]
////        do{
////            let encoded = try JSONEncoder().encodeJSONObject(array)
////            print(encoded)
////        }catch{
////            print("encoding failed")
////        }
////
////
////    }
////    func getArray(){
////        let decoder = JSONDecoder()
////        do{
////            let array = try decoder.decode([irrigationSystem](), string: String(data: data.fetchedData, encoding: .utf8)!)
//////            let array = try decoder.decode(irrigationZone.self, from: data.fetchedData)
////            print(array)
////        }catch{
////            print("decoding failed.")
////        }
////    }
//    func setup(){
//        data.statusURL = data.getStatusURL(directory: directories.irrigationStatus, queries: [URLQueryItem]())
////        status = converter.getStatus(data: data.statusData)
//    }
//    func panicMode(){
//        let url = data.getRequestURL(directory: directories.irrigationDeveloper, queries: [URLQueryItem(name: "mode", value: "panic")])
//        data.makeActionRequest(url: url)
//    }
//    func toggleMainValve(){
//        let url = data.getRequestURL(directory: directories.irrigationDeveloper, queries: [URLQueryItem(name: "valve", value: "main")])
//        data.makeActionRequest(url: url)
//    }
//    func toggleMainPump(){
//        let url = data.getRequestURL(directory: directories.irrigationDeveloper, queries: [URLQueryItem(name: "pump", value: "main")])
//        data.makeActionRequest(url: url)
//    }
//    func toggleZone(zoneID: String){
//        let url = data.getRequestURL(directory: directories.irrigationDeveloper, queries: [URLQueryItem(name: "zone", value: zoneID)])
//        data.makeActionRequest(url: url)
//    }
//    var body: some View {
//        NavigationView{
//            VStack(alignment: .leading){
//                HStack{
//                    Text(status.active ? "ON" : "OFF")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(status.active ? .green : .orange)
//                    Spacer()
//                }
//                ForEach(status.schedule){slot in
//                    HStack{
//                        Text(String(slot.minutes))
//                        Text(String(Date(timeIntervalSince1970: Double(slot.time) ?? 0).description))
//                    }
//                }
//                Button(action: {
//                    planner.toggle()
//                }){
//                    Text("Change schedule")
//                }
//            ForEach(status.zones){zone in
//                Button(action: {toggleZone(zoneID: zone.id)}){
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Zone \(zone.id)")
//                                .font(.title2)
//                                .bold()
//                                .foregroundColor(.primary)
//                            if zone.active{
//                                Text("\(zone.name) irrigating")
//                                    .foregroundColor(.secondary)
//                            }else{
//                                Text("Paused")
//                                    .foregroundColor(.secondary)
//                            }
////                            Spacer()
//                        }
//                        Spacer()
//                        if zone.active{
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                        }
//                    }
//                    .padding()
//                    .background(Color(UIColor.systemFill))
//                    .cornerRadius(13)
//                }
//            }
//                Divider()
//                HStack{
//                    Button(action: {toggleMainPump()}){
//                        HStack{
//                            Spacer()
//                            Text("Pump \(status.active ? "off" : "on")")
//                                .font(.body.bold())
//                                .foregroundColor(status.pumpStatus ? .white : .primary)
//                            Spacer()
//                        }
//                        
//                    }.buttonStyle(RectangleButtonStyle(color: status.pumpStatus ? Color(UIColor.systemOrange) : Color(UIColor.systemFill)))
//                    Spacer()
//                    Button(action: {toggleMainValve()}){
//                        HStack{
//                            Spacer()
//                            Text("Valve \(status.controlValveActive ? "off" : "on")")
//                                .font(.body.bold())
//                                .foregroundColor(status.controlValveActive ? .white : .primary)
//                            Spacer()
//                        }
//                        
//                    }.buttonStyle(RectangleButtonStyle(color: status.controlValveActive ? Color(UIColor.systemTeal) : Color(UIColor.systemFill)))
//                }
//                Spacer()
//                if status.active{
//                    Button(action: {panicMode()}){
//                        HStack{
//                            Spacer()
//                            Text("Panic")
//                                .font(.body.bold())
//                                .foregroundColor(.white)
//                            Spacer()
//                        }
//                        
//                    }.buttonStyle(RectangleButtonStyle(color: Color(UIColor.systemPink))).padding(.bottom, 10)
//                }
//        }
//            .fullScreenCover(isPresented: $planner){
//                IrrigationScheduleView(active: $planner, status: $status)
//            }
//        .padding([.leading, .trailing])
//        .navigationTitle("Irrigation")
//        .onAppear(perform: setup)
////        .onChange(of: data.statusData, perform: {value in status = converter.getStatus(data: value)})
////        }
//        }
//    }
//}
//
//struct irrigation_Previews: PreviewProvider {
//    static var previews: some View {
//        Irrigation()
//    }
//}
