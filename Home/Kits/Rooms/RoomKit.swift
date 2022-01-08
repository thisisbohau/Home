//
//  RoomKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.10.21.
//
import SwiftUI
import Foundation

class RoomKit{
    let favKey: String = "RoomFavorites"
    func addToFavorites(id: Int){
        var favorites = getFavorites()
        favorites.append(id)
        NSUbiquitousKeyValueStore.default.set(favorites, forKey: favKey)
        print("Room added to favorites: \(id)")
    }
    func removeFromFavorites(id: Int){
        var favorites = getFavorites()
        favorites.removeAll(where: {$0 == id})
        NSUbiquitousKeyValueStore.default.set(favorites, forKey: favKey)
        print("Room removed from favorites: \(id)")
    }
    func getFavorites() -> [Int]{
        guard let favorites = NSUbiquitousKeyValueStore.default.array(forKey: favKey) as? [Int] else{
            print("Unable to fetch favorites: \(NSError.debugDescription())")
            
//            NSUbiquitousKeyValueStore.default.set([Int](), forKey: favKey)
            return [Int]()
        }
        return favorites
    }
}


struct RoomFavoriteControl: View{
    var room: Room
    @State var isFavorite: Bool = false
    
    func toggle(){
        if isFavorite{
            RoomKit().addToFavorites(id: Int(room.id))
        }else{
            RoomKit().removeFromFavorites(id: Int(room.id))
        }
    }
    func fetch(){
        if RoomKit().getFavorites().contains(Int(room.id)){
            isFavorite = true
        }else{
            isFavorite = false
        }
    }
    var body: some View{
        VStack{
            HStack{
                Spacer()
                Text("Display Options")
                    .font(.largeTitle.bold())
                    
                Spacer()
            }.padding()
                .padding(.top)
            Form{
                Section(header: Text("Is Favorite")){
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }
            }
        }
        .onChange(of: isFavorite, perform: {_ in toggle()})
        .onAppear(perform: fetch)
    }
}
