//
//  SceneOverview.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.07.21.
//

import SwiftUI

struct SceneOverview: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var sceneKit: SceneKit
    
    func setScene(scene: SceneAutomation){
        sceneKit.setScene(scene: scene)
    }
    
    var body: some View {
        if !SceneKit().getScheduledScenes(scenes: updater.status.scenes).isEmpty{
            VStack(alignment: .leading){
                Text("Automations")
                    .font(.title.bold())
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(SceneKit().getScheduledScenes(scenes: updater.status.scenes)){scene in
                            SceneControl(scene: scene, onTap: {setScene(scene: scene)})
    //                        QuickActionControl(title: scene.name, description: "", icon: scene.icon ?? "heart.fill", color: .indigo, onLongPress: {}, onTap: {setScene(scene: scene)}, time: SceneKit().getRunTimeToday(scene: scene) ?? "")
                                .shadow(radius: 3)
                                .padding(3)
                                .padding(.trailing, 5)
                        }
                    }
                }
            }
            .padding()
            .cornerRadius(13)
        }
    }
}

struct SceneOverview_Previews: PreviewProvider {
    static var previews: some View {
        SceneOverview()
    }
}
