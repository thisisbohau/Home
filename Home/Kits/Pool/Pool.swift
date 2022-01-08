//
//  Pool.swift
//  Home
//
//  Created by David Bohaumilitzky on 29.06.21.
//

import SwiftUI

class PoolKit{
    enum ValueType: String{
        case pH = "pH"
        case sanatizer = "sanatizer"
        case temp = "temp"
    }
 
    func checkValue(type: ValueType, value: Float) -> Bool{
        switch type{
        case .pH:
            let pHRange = 6.8...7.6
            return pHRange.contains(Double(value)) ? true : false
        case .sanatizer:
            let sanatizerRange = 500.0...800.0
            return sanatizerRange.contains(Double(value)) ? true : false
        case .temp:
            let tempRange = 23.5...30.5
            return tempRange.contains(Double(value)) ? true : false
            
        }
    }
    func getValueStatusIcon(value: Float, type: ValueType) -> String{
        return checkValue(type: type, value: value) ? "checkmark.circle" : "exclamationmark.circle"
    }
    
    func getPoolStatus(pool: Pool) -> Int{
        var okCount: Int = 0
        if checkValue(type: .temp, value: pool.temp){
            okCount += 1
        }
        if checkValue(type: .pH, value: pool.pH){
            okCount += 1
        }
        if checkValue(type: .sanatizer, value: pool.aCl){
            okCount += 1
        }
        if okCount >= 3{
            return 1
        }else if okCount == 2{
            return 2
        }else{
            return 3
        }
    }
}
struct StatusCircle: View{
    var color: Color
    var size: CGFloat
    
    var body: some View{
        Circle()
            .foregroundColor(color)
            .blur(radius: size/3.5)
            .frame(width: size, height: size)
    }
}
struct PoolOverview: View {
    @EnvironmentObject var pool: UpdateManager
    @State var statusColor: Color = .teal
    @State var statusLabel: String = ""
    
    func update(){
        let status = PoolKit().getPoolStatus(pool: pool.status.pool)
        if status == 1{
            statusColor = .teal
            statusLabel = "All looks good"
        }else if status == 2{
            statusColor = .orange
            statusLabel = "Take a look"
        }else{
            statusColor = .pink
            statusLabel = "Attention required"
        }
    }
    var valueList: some View{
        VStack(alignment: .leading){
            Text("Temperature")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            HStack{
                Text("\(String(format: "%.1f", pool.status.pool.temp))°")
                    .foregroundStyle(.secondary)
                Image(systemName: PoolKit().getValueStatusIcon(value: pool.status.pool.temp, type: PoolKit.ValueType.temp))
                    .foregroundColor(PoolKit().checkValue(type: PoolKit.ValueType.temp, value: pool.status.pool.temp) ? .green : .orange)
            }.padding(.bottom, 5)
            
            Text("pH level")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            HStack{
                Text("\(String(format: "%.1f", pool.status.pool.pH))")
                    .foregroundStyle(.secondary)
                Image(systemName: PoolKit().getValueStatusIcon(value: pool.status.pool.pH, type: PoolKit.ValueType.pH))
                    .foregroundColor(PoolKit().checkValue(type: PoolKit.ValueType.pH, value: pool.status.pool.pH) ? .green : .orange)
            }.padding(.bottom, 5)
                
            Text("Sanatizer")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            HStack{
                Text("\(String(format: "%.1f", pool.status.pool.aCl))")
                    .foregroundStyle(.secondary)
                Image(systemName: PoolKit().getValueStatusIcon(value: pool.status.pool.aCl, type: PoolKit.ValueType.sanatizer))
                    .foregroundColor(PoolKit().checkValue(type: PoolKit.ValueType.sanatizer, value: pool.status.pool.aCl) ? .green : .orange)
            }.padding(.bottom, 5)
            
            
        }
    }

    var body: some View {
        VStack(alignment: .leading){
            ZStack{
                HStack{
                    VStack(alignment: .leading){
                        Text(statusLabel)
                            .font(.title.bold())
                        if pool.status.pool.pumpActive{
                            Text("Pump on")
                                .foregroundStyle(.secondary)
                        }
                        valueList
                            .padding(.top, 10)
                            
                    }
                    Spacer()
                }
                HStack{
                    Spacer()
                    StatusCircle(color: statusColor, size: sizeOptimizer(iPhoneSize: 50, iPadSize: 80))
                        .padding()
                        .padding(.trailing, sizeOptimizer(iPhoneSize: 30, iPadSize: 40))
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(13)
        .padding([.leading, .trailing])
        .onAppear(perform: update)
        .onChange(of: pool.lastUpdated, perform: {value in update()})
            
    }
}

struct Pool_Previews: PreviewProvider {
    static var previews: some View {
        PoolOverview()
    }
}
