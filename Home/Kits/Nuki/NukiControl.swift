//
//  NukiControl.swift
//  Home
//
//  Created by David Bohaumilitzky on 09.07.21.
//

import SwiftUI

extension View {
    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

struct NukiControl: View {
    @EnvironmentObject var updater: UpdateManager
    @State var calcStatus: Nuki = Nuki(id: 0, state: false, battery: 0, door: 0)
    @State var setState: Bool = false
    
    @State var waitingForUpdate: Bool = true
    @State var setupComplete: Bool = false
    
    @State var toggleWarning: Bool = false
    @State var animate: CGFloat = 1
    @State var animateUnlatch: Bool = false
    @State var animateColor: Color = .orange
    
    @State var viewSize: CGSize = CGSize(width: 100, height: 100)
    
    func setup(){
        calcStatus = updater.status.nuki
        setState = calcStatus.state
        
        //set for future animation
        if calcStatus.state{
            animate = 0
            animateColor = .orange
        }else{
            animate = 1
            animateColor = .secondary
        }
        
        setupComplete = true
        waitingForUpdate = false
    }
    
    func updateTerminator(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
            if waitingForUpdate{
                print("NUKI: Server took too long to respond. Update aborted")
                calcStatus = updater.status.nuki
                setState = calcStatus.state
                waitingForUpdate = false
            }
        })
    }
    
    func toggleLock(){
        waitingForUpdate = true
        calcStatus.state = setState
        NukiKit().toggleLock(lock: updater.status.nuki, newState: setState)
        updateTerminator()
    }
    
    func lockNGo(){
        waitingForUpdate = true
        calcStatus.state = true
        NukiKit().lockNGo(lock: updater.status.nuki)
        updateTerminator()
    }
    func overrideAction(state: Bool){
        NukiKit().toggleLock(lock: updater.status.nuki, newState: state)
    }
    func update(){
        if setupComplete{
            let newState = updater.status.nuki
            
            if waitingForUpdate{
                if setState == newState.state{
                    calcStatus = newState
                    waitingForUpdate = false
                    print("nuki edit successful\(newState)")
                }
            }else{
                calcStatus = newState
                setState = newState.state
            }
        }
    }
    
    func animateWithState(state: Bool){
        if state{
            animate = 0
            animateColor = .orange
        }else{
            animate = 1
            animateColor = .secondary
        }
        withAnimation(.linear, {
            if animate == 0{
                animate = 1
            }else{
                animate = 0
            }
        })
    }
//    func toggleLock(newState: Bool){
//        withAnimation(.linear, {
//            if newState != state{
//                delay = true
//                NukiKit().toggleLock(lock: updater.status.nuki, newState: newState)
//                state = newState
//                DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
//                    delay = false
//                })
//            }
//        })
//    }
//
//    func update(){
//        if !delay{
//            state = updater.status.nuki.state
//        }
//    }
//
//    var slide: some Gesture{
//        DragGesture(minimumDistance: 10)
//            .onChanged({value in
//                if value.translation.height < 0 {
//                    // up
//                    toggleLock(newState: true)
//                }
//
//                if value.translation.height > 0 {
//                   //down
//                    toggleLock(newState: false)
//                }
//            })
//    }
    
//    var slider: some View{
//        GeometryReader{proxy in
//            VStack{
//                Spacer()
//                HStack{
//                    Spacer()
//                    ZStack{
//
//                        Rectangle()
//                            .foregroundColor(Color.gray.opacity(0.3))
//                            .frame(width: 150)
//                            .cornerRadius(36)
//
//                        if state{
//                            VStack{
//                                Rectangle()
//                                    .foregroundColor(Color.orange)
//                                    .frame(width: 150, height: proxy.size.height*0.32)
//                                    .cornerRadius(36)
//                                    .overlay(Image(systemName: "lock.open.fill").font(.largeTitle).foregroundColor(.white))
//                                Spacer()
//                            }
//                        }else{
//                            VStack{
//                                Spacer()
//                                Rectangle()
//                                    .foregroundColor(Color.gray.opacity(0.3))
//                                    .frame(width: 150, height: proxy.size.height*0.32)
//                                    .cornerRadius(36)
//                                    .overlay(Image(systemName: "lock.fill").font(.largeTitle).foregroundStyle(.secondary))
//                            }
//                        }
//                    }.frame(height: proxy.size.height*0.70)
//                        .gesture(slide)
//                    Spacer()
//                }
//                Spacer()
//            }
//        }
//    }
    
    var openDoor: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Circle()
                    .frame(width: viewSize.width/2, height: viewSize.height/2)
                    .foregroundStyle(.regularMaterial)
                    .overlay(
                        VStack{
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 55).bold())
                            Text("Unlatched")
                                .font(.title2.bold())
                                .padding(.top, 4)
                        } .foregroundColor(.primary)
                    )
                    .background(
                        ZStack{
                            Circle()
                                .foregroundColor(.orange.opacity(animateUnlatch ? 0.6 : 0.2))
                                .scaleEffect(animateUnlatch ? 0.9 : 2, anchor: .center)
                            Circle()
                                .foregroundColor(.orange.opacity(animateUnlatch ? 0.2 : 0.6))
                                .scaleEffect(animateUnlatch ? 2 : 0.9, anchor: .center)
                        }
                    )
                Spacer()
            }
            Spacer()
        }
        .onAppear(perform: {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), {
                animateUnlatch.toggle()
            })
        })
        .actionSheet(isPresented: $toggleWarning, content: {ActionSheet(title: Text("Override Lock Actions"), message: Text("The door may be unlatched. Override only in emergencies"), buttons: [.destructive(Text("Unlock")){overrideAction(state: true)}, .cancel()])})
    }
    
    var overrideActions: some View{
        HStack{
            Button(action: {toggleWarning.toggle()}){
                VStack{
                    Image(systemName: "lock.open.fill")
                        .font(.title2)
                        .padding(15)
                        .background(
                            Circle()
                                .foregroundColor(.orange)
                                
                        )
                    Text("Unlock")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.top, 10)
                }
                .foregroundColor(.primary)
            }.padding(.trailing)
            
            Button(action: {overrideAction(state: false)}){
                VStack{
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .padding(15)
                        .background(
                            Circle()
                                .foregroundColor(.secondary)
                        )
                    Text("Lock")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.top, 10)
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    var openIcon: some View{
        VStack{
            Image(systemName: "lock.open.fill")
                .font(.largeTitle)
                .foregroundStyle(.primary)
        }
    }
    var closedIcon: some View{
        VStack{
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View{
        GeometryReader{proxy in
            VStack{
                HStack{
                    VStack{
                        if calcStatus.state{
                            openIcon
                                .foregroundColor(.orange)
                        }else{
                            closedIcon
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text("Front Door")
                            .font(.title.bold())
                        HStack{
                            Text(calcStatus.state ? "Unlocked" : "Locked")
                            Text(" | ")
                            Image(systemName: "bolt.fill")
                            Text("\(calcStatus.battery)%")
                        }.foregroundStyle(.secondary)
                    }
                    Spacer()
                }.padding()
                
                Spacer()
                if updater.status.nuki.door == 2{
                    SmartToggleSwitch(active: $setState, sliderHeight: proxy.size.height*0.6, sliderWidth: 160, onColor: .orange, onIcon: AnyView(openIcon), offIcon: AnyView(closedIcon))
                    Spacer()
                    Button(action: lockNGo){
                        VStack{
                            Image(systemName: "lock.rotation")
                                .font(.title)
                                .padding(10)
                                .background(
                                    Circle()
                                        .foregroundColor(.orange)
                                        .offset(x: -1)
                                )
                            Text("Lock'n go")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .padding(.top, 10)
                        }
                        .foregroundColor(.primary)
                    }.padding()
                }else{
                    openDoor
                    Spacer()
                    overrideActions
                }
            }
            .background(
                Rectangle()
                    .ignoresSafeArea()
                    .frame(width: proxy.size.width, height: animate == 1 ? proxy.size.height : 0)
                    .foregroundColor(animateColor)
                    .overlay(.regularMaterial)
                    .opacity(animate == 1 ? 0 : 1)
            )
            .onAppear(perform: {
                setup()
                viewSize = proxy.size
            })
            .onChange(of: setState, perform: {state in
                animateWithState(state: state)
                toggleLock()
            })
            .onChange(of: updater.lastUpdated, perform: {_ in
                update()
            })
        }
    }
        
    //    var sdbody: some View {
    //        VStack{
    //            HStack{
    //                Spacer()
    //                VStack{
    //                    Text("Front Door")
    //                        .font(.title.bold())
    //                    VStack(alignment: .leading){
    //                        HStack{
    //                            Text(state ? "Unlocked" : "Locked")
    //                        }
    //                    }.foregroundStyle(.secondary)
    //                }
    //                Spacer()
    //            }.padding(.top)
    //            Spacer()
    //            HStack{
    //                Spacer()
    //                if updater.status.nuki.door == 2{
    //
    //                }else{
    //                    openDoor
    //                }
    //                Spacer()
    //            }
    //        }.padding()
    //            .onChange(of: updater.lastUpdated, perform: {value in update()})
    //            .accentColor(.orange)
    //    }
}

struct NukiControl_Previews: PreviewProvider {
    static var previews: some View {
        NukiControl()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
