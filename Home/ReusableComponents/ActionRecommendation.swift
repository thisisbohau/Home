//
//  ActionRecommendation.swift
//  Home
//
//  Created by David Bohaumilitzky on 04.01.22.
//

import SwiftUI

struct ActionRecommendation: View {
    var icon: AnyView
    var title: String
    var caption: String
    var actionPrompt: String
    var action: () -> Void
    
    var body: some View {
        HStack{
            VStack{
               icon
            }
            VStack(alignment: .leading){
                Text(title)
                    .font(.headline.bold())
                Text(caption)
                    .foregroundStyle(Color("secondary"))
                    .font(.caption)
            }
            .padding(.leading)
            Spacer()
            Button(action: action){
                Text(actionPrompt)
            }
            .padding(.trailing)
        }
        .padding()
        .background(Color("fill"))
        .cornerRadius(15)
    }
}

struct ActionRecommendation_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            
            HStack{
                Spacer()
            }
            Spacer()
            ActionRecommendation(icon: AnyView(Text("hi")), title: "hi", caption: "hi too", actionPrompt: "set", action: {
                print("tapped")
            })
                .padding()
            Spacer()
        }
        .background(Color("background"))
    }
}
