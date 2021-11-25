//
//  LeaveButton.swift
//  Home
//
//  Created by David Bohaumilitzky on 25.07.21.
//

import SwiftUI

struct LeaveButton: View {
    @State var leave: Bool = false
    var body: some View {
        Button(action: {leave.toggle()}){
        HStack{
            Spacer()
            Text("Leave Home")
                .bold()
            Spacer()
        }.padding(15)
            .background(Color.accentColor)
            .cornerRadius(13)
            
            .foregroundColor(.primary)
        }.padding(10)
            .sheet(isPresented: $leave){
                LeaveStart()
            }
//            .padding()
    }
}

struct LeaveButton_Previews: PreviewProvider {
    static var previews: some View {
        LeaveButton()
    }
}
