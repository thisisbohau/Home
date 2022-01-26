//
//  DishwasherActive.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.01.22.
//

import SwiftUI

struct DishwasherStatus: View {
    @EnvironmentObject var updater: UpdateManager
    @State var proxy: CGSize = CGSize(width: 0, height: 0)
    @State var animate: Bool = false
    @State var programSelector: Bool = false
    
    func getFinishTime() -> String{
        let end = Calendar.current.date(byAdding: .second, value: updater.status.dishwasher.timeRemaining, to: Date())
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: end ?? Date())
    }
    func getTime() -> String{
        let time = secondsToHoursMinutesSeconds(seconds: updater.status.dishwasher.timeRemaining)
        
        
        if time.0 != 0{
            return "\(time.0)h \(time.1)min"
        }else{
            return "\(time.1)min"
        }
    }
    
    func getDuration() -> Int{
        let duration = SystemUtility().secondsBetweenDates(start: Date(timeIntervalSince1970: Double(updater.status.dishwasher.startTime) ?? 0), end: Date())
        return duration + updater.status.dishwasher.timeRemaining
        
    }
    func togglePower(){
        DishwasherKit().togglePower()
    }
    var finishedControl: some View{
        VStack{
            Spacer()
            Button(action: {}){
                Circle()
                    .foregroundColor(Color("fill"))
                    .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                    .overlay(
                        VStack{
                            Image(systemName: "checkmark")
                                .font(.system(size: 80))
                            Text("DONE")
                                .font(.largeTitle.bold())
                                .padding()
                        }
                            .foregroundColor(.primary)
                    )
                    .shadow(color: .teal, radius: 10)
            }
            Spacer()
            Text("Cycle complete. Empty dishwasher to continue.")
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding()
        }
    }
    var activeControl: some View{
        VStack{
            Spacer()
            
            SmartCircleGauge(currentInterval: updater.status.dishwasher.timeRemaining, initialInterval: getDuration(), accentColor: Color("secondaryFill"), secondaryColor: Color("fill"), stroke: 33)
                .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                .overlay(
                    VStack{
                        Text(getTime())
                            .font(.largeTitle.bold())
                        Text("Completes at \(getFinishTime())")
                            .foregroundStyle(.secondary)
                    }
                )
                .background(
                    ZStack{
                        Circle()
                            .trim(from: 0.3, to: 0.6)
                            .foregroundColor(.teal)
                            .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .foregroundColor(.teal)
                            .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                    }.rotationEffect(Angle(degrees: animate ? 0 : 360))
                        .blur(radius: 30)
                    
                )
            Spacer()
        }
    }
    var readyControl: some View {
        VStack{
            Spacer()
            Button(action: {programSelector.toggle()}){
                Circle()
                    .foregroundColor(Color("fill"))
                    .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                    .overlay(
                        VStack{
                            Image(systemName: "play.fill")
                                .font(.system(size: 80))
                            Text("START")
                                .font(.largeTitle.bold())
                                .padding()
                        }
                            .foregroundColor(updater.status.dishwasher.doorState ? .secondary : .primary)
                    )
                    .shadow(color: .teal, radius: animate ? 20 : 10)
                    
            }.disabled(updater.status.dishwasher.doorState)
            Spacer()
            if updater.status.dishwasher.doorState{
            HStack{
                Image(systemName: "exclamationmark.circle")
                Text("Door Open")
                
            }.foregroundColor(.orange)
                .font(.body.bold())
        }
            Spacer()
            Text("You can start a cleaning cycle right from the app.")
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding()
        }
    }
    var offControl: some View{
        VStack{
            Spacer()
            Button(action: togglePower){
                Circle()
                    .foregroundColor(Color("fill"))
                    .frame(width: proxy.width*0.7, height: proxy.width*0.7)
                    .overlay(
                        VStack{
                            Image(systemName: "power")
                                .font(.system(size: 80))
                            Text("OFF")
                                .font(.largeTitle.bold())
                                .padding()
                        }
                            .foregroundColor(.primary)
                    )
                    .shadow(radius: 8)
            }
            Spacer()
            Text("The dishwasher is off. To start tap the button above")
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding()
        }
    }
    
    var body: some View{
        VStack{
            if programSelector{
                DishwasherProgramSelector()
            }else{
                main
            }
        }
    }
    var main: some View {
        GeometryReader{proxy in
            Color("background").ignoresSafeArea()
        VStack{
            HStack{
                VStack{
                   Image(systemName: "")
                }
                
                VStack(alignment: .leading){
                    Text("Dishwasher")
                        .font(.title.bold())
                    HStack{
                        if DishwasherKit().getOperationState(status: updater.status.dishwasher.operationState) == .Running{
                            Text("\(updater.status.dishwasher.availablePrograms.first(where: {$0.id == updater.status.dishwasher.activeProgram})?.name ?? "") \(updater.status.dishwasher.programProgress)%")
                            
                        }else{
                            Text("\(DishwasherKit().getOperationStateVerbos(status: DishwasherKit().getOperationState(status: updater.status.dishwasher.operationState)))")
                        }
                        
                        Text(" | ")
                        Image(systemName: "bolt.fill")
                            .foregroundColor(updater.status.dishwasher.power ? .teal : .secondary)
                        Text("\(updater.status.dishwasher.power ? "On" : "Off")")
                    }.foregroundStyle(.secondary)
                }
                Spacer()
            }.padding()
            
            if !updater.status.dishwasher.power{
                offControl
            }else{
                switch DishwasherKit().getOperationState(status: updater.status.dishwasher.operationState){
                case .Running:
                    activeControl
                case .Ready:
                    readyControl
                case .Waiting:
                    readyControl
                case .On:
                    readyControl
                case .Finished:
                    finishedControl
                default:
                    offControl
                }
            }
        }
        .onAppear(perform: {
            DispatchQueue.main.async {
                withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 0.7, damping: 0.8, initialVelocity: 1).repeatForever(autoreverses: true)){
                    animate.toggle()
                }
            }
            
        })
        .onAppear(perform: {
            self.proxy = proxy.size
        })
            
        }
    }
}

struct DishwasherActive_Previews: PreviewProvider {
    static var previews: some View {
        DishwasherStatus()
    }
}
