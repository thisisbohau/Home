//
//  SmartHorizontalSelectionSlider.swift
//  Home
//
//  Created by David Bohaumilitzky on 23.12.21.
//

import SwiftUI

struct SmartHorizontalSelectionSlider: View {
    @Binding var selectionPoints: [SelectionPoint]
    @Binding var selectedPoint: SelectionPoint
    var controlSize: CGFloat
    var availableSpace: CGFloat
    var selectColor: Color
    
    @State var onSelectionPoint: SelectionPoint =  SelectionPoint(id: 0, icon: AnyView(Image("light.bulb")), title: "Light")
    @State var controlOffset: CGFloat = 0
    
    func getOffset(id: Int) -> CGFloat{
        let combinedControlHeight: CGFloat = CGFloat(selectionPoints.count)*controlSize
        let offsetFraction = (availableSpace - combinedControlHeight)/CGFloat(selectionPoints.count - 1)*CGFloat(id)
        return offsetFraction
    }
    func select(point: SelectionPoint){
        selectedPoint = point
        onSelectionPoint = point
        controlOffset = controlSize*CGFloat(point.id) + getOffset(id: point.id)
    }
    var body: some View {
        HStack{
            VStack{
                Spacer()
                    ZStack{
                        VStack(spacing: 0){
                            ForEach(selectionPoints){point in
                                Button(action: {select(point: point)}){
                                Rectangle()
                                        .frame(width: controlSize, height: CGFloat(availableSpace/CGFloat(selectionPoints.count))*0.8)
                                    .foregroundColor(onSelectionPoint.id == point.id ? selectColor : .clear)
                                        .padding(0)
                                        .overlay(
                                            point.icon
                                                .font(.caption)
                                                .foregroundColor(onSelectionPoint.id == point.id ? .white : .secondary)
                                        )
                                    
                                }.offset(y: getOffset(id: point.id))
                                    .padding(0)
                            }
                            Spacer()
                        }
                        
                        //MARK: Control
                        VStack{
                            VStack{
                                HStack{
                                    Spacer()
                                }
                                Spacer()
                            }
                                .frame(width: controlSize, height: controlSize)
                                .contentShape(Circle())
                                .offset(y: controlOffset)
                                .highPriorityGesture(DragGesture(minimumDistance: 0)
                                    .onChanged({location in
                                        controlOffset = location.location.y
                                        let actualLoc = location.location.y
                                        for point in selectionPoints{
                                            let calc = controlSize*CGFloat(point.id) + getOffset(id: point.id)
                                            print("Loc\(actualLoc)")
                                            
                                            let range = (actualLoc - 40)...(actualLoc + 40)
                                            
                                            if range.contains(calc){
                                                onSelectionPoint = point
                                                print("New selection: \(point.id.description)")
                                                break
                                            }
                                        }
                                    })
                                            .onEnded({location in
                                    let actualLoc = location.location.y
                                    for point in selectionPoints{
                                        let calc = controlSize*CGFloat(point.id) + getOffset(id: point.id)
                                        print("Loc\(actualLoc)")
                                        let range = (actualLoc - 40)...(actualLoc + 40)
                                        if range.contains(calc){
                                            selectedPoint = point
                                            onSelectionPoint = point
                                            controlOffset = calc
                                            print("New selection: \(point.id.description)")
                                            break
                                        }
                                    }
                                })
                                )
                            Spacer()
                        }
                    }
                    .frame(height: availableSpace)
                    .padding(10)
                    .background(.regularMaterial)
                    .cornerRadius(70)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0){
                ForEach(selectionPoints){point in
                    VStack{
                        if point.title != ""{
                        Text(point.title)
                            .padding()
                            .font(.caption)
                            .foregroundColor(onSelectionPoint.id == point.id ? .primary : .secondary)
                            .foregroundStyle(onSelectionPoint.id == point.id ? .primary : .secondary)
                        }
                            
                    }
                    .frame(height: controlSize)
                        .offset(y: getOffset(id: point.id))
                }
                Spacer()
            }.frame(height: availableSpace)
        }
        .onChange(of: selectedPoint.id, perform: {point in
            select(point: selectionPoints.first(where: {$0.id == point})!)
        })
    }
}

//struct SmartHorizontalSelectionSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        SmartHorizontalSelectionSlider(
//    }
//}
