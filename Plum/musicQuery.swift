//
//  musicQuery.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer
import CoreSpotlight
import MobileCoreServices

class musicQuery{
    var delegate: MySpotlightDelegate?
    static let shared = musicQuery()
    let mainQuery: MPMediaQuery
    var detailQuery: MPMediaQuery!
    var currentSongsCount: Int!
    var songs: [MPMediaItem]!
    var artists: [Artist]!
    var albums: [AlbumB]!
    var playlists: [Playlist]!
    var spotlightIdentifiers = [String]()
    var currentIdentifiers = [String]()
    var progress: Float = 0.0
    
    init(){
        mainQuery = MPMediaQuery()
    }
    
    func setArrays(){
        songs = allSongs()
        artists = allArtists()
        albums = allAlbums()
        playlists = allPlaylists()
    }
    
    func allSongs() -> [MPMediaItem]{
        detailQuery = mainQuery
        filterCloudItems()
        let songs = detailQuery?.items
        currentSongsCount = songs?.count
        for song in songs!{
            currentIdentifiers.append("\(song.persistentID)")
        }
        return songs!
    }
    
    func songsByArtist(artist: String) -> [MPMediaItem]{
        detailQuery = mainQuery
        filterCloudItems()
       let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist)
       detailQuery?.addFilterPredicate(predicate)
        return detailQuery.items!
    }
    
    func songsByArtistID(artist: MPMediaEntityPersistentID) -> [MPMediaItem]{
        detailQuery = MPMediaQuery.songs()
        //filterCloudItems()
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)
        /*predicate = MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)*/
        return detailQuery.items!
    }
    
    func allArtists() -> [Artist]{
        detailQuery = MPMediaQuery.artists()
        detailQuery.groupingType = MPMediaGrouping.albumArtist
        var artists = [Artist]()
        for collection in detailQuery.collections!{
            let newArtist = Artist(Collection: collection)
            if !newArtist.isCloud{
                artists.append(newArtist)
            }
        }
        return artists
    }
    
    func artistAlbums(artist: String) -> [MPMediaItemCollection]{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtist)
        detailQuery?.addFilterPredicate(predicate)
        filterCloudItems()
        return detailQuery.collections!
    }
    
    func artistAlbumsID(artist: MPMediaEntityPersistentID) -> [AlbumB]{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)
        filterCloudItems()
        var albums = [AlbumB]()
        if let det = detailQuery.collections{
            for i in 0 ..< det.count{
                albums.append(AlbumB(collection: det[i]))
            }
        }
        return albums
    }
    
    func album(album: String) -> [MPMediaItem]{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumTitle)
        detailQuery?.addFilterPredicate(predicate)
        filterCloudItems()
        return detailQuery.items!
    }
    
    func allAlbums() -> [AlbumB]{
        detailQuery = MPMediaQuery.albums()
        var albums = [AlbumB]()
        for album in detailQuery.collections!{
            albums.append(AlbumB(collection: album))
        }
        return albums
    }
    
    func albumID(album: MPMediaEntityPersistentID) -> AlbumB{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)
        return AlbumB(collection: (detailQuery.collections?.first)!)
    }
    
    func songsByAlbumID(album: MPMediaEntityPersistentID) -> [MPMediaItem]{
        detailQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        return detailQuery.items!
    }
    
    func albumBy(item: MPMediaItem) -> AlbumB{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: item.albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        return AlbumB(collection: (detailQuery.collections?.first)!)
    }
    
    func artistBy(item: MPMediaItem) -> Artist{
        detailQuery = MPMediaQuery.artists()
        let predicate = MPMediaPropertyPredicate(value: item.artistPersistentID, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        return Artist(Collection: (detailQuery.collections?.first)!)
    }
    
    func allPlaylists() -> [Playlist] {
        detailQuery = MPMediaQuery.playlists()
        var playlists = [Playlist]()
        for collection in detailQuery.collections!{
            playlists.append(Playlist(collection: collection))
        }
        return playlists
    }
    
    func playlistsIncluding(artist: MPMediaEntityPersistentID) -> [Playlist]{
        detailQuery = MPMediaQuery.playlists()
        var playlists = [Playlist]()
        for collection in detailQuery.collections!{
            let items = collection.items
            for song in items{
                if song.albumArtistPersistentID == artist{
                    playlists.append(Playlist(collection: collection))
                    break
                }
            }
        }
        return playlists
    }
    
    func filterCloudItems(){
        let cloudPredicate = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyIsCloudItem)
        detailQuery.addFilterPredicate(cloudPredicate)
    }
    
    func songForID(ID: MPMediaEntityPersistentID) -> MPMediaItem{
        detailQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: ID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        return (detailQuery.items?.first)!
    }
    
    func hasLibraryChanged() -> Bool{
        if currentSongsCount != previousLibraryState(){
            return true
        }else{
            return false
        }
    }
    
    func wereSongsRemoved() -> Bool{
        if previousLibraryState() < currentSongsCount{
            print("Byly usuniete")
            saveCurrentLibraryState()
            return true
        }else{
            return false
        }
    }
    
    func wereSongsAdded() -> Bool{
        if previousLibraryState() > currentSongsCount{
            print("Byly dodane")
            saveCurrentLibraryState()
            return true
        }else{
            return false
        }
    }
    
    func previousLibraryState() -> Int{
        let defaults = UserDefaults.standard
        let previous = defaults.integer(forKey: "previousCount")
        return previous
    }
    
    func saveCurrentLibraryState(){
        print("Zapisuje obecny stan (\(currentSongsCount))")
        let defaults = UserDefaults.standard
        defaults.set(currentSongsCount, forKey: "previousCount")
    }
    
    func index(){
        let items = allSongs()
        for i in 0 ..< items.count{
            let project = items[i]
            
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = project.title
            attributeSet.contentDescription = project.albumArtist
            attributeSet.album = project.albumTitle
            attributeSet.rating = project.rating as NSNumber
            let art = project.artwork?.image(at: CGSize(width: 30, height: 30)) ?? #imageLiteral(resourceName: "no_music")
            let data = UIImagePNGRepresentation(art)
            attributeSet.thumbnailData = data
            let item = CSSearchableItem(uniqueIdentifier: String(project.persistentID), domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
            CSSearchableIndex.default().indexSearchableItems([item]) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully indexed!")
                }
            }
        }
    }
    
    func addToSpotlight(){
        print("Indeksowanie rozpoczete...")
        let items = allSongs()
        var searchableItems = [CSSearchableItem]()
        var i: Float = 0.0
        let tmp = Float(currentSongsCount)
        DispatchQueue.global().async(execute: {
        for item in items{
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = item.title
            attributeSet.contentDescription = "\(item.albumArtist ?? "Unknown artist") - \(item.albumTitle ?? "Unknown album")"
            attributeSet.rating = item.rating as NSNumber
            let artwork = item.artwork?.image(at: CGSize(width: 10, height: 10)) ?? #imageLiteral(resourceName: "no_music")
            let artworkData = UIImagePNGRepresentation(artwork)
            attributeSet.thumbnailData = artworkData
            
            //attributeSet.duration = 400 as NSNumber
            let searchableItem = CSSearchableItem(uniqueIdentifier: String(item.persistentID), domainIdentifier: "com.adw.plum", attributeSet: attributeSet)
            searchableItems.append(searchableItem)
            //print("progress = \(progress)")
            self.progress = i / tmp * 100
            i += 1.0
            self.spotlightIdentifiers.append(searchableItem.uniqueIdentifier)
        }
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
        })
        print("Indeksowanie zakonczone!")
    }
    
    func removeFromSpotlight(){
        let answer = zip(spotlightIdentifiers, currentIdentifiers).enumerated().filter() {
            $1.0 != $1.1
            }.map{$0.0}
        var toDelete = [String]()
        for i in 0 ..< answer.count{
            toDelete.append(spotlightIdentifiers[i])
            spotlightIdentifiers.remove(at: answer[i])
        }
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: toDelete) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    func removeAllFromSpotlight(){
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: spotlightIdentifiers) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
}

protocol MySpotlightDelegate {
    func indexingEnded()
}
