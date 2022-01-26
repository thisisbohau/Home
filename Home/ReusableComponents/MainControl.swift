//
//  MainControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 21.09.21.
//

import SwiftUI

struct MainControl: View {
    var icon: AnyView
    var title: String
    var caption: String
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                icon
            }
            Spacer()
            Text(title)
                .font(.title3.bold())
            Text(caption)
                .font(.callout)
                .foregroundColor(Color("secondary"))
//                .padding(.bottom, 10)
        }
        .aspectRatio(1.2, contentMode: .fit)
        .frame(width: 130)
        
        .foregroundColor(Color("primary"))
        .padding()
        .background(Color("fill"))
        .cornerRadius(16)
    }
}

struct MainControl_Previews: PreviewProvider {
    static var previews: some View {
        MainControl(icon: AnyView(Image(systemName: "checkmark").font(.title2.bold())), title: "Title", caption: "Caption")
    }
}
