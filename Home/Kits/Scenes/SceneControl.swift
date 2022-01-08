//
//  SceneControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 18.07.21.
//

import SwiftUI

struct SceneControl: View {
    var scene: SceneAutomation
    var onTap: ()  -> Void
    
    @State var editScene: SceneAutomation = SceneAutomation(id: 0, name: "All Off", lights: [Light](), blinds: [Blind](), tado: [TempDevice](), active: false, schedule: nil, room: nil, icon: "moon.fill")
//    @GestureState var press = false
    @State var edit: Bool = false
    
    func setup(){
        editScene = scene
    }
//    var longPress: some Gesture {
//        LongPressGesture(minimumDuration: 0.3)
//                .updating($press) { currentstate, gestureState, transaction in
//                    transaction.animation = Animation.easeInOut
//                    gestureState = currentstate
//                }
//                .onEnded(){_ in
//                    onLongPress()
//                }
//        }
    
    var body: some View{
        VStack{
            HStack{
                Image(systemName: SceneKit().sceneIcons.first(where: {$0.id == scene.icon})?.id ?? "")
                    .font(.title)
                    .foregroundColor(SceneKit().sceneIcons.first(where: {$0.id == scene.icon})?.color ?? .indigo)
                    .padding(.trailing, 10)
                VStack(alignment: .leading){
                    Text(scene.name)
                        .foregroundColor(.primary)
                        .bold()
                    if SceneKit().getRunTimeToday(scene: scene) != ""{
                        Text(SceneKit().getRunTimeToday(scene: scene))
                            .foregroundColor(.secondary)
                            .font(.callout)
                    }
                }
                Spacer()
            }.padding()
            
        }
//        .background(Color("fill"))
        .background(.thinMaterial)
        .cornerRadius(18)
        .foregroundColor(.primary)
        .aspectRatio(3.3, contentMode: .fit)
        
        .simultaneousGesture(
            TapGesture().onEnded({_ in onTap()})
        )
//        .scaleEffect(press ? 0.8 : 1)
//        .animation(.easeInOut, value: press)
        .sheet(isPresented: $edit){
            SceneEditScene(active: $edit, scene: $editScene)
        }
        .onAppear(perform: setup)
//        .contextMenu(menuItems: {
//            Button(action: {edit.toggle()}){Text("Edit")}
//        })
        
    }
//    var main: some View{
//        VStack{
//            HStack{
//                Spacer()
//            }
//            Image(systemName: icon)
//                .font(.title)
//                .foregroundColor(.white)
//                .padding()
//                .background(color)
//                .clipShape(Circle())
//                .padding()
//            Text(title)
//                .foregroundColor(.black)
//                .bold()
//                .padding([.bottom])
////            Text(description)
////                .foregroundColor(.gray)
////                .font(.caption)
////                .padding()
////                .padding()
////            Spacer()
//        }.padding([.leading, .trailing, .bottom])
////        .padding(10)
////        .padding()
//        
//        .background(Color.white)
//        .cornerRadius(18)
//        
////        .simultaneousGesture(longPress.sequenced(before: TapGesture()))
//        .simultaneousGesture(
//            TapGesture().onEnded({_ in onTap()})
//        )
//        .scaleEffect(press ? 0.8 : 1)
//        .animation(.easeInOut, value: press)
//        
//    }
}

//struct SceneControl_Previews: PreviewProvider {
//    static var previews: some View {
//        SceneControl()
//    }
//}
