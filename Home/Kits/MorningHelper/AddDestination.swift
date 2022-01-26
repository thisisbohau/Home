//
//  AddDestination.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.10.21.
//

import SwiftUI
import MapKit

struct AddDestination: View {
    @ObservedObject var locationService: LocationService
    @State var selectedAddress: MKLocalSearchCompletion? = nil
    @State var name: String = ""
    
    func addLocation(){
        locationService.getLocationFromAddress(address: selectedAddress!, completion: {coordinates in
            let destination = LocationDestination(id: 0, name: name, latitude: coordinates.latitude, longitude: coordinates.longitude)
            MorningKit().addLocation(location: destination)
        })
       
    }
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Search Location")) {
                    ZStack(alignment: .trailing) {
                        TextField("Search", text: $locationService.queryFragment)
                        // This is optional and simply displays an icon during an active search
                        if locationService.status == .isSearching {
                            Image(systemName: "clock")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                Section(header: Text("Select Address")) {
                    List {
                        Group { () -> AnyView in
                            switch locationService.status {
                            case .noResults: return AnyView(Text("No Results"))
                            case .error(let description): return AnyView(Text("Error: \(description)"))
                            default: return AnyView(EmptyView())
                            }
                        }.foregroundColor(Color.gray)

                        ForEach(locationService.searchResults, id: \.self) { completionResult in
                            // This simply lists the results, use a button in case you'd like to perform an action
                            // or use a NavigationLink to move to the next view upon selection.
                            Button(action: {selectedAddress = completionResult}){
                                VStack(alignment: .leading){
                                    Text(completionResult.title)
                                    if completionResult.subtitle != ""{
                                        Text(completionResult.subtitle)
                                            .foregroundStyle(.secondary)
                                    }
                                }.padding(10)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                if selectedAddress != nil{
                    Section(header: Text("Selected")){
                        VStack(alignment: .leading){
                            Text(selectedAddress!.title)
                            if selectedAddress!.subtitle != ""{
                                Text(selectedAddress!.subtitle)
                                    .foregroundStyle(.secondary)
                            }
                        }.padding(10)
                    }
                    Section(header: Text("Add name")){
                        TextField("Name", text: $name)
                    }
                }
                
                
                
            }
            Button(action: addLocation){
                HStack{
                    Spacer()
                    Text("Add Location")
                        .font(.body.bold())
                    Spacer()
                }
                
            }.buttonStyle(RectangleButtonStyle(color: Color.accentColor)).disabled(name.isEmpty)
        }
    }
}

//struct AddDestination_Previews: PreviewProvider {
//    static var previews: some View {
//        AddDestination()
//    }
//}
