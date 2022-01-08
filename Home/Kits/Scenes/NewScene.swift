//
//  NewScene.swift
//  Home
//
//  Created by David Bohaumilitzky on 01.07.21.
//

import SwiftUI

struct NewScene: View {
    @Binding var active: Bool
    @EnvironmentObject var updater: UpdateManager
    @State var step: Int = 1
    @State var title: String = "Select Accessories"
    
    @State var rooms: [Room] = [Room]()
    @State var scene: SceneAutomation = SceneAutomation(id: 0, name: "", lights: [], blinds: [], tado: [], active: false, schedule: [], room: nil, icon: nil)
    
    @State var editLight: Bool = false
    @State var selectedLight: Light = Light(id: "", name: "", isHue: false, isDimmable: false, reachable: false, type: "", hue: 0, saturation: 0, brightness: 0, state: false)
    
    func updateSteps(){
        switch step{
        case 1:
            title = "Select Accessories"
        case 2:
            title = "Edit Accessories"
        case 3:
            title = "Schedule"
        case 4:
            title = "Summary"
        case 5:
            active = false
        default:
            title = ""
        }
    }
    
    var main: some View{
        ZStack{
            Color("background")
                .ignoresSafeArea()
            
                VStack{
                    switch step{
                    case 1:
                        ScrollView{
                            SceneSelectAccessories(scene: $scene, step: $step)
                                .padding()
                        }
                    case 2:
                        ScrollView{
                            SceneEditAccessories(scene: $scene, step: $step)
                                .padding()
                        }
                    case 3:
                        ScrollView{
                            SceneSchedule(scene: $scene, step: $step)
                        }
                    case 4:
                        ScrollView{
                            SceneCreate(scene: $scene, step: $step)
                        }
                    default:
                        SceneSelectAccessories(scene: $scene, step: $step)
                    }
                }
            if step != 4{
                VStack{
                    Spacer()
                    Button(action: {step += 1}){
                        HStack{
                            Spacer()
                            Text("Next")
                            Spacer()
                        }
                        
                    }.buttonStyle(RectangleButtonStyle(color: Color.accentColor))
                }.padding(10)
            }
        }
        
    }

    var body: some View {
        NavigationView{
            main
                .navigationTitle(title)
                .onChange(of: step, perform: {_ in updateSteps()})
                .animation(.easeInOut, value: step)
                .navigationBarItems(leading: HStack{
                    if step != 1{
                        Button(action: {step -= 1}){Text("Back")}
                    }
                }, trailing: Button(action: {active = false}){Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)})
        }
//        .sheet(isPresented: $editLight){
//            SceneLightControl(scene: $scene, light: $selectedLight)
//        }
    }
}

//struct NewScene_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScene()
//    }
//}
