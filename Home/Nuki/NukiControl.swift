//
//  NukiControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

struct NukiControl: View {
    @EnvironmentObject var updater: Updater
    @State var delay: Bool = false
    @State var state: Bool = false
    @State var toggleWarning: Bool = false
    
    func toggleLock(newState: Bool){
        withAnimation(.linear, {
            if newState != state{
                delay = true
                NukiKit().toggleLock(lock: updater.status.nuki, newState: newState)
                state = newState
                DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
                    delay = false
                })
            }
        })
    }
    
    func update(){
        if !delay{
            state = updater.status.nuki.state
        }
    }
    
    var slide: some Gesture{
        DragGesture(minimumDistance: 10)
            .onChanged({value in
                if value.translation.height < 0 {
                    // up
                    toggleLock(newState: true)
                }

                if value.translation.height > 0 {
                   //down
                    toggleLock(newState: false)
                }
            })
    }
    
    var slider: some View{
        GeometryReader{proxy in
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    ZStack{
                        
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(width: 150)
                            .cornerRadius(36)
                        
                        if state{
                            VStack{
                                Rectangle()
                                    .foregroundColor(Color.orange)
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image(systemName: "lock.open.fill").font(.largeTitle).foregroundColor(.white))
                                Spacer()
                            }
                        }else{
                            VStack{
                                Spacer()
                                Rectangle()
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: proxy.size.height*0.32)
                                    .cornerRadius(36)
                                    .overlay(Image(systemName: "lock.fill").font(.largeTitle).foregroundStyle(.secondary))
                            }
                        }
                    }.frame(height: proxy.size.height*0.70)
                        .gesture(slide)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    var openDoor: some View{
        VStack{
            Spacer()
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 100))
                .foregroundColor(.orange)
            Text("The door is unlatched.")
                .padding()
                .foregroundColor(.secondary)
            Button(action: {toggleWarning.toggle()}){
                Text("Toggle anyways")
                    .foregroundColor(.orange)
            }
            Spacer()
        }.actionSheet(isPresented: $toggleWarning, content: {ActionSheet(title: Text("Override actions"), message: Text("Only use when near Home"), buttons: [.default(Text("Lock")){toggleLock(newState: false)}, .destructive(Text("Unlock")){toggleLock(newState: true)}, .cancel()])})
    }
    var body: some View {
        VStack{
            HStack{
                Spacer()
                VStack{
                    Text("Front Door")
                        .font(.title.bold())
                    VStack(alignment: .leading){
                        HStack{
                            Text(state ? "Unlocked" : "Locked")
                        }
                    }.foregroundStyle(.secondary)
                }
                Spacer()
            }.padding(.top)
            Spacer()
            HStack{
                Spacer()
                if updater.status.nuki.door == 2{
                    slider
                }else{
                    openDoor
                }
                Spacer()
            }
        }.padding()
            .onChange(of: updater.lastUpdated, perform: {value in update()})
            .accentColor(.orange)
    }
}

struct NukiControl_Previews: PreviewProvider {
    static var previews: some View {
        NukiControl()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
