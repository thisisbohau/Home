//
//  MowingAnimation.swift
//  Home
//
//  Created by David Bohaumilitzky on 10.07.21.
//

import SwiftUI

struct MowingAnimation: View {
    var gras: some View{
        HStack{
            ForEach(1...100, id: \.self){_ in
                Rectangle()
                    .frame(width: 5, height: 50)
                    .foregroundColor(.pink)
                    .padding(5)
            }
        }
    }
    var body: some View {
        GeometryReader{proxy in
            HStack{
                ForEach(1...Int((proxy.size.width*0.5)/10), id: \.self){_ in
                    Rectangle()
                        .frame(width: 5, height: 50)
                        .foregroundColor(.pink)
                        .padding(2)
                }
            }
        }
//        gras
    }
}

struct MowingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        MowingAnimation()
    }
}
