//
//  WakeUpSettings.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.09.21.
//

import SwiftUI

struct WakeUpSettings: View {
    @Binding var active: Bool
    @ObservedObject var locationServices = LocationService()
    @EnvironmentObject var updater: UpdateManager
    @State var wakeUpTime: Date = Date()
    @State var arrivalTime: Date = Date()
    @State var showNewDestination: Bool = false
    @State var destination: LocationDestination = LocationDestination(id: 0, name: "", latitude: 0, longitude: 0)
    
    func getArrivalTime() -> String{
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return MorningKit().dateToString(date: arrivalTime)
    } 
    func setup(){
//        print(updater.status.morning)
        wakeUpTime = MorningKit().stringToDate(date: updater.status.morning.wakeUpTime)
        arrivalTime = MorningKit().stringToDate(date: updater.status.morning.arrivalTime)
    }
    
    func set(){
        Task{
        let _ = await MorningKit().setRoutine(destination: destination, arrivalTime: arrivalTime, wakeUpTime: wakeUpTime)
        active = false
        }
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                HStack{
                    Text(
                        "You will arrive at \(updater.status.morning.destinations.first(where: {$0.id == destination.id})?.name ?? "") at \(MorningKit().formatDate(date: arrivalTime)).")
                        .foregroundStyle(.secondary)
                    Spacer()
                }.padding(.leading)
                List{
                    Section{
                        VStack{
                            Text("When do you wake up?")
                                .font(.title.bold())
                            DatePicker("Wake Up at:", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        }.padding()
                    }
                    
                    Section{
                        VStack{
                            Text("When do you want to arrive?")
                                .font(.title.bold())
                            DatePicker("Arrive at:", selection: $arrivalTime, displayedComponents: .hourAndMinute)
                        }.padding()
                    }
                    
                    Section(header: Text("Destination")){
                        ForEach(updater.status.morning.destinations){destination in
                            Button(action: {
                                self.destination = destination
                            }){
                                VStack(alignment: .leading){
                                    Text(destination.name)
                                }.padding(10)
                            }
                        }
                        Button(action: {showNewDestination.toggle()}){
                            Text("Add new Destination")
                        }
                    }
                }
                
            }
            .sheet(isPresented: $showNewDestination){
                AddDestination(locationService: locationServices)
            }
            .navigationBarItems(trailing:
                Button(action: set){
                    Text("Set")
            }.disabled(destination.id == 0)
            )
            .navigationBarItems(leading: Text("Destination: \(updater.status.morning.destinations.first(where: {$0.id == destination.id})?.name ?? "")"))
            .navigationTitle("Morning Commute")
            .onAppear(perform: setup)
        }
    }
}

//struct WakeUpSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        WakeUpSettings()
//    }
//}
