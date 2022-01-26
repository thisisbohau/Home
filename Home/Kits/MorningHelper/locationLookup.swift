//
//  locationLookup.swift
//  Home
//
//  Created by David Bohaumilitzky on 03.10.21.
//

import Foundation
import Combine
import MapKit
import CoreLocation

class LocationService: NSObject, ObservableObject {

    func getLocationFromAddress(address: MKLocalSearchCompletion, completion: @escaping(CLLocationCoordinate2D) -> Void){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address.title) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude ?? 0
            let lon = placemark?.location?.coordinate.longitude ?? 0
            print("Lat: \(lat), Lon: \(lon)")
            completion(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
    }
   
    enum LocationStatus: Equatable {
        case idle
        case noResults
        case isSearching
        case error(String)
        case result
    }

    @Published var queryFragment: String = ""
    @Published private(set) var status: LocationStatus = .idle
    @Published private(set) var searchResults: [MKLocalSearchCompletion] = []

    private var queryCancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!

    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self

        queryCancellable = $queryFragment
            .receive(on: DispatchQueue.main)
            // we're debouncing the search, because the search completer is rate limited.
            // feel free to play with the proper value here
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
            .sink(receiveValue: { fragment in
                self.status = .isSearching
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.status = .idle
                    self.searchResults = []
                }
        })
    }
}

extension LocationService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Depending on what you're searching, you might need to filter differently or
        // remove the filter altogether. Filtering for an empty Subtitle seems to filter
        // out a lot of places and only shows cities and countries.
        self.searchResults = completer.results
        self.status = completer.results.isEmpty ? .noResults : .result
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
}