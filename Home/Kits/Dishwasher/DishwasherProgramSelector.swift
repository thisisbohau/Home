//
//  DishwasherProgramSelector.swift
//  Home
//
//  Created by David Bohaumilitzky on 17.01.22.
//

import SwiftUI

struct DishwasherProgramSelector: View {
    @EnvironmentObject var updater: UpdateManager
    @State var loading: Bool = false
    
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
    
    func selectProgram(program: DishwasherProgram){
        loading = true
        DishwasherKit().selectProgram(program: program)
    }
    
    func selectOption(option: DishwasherOption){
        
        DishwasherKit().selectOption(option: option, newState: !option.state)
    }
    
    
    var body: some View {
        ScrollView{
            HStack{
                Spacer()
                Text("Select Program")
                    .font(.largeTitle.bold())
                Spacer()
            }
            .padding(.top)
            HStack{
                if loading{
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.trailing, 10)
                    Text("Updating run time...")
                        .foregroundStyle(.secondary)
                }else{
                    VStack{
                        Text(getTime())
                            .font(.system(size: 50).bold())
                        Text("Completes at \(getFinishTime())")
                            .foregroundStyle(.secondary)
                    }
                    
                }
                
            }.padding()
            ForEach(updater.status.dishwasher.availablePrograms){program in
                Button(action: {
                    selectProgram(program: program)
                }){
                    HStack{
                        Text(program.name)
                            .bold()
                            .padding()
                        Spacer()
                    }
                    .foregroundColor(updater.status.dishwasher.activeProgram == program.id ? .primary : .secondary)
                    .background(Color(updater.status.dishwasher.activeProgram == program.id ? "secondaryFill" : "fill"))
                    .cornerRadius(15)
                }
            }
            
            HStack{
                Text("Options")
                    .font(.title.bold())
                Spacer()
            }
            ForEach(updater.status.dishwasher.availableOptions){option in
                Button(action: {
                    selectOption(option: option)
                }){
                    
                    HStack{
                        Image(systemName: option.state ? "circle.fill" : "circle")
                            
                        Text(option.name)
                            .bold()
                            .padding()
                        Spacer()
                    }
                    .foregroundColor(option.available ? .primary : .secondary)
                    .foregroundStyle(option.state ? .primary : .secondary)
                    .padding(10)
    //                .foregroundColor(updater.status.dishwasher.availableOptions == option.id ? .primary : .secondary)
    //                .background(Color(updater.status.dishwasher.activeProgram == option.id ? "secondaryFill" : "fill"))
                    .cornerRadius(15)
                }.disabled(!option.available)
            }
            
            Spacer()
        }
        .padding()
        .background(Color("background").ignoresSafeArea())
        .onChange(of: updater.status.dishwasher.timeRemaining, perform: {_ in loading = false})
        

        
    }
}

struct DishwasherProgramSelector_Previews: PreviewProvider {
    static var previews: some View {
        DishwasherProgramSelector()
    }
}
