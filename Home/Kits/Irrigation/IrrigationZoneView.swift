//
//  IrrigationZoneView.swift
//  Home
//
//  Created by David Bohaumilitzky on 07.05.21.
//

import SwiftUI

struct IrrigationZoneView: View {
    @Binding var active: Bool
    @Binding var zone: irrigationZone
    @State var unableToAuthenticate: Bool = false
    
    @State var time: Int = 0
    
    func manualTrigger(){
//        Biometrics().authenticate(){state in
//            if state{
                IrrigationKit().startManualIrrigation(zone: zone, time: time*60)
                active = false
//            }else{
//                unableToAuthenticate = true
//            }
//        }
    }
    
    var body: some View {
        GeometryReader{proxy in
        NavigationView{
            VStack{
//                Form{
//                    Section(header: Text("Manual Mode")){
//                        Picker("Irrigation time:", selection: $time) {
//                            ForEach(0 ..< 61) {
//                                if $0 != 0{
//                                    Text("\($0) minutes")
//                                }
//                            }
//                        }
//                    }
//                }
                Spacer()
                CircularSlider(max: 80, size: proxy.size.width*0.7, value: $time)
                    .overlay(
                        Text("\(time) min")
                            .font(.title.bold())
                            .animation(.linear, value: time)
                    )
                   
                Spacer()
                Text("After the timer is complete the system will return to the previous operation mode. Schedules and safeties are not affected")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                    .foregroundColor(.secondary)
                
                Button(action: manualTrigger){
                    HStack{
                        Spacer()
                        Text("Start Irrigation")
                            .font(.body.bold())
                        Spacer()
                    }
                }
                .buttonStyle(RectangleButtonStyle(color: Color.accentColor))
                .padding()
            }.navigationTitle(zone.name)
            .alert(isPresented: $unableToAuthenticate){
                Alert(title: Text("Access denied"), message: Text("We were unable to authenticate you."), dismissButton: .cancel())
            }
        }
        }
    }
}

//struct IrrigationZoneView_Previews: PreviewProvider {
//    static var previews: some View {
//        IrrigationZoneView()
//    }
//}
