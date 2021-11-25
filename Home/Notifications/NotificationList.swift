//
//  NotificationList.swift
//  Home
//
//  Created by David Bohaumilitzky on 18.07.21.
//

import SwiftUI


struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        self.present(toPresent, animated: true, completion: nil)
    }
}

struct NotificationList: View {
    @EnvironmentObject var updater: Updater
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Notifications")
                    .font(.title2.bold())
                    .padding(.top)
                Spacer()
            }
                
            ScrollView{
                ForEach(updater.status.notifications){message in
                    if message.priority{

                        HStack{
                            Image(systemName: message.icon)
                                .foregroundStyle(.primary)
                                .font(.title)
                                .padding(.trailing)
                            VStack(alignment: .leading){
                                Text("Time sensitive")
                                    .bold()
                                    .foregroundColor(.orange)
//                                    .padding([.top, .bottom], 3)
                                Text(message.title)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                Text(message.message)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            
                    }else{
                        HStack{
                            Image(systemName: message.icon)
                                .foregroundStyle(.primary)
                                .font(.title)
                                .padding(.trailing)
                            VStack(alignment: .leading){
                                Text(message.title)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                Text(message.message)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            
                    }
                    
                }
                    
                    
                }
            Spacer()
            }.padding()
            .background(Image("51635").centerCropped().overlay(.ultraThinMaterial))
            

    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList()
    }
}
