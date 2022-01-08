//
//  LeaveStart.swift
//  Home
//
//  Created by David Bohaumilitzky on 22.07.21.
//

import SwiftUI

extension String {
func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
  let _font = font ?? UIFont.systemFont(ofSize: 14, weight: .regular)
  let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font])
  let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: _font.pointSize)]
  let range = (self as NSString).range(of: text)
  fullString.addAttributes(boldFontAttribute, range: range)
  return fullString
}}

struct LeaveStart: View {
    @State var enableDogMode: Bool = true
    @State var enableSentry: Bool = true
    @State var getStatusUpdates: Bool = false
    
    @State var page: Int = 0
    
    func summary(){
        if enableDogMode{
            SwitchKit().set(id: 22955, newValue: true)
        }
        if getStatusUpdates{
            SwitchKit().set(id: 12837, newValue: true)
        }
        
    }
    var body: some View{
//        LeaveSentry(page: $page, useSentry: enableSentry)
        switch page{
        case 0:
            main
        case 1:
            LeaveTurnOffLights(page: $page)
        case 2:
            LeaveSentry(page: $page, useSentry: enableSentry)
        case 3:
            LeaveSummary(dogMode: enableDogMode, sentry: enableSentry, summary: getStatusUpdates)

        default:
            main
        }
    }
    
    var systemSummary: some View{
        GeometryReader{proxy in
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    Button(action: {enableSentry.toggle()}){
                        HStack{
                            Spacer()
                            VStack{
                                Image("sentry")
                                    .font(.system(size: 45))
                                    .symbolRenderingMode(enableSentry ? .multicolor : .monochrome)
                                    .foregroundColor(enableSentry ? .clear : .secondary)
                                    .padding(10)
                                Spacer()
                                Text("Sentry")
                                    .font(.title.bold())
                                    .foregroundStyle(.secondary)
                                Text("Intelligent Defence")
                                    .multilineTextAlignment(.center)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom)
                            }
                            Spacer()
                        }
                        .padding([.top, .bottom])
                        .frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 2.1, iPadSize: 3)*0.93, height: proxy.size.width/sizeOptimizer(iPhoneSize: 2.1, iPadSize: 3)*0.97)
    //                    .aspectRatio(sizeOptimizer(iPhoneSize: 0.9, iPadSize: 1.8), contentMode: .fit)
                        .background(Color("fill"))
                        .cornerRadius(22)
                        .padding(10)
                        
                        .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color("secondaryFill"), lineWidth: enableSentry ? 5 : 0)
                            )
                        .padding(10)
    //                    .cornerRadius(22)
                    }
                    
                    Button(action: {enableDogMode.toggle()}){
                        HStack{
                            Spacer()
                            VStack{
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(enableDogMode ? .orange : .secondary)
                                    .padding(10)
                                Spacer()
                                Text("Dog Mode")
                                    .font(.title.bold())
                                    .foregroundStyle(.secondary)
                                Text("Comfort lighting")
                                    .multilineTextAlignment(.center)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom)
                            }
                            Spacer()
                        }
                        .padding([.top, .bottom])
                        .frame(width: proxy.size.width/sizeOptimizer(iPhoneSize: 2.1, iPadSize: 3)*0.93, height: proxy.size.width/sizeOptimizer(iPhoneSize: 2.1, iPadSize: 3)*0.97)
                        .background(Color("fill"))
                        .cornerRadius(22)
                        .padding(10)
                        
                        .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color("secondaryFill"), lineWidth: enableDogMode ? 5 : 0)
                            )
                        .padding(10)
                    }
                    Spacer()
                }.foregroundStyle(.primary)
            }
        }
    }
    var main: some View{
        VStack(alignment: .leading){
            HStack{
                VStack(alignment: .leading){
                    Text("Ready to leave?")
                        .font(.largeTitle.bold())
                        .padding(.trailing)
                    Text("All lights will be turned off automatically.")
                        .foregroundStyle(.secondary)
                }
            }.padding(.top)
            Spacer()
//            Text("Requested Systems")
//                .font(.title.bold())
            
            systemSummary
                .padding(.top)
            
            Spacer()
            Button(action: {page += 1; summary()}){
                HStack{
                    Spacer()
                    Text("Continue")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color("fill")))

        }.padding()
        .background(Color("background"))
    }
    var main2: some View {
        VStack{
            HStack{
                Spacer()
                Text("Leave Home")
                    .font(.largeTitle.bold())
                Spacer()
            }.padding()
            Form{
                Toggle("Dog Mode", isOn: $enableDogMode)
                Toggle("Sentry Mode", isOn: $enableSentry)
                Toggle("Receive Status Updates", isOn: $getStatusUpdates)
                
                Section{
                    Text("\("Dog Mode: ".withBoldText(text: "Dog Mode:"))Home will insure that a minimum amount of light is always available during your leave\n\n\("Sentry Mode: ".withBoldText(text: "Sentry Mode:")) Sentry Mode uses a set of motion sensors to detect possible incidents\n\n\("Status Updates: ".withBoldText(text: "Status Updates:")) When enabled Home will send a status summary every 30min.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            Spacer()
            Button(action: {page += 1; summary()}){
                HStack{
                    Spacer()
                    Text("Continue")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.teal))

        }.padding()
    }
}

struct LeaveStart_Previews: PreviewProvider {
    static var previews: some View {
        LeaveStart()
    }
}
