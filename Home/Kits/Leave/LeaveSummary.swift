//
//  LeaveSummary.swift
//  Home
//
//  Created by David Bohaumilitzky on 24.07.21.
//

import SwiftUI

struct ChecklistItem: View{
    var title: String
    var completed: Bool
    
    var body: some View{
        HStack{
            Image(systemName: completed ? "checkmark.circle" : "circle")
                .foregroundColor(completed ? Color.accentColor : Color("fill"))
            Text(title)
                .foregroundColor(completed ? Color("secondary") : Color("fill"))
            
        }.padding(5)
    }
}
struct LeaveSummary: View {
    @EnvironmentObject var updater: UpdateManager
    var dogMode: Bool
    var sentry: Bool
    var summary: Bool
    @State var analysisComplete: Bool = false
    @State var analysisCondition: String = ""
    @State var lockNGoActive: Bool = false
    
    func getLightConditions(){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "action", value: "analyze"))
            
            let response = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.lightAnalyzer, queries: queries)
            
//            let requestURL = Updater().getRequestURL(directory: directories.lightAnalyzer, queries: queries)
//            Updater().makeActionRequest(url: requestURL){response in
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                    let condition = Int(response ?? "") ?? 0
                    if condition == 1{
                        analysisCondition = "- bright"
                    }else if condition == 2{
                        analysisCondition = "- dimmed"
                    }else{
                        analysisCondition = "- dark"
                    }
                    analysisComplete = true
//                })
            })
        }
    }
    
    func lockNGo(){
        NukiKit().lockNGo(lock: updater.status.nuki)
        lockNGoActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
            lockNGoActive = false
        })
    }
    
    func checkFloor(floor: Int) -> Bool{
        let rooms = updater.status.rooms.filter({$0.floor == floor})
        let lights = rooms.flatMap({$0.lights})
        let on = lights.contains(where: {$0.state})
        return !on
    }
    func getLeftTime() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.pmSymbol = .none
        formatter.amSymbol = .none
        return formatter.string(from: Date())
    }
    
    var body: some View{
        main
            .background(Color("background"))
            .onAppear(perform: getLightConditions)
    }
    var checkList: some View{
        VStack(alignment: .leading){
            ChecklistItem(title: "Windows closed", completed: updater.status.rooms.flatMap({$0.windows}).filter({$0.state == true}).count == 0)
            ChecklistItem(title: "Upstairs lights off", completed: checkFloor(floor: 1))
            ChecklistItem(title: "Downstairs lights off", completed: checkFloor(floor: 0))
            ChecklistItem(title: "Light analysis complete \(analysisCondition)", completed: analysisComplete)
            ChecklistItem(title: "Safety Check complete", completed: true)
        }.padding(.bottom)
    }
    var systemSummary: some View{
        GeometryReader{proxy in
            HStack{
                if sentry{
                    HStack{
                        Spacer()
                        VStack{
                            Image("sentry")
                                .font(.system(size: 45))
                                .symbolRenderingMode(.multicolor)
                                .padding(10)
                            Spacer()
                            Text("Sentry")
                                .font(.title.bold())
                                .foregroundStyle(.secondary)
                            Text("STANDBY")
                                .multilineTextAlignment(.center)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.bottom)
                        }
                        Spacer()
                    }
                    .padding([.top, .bottom])
                    .frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 2, iPadSize: 3)*0.97, height: proxy.size.width/sizeOptimizer(iPhoneSize: 2, iPadSize: 3)*0.97)
                    .background(Color("fill"))
                    .cornerRadius(22)
                }
                if sentry{
                    HStack{
                        Spacer()
                        VStack{
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 45))
                                .foregroundColor(.orange)
                                .padding(10)
                            Spacer()
                            Text("Dog Mode")
                                .font(.title.bold())
                                .foregroundStyle(.secondary)
                            Text("ACTIVE")
                                .multilineTextAlignment(.center)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.bottom)
                        }
                        Spacer()
                    }
                    .padding([.top, .bottom])
                    .frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 2, iPadSize: 3)*0.97, height: proxy.size.width/sizeOptimizer(iPhoneSize: 2, iPadSize: 3)*0.97)
                    .background(Color("fill"))
                    .cornerRadius(22)
                }
                Spacer()
            }
        }
    }
    var main: some View{
        VStack(alignment: .leading){
            HStack{
                VStack(alignment: .leading){
                    Text("Take care and stay safe")
                        .font(.largeTitle.bold())
                        .padding(.trailing)
                    Text("Home will take over control when you leave.")
                        .foregroundStyle(.secondary)
                }
            }.padding(.top)
            Spacer()
//            Text("Requested Systems")
//                .font(.title.bold())
                
            systemSummary
                .padding(.top)
                checkList
            Spacer()
            Button(action: lockNGo){
                HStack{
                    Spacer()
                    Label("Lock'n go?", systemImage: "lock.fill")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyleAnimate(color: Color("fill"), animateTo: $lockNGoActive))

        }.padding()
    }
    var scratch: some View {
        VStack{
            HStack{
                Spacer()
                Text("Take care")
                    .font(.largeTitle.bold())
                Spacer()
            }.padding()
            Spacer()
            VStack(alignment: .leading){
                Text("Requested Systems")
                    .font(.title2.bold())
                if dogMode{
                    HStack{
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                        Text("Dog Mode")
                            .bold()
                    }
                }
                if sentry{
                    HStack{
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                        Text("Sentry Mode")
                            .bold()
                    }
                }
                if summary{
                    HStack{
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                        Text("Status Summary")
                            .bold()
                    }
                }
                Spacer()
                HStack{
                    Spacer()
                    VStack{
                        Text("Home left at")
                            .foregroundColor(.secondary)
                        
                        Text(getLeftTime())
                            .font(.system(size: 75).bold())
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    Spacer()
                }
               
                Spacer()
                if sentry{
                    Text("Sentry will activate automatically when you leave Home. Important notifications will always be sent to your devices. ")
                        .foregroundColor(.secondary)
                }
            }.padding()
 
            Spacer()
            Button(action: {}){
                HStack{
                    Spacer()
                    Text("Lock and go?")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.orange))

        }.padding()
    }
}

struct LeaveSummary_Previews: PreviewProvider {
    static var previews: some View {
        LeaveSummary(dogMode: true, sentry: true, summary: false)
    }
}
