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
import os.log

class musicQuery{
    var delegate: MySpotlightDelegate?
    static let shared = musicQuery()
    //let mainQuery: MPMediaQuery
    var detailQuery: MPMediaQuery!
    var currentSongsCount: Int!
    var songs: [MPMediaItem]!
    var artists: [Artist]!
    var albums: [AlbumB]!
    var playlists: [Playlist]!
    var spotlightProgress: Float = 0
    var arraysSet = false
    var artistsSet = false
    var albumsSet = false
    var playlistsSet = false
    var songsSet = false
    
    private init(){
        //mainQuery = MPMediaQuery()
        print("Musicquery init start")
        //setArrays()
        print("Musicquery init end")
    }
    
    func setArrays(){
        if !playlistsSet{
            playlists = allPlaylists()
            playlistsSet = true
        }
        if !artistsSet {
            artists = allArtists()
            artistsSet = true
        }
        if !albumsSet {
            albums = allAlbums()
            albumsSet = true
        }
        if !songsSet {
            songs = allSongs()
            songsSet = true
        }
        arraysSet = true
    }
    
    /*private func savePlaylists() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(playlists, toFile: Playlist.ArchiveURL.path)
        if isSuccessfulSave {
            print("playlists successfully saved.")
        } else {
            print("Failed to save playlists...")
        }
    }
    
    private func loadPlaylists() -> [Playlist]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Playlist.ArchiveURL.path) as? [Playlist]
    }
    
    private func saveAlbums() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(albums, toFile: AlbumB.ArchiveURL.path)
        if isSuccessfulSave {
            print("Albums successfully saved.")
        } else {
            print("Failed to save albums...")
        }
    }
    
    private func loadAlbums() -> [AlbumB]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AlbumB.ArchiveURL.path) as? [AlbumB]
    }
    
    private func saveArtists() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(artists, toFile: Artist.ArchiveURL.path)
        if isSuccessfulSave {
            print("Artists successfully saved.")
        } else {
            print("Failed to save artists...")
        }
    }
    
    private func loadArtists() -> [Artist]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Artist.ArchiveURL.path) as? [Artist]
    }*/
    
    func allSongs() -> [MPMediaItem]{
        detailQuery = MPMediaQuery.songs()
        filterCloudItems(detailQuery)
        let songs = detailQuery?.items
        currentSongsCount = songs?.count
        self.songs = songs
        songsSet = true
        return songs!
    }
    
    func songsByArtistID(artist: MPMediaEntityPersistentID) -> [MPMediaItem]{
        detailQuery = MPMediaQuery.songs()
        filterCloudItems(detailQuery)
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)
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
        self.artists = artists
        artistsSet = true
        return artists
    }
    
    func artistAlbumsID(artist: MPMediaEntityPersistentID) -> [AlbumB]{
        detailQuery = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        detailQuery?.addFilterPredicate(predicate)
        filterCloudItems(detailQuery)
        var albums = [AlbumB]()
        if let det = detailQuery.collections{
            for i in 0 ..< det.count{
                albums.append(AlbumB(collection: det[i]))
            }
        }
        return albums
    }
    
    func allAlbums() -> [AlbumB]{
        detailQuery = MPMediaQuery.albums()
        filterCloudItems(detailQuery)
        var albums = [AlbumB]()
        for album in detailQuery.collections!{
            let a = AlbumB(collection: album)
            if !a.isCloud {
                albums.append(a)
            }
        }
        self.albums = albums
        albumsSet = true
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
        filterCloudItems(detailQuery)
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
        let query = MPMediaQuery.songs()
        query.groupingType = .playlist
        var lists = [Playlist]()
        for list in query.collections! {
            if let l = list as? MPMediaPlaylist {
                lists.append(Playlist(collection: l))
//                let id = l.persistentID
//                let parent = l.value(forProperty: "parentPersistentID")
//                let name = l.name
//                let folder = l.value(forProperty: "isFolder")
//                print("Name: \(name), folder: \(folder), id: \(id), parent: \(parent)")
            }
        }
        self.playlists = lists
        playlistsSet = true
        return lists
    }
    
//    func playlistsV() -> [Playlist] {
//        detailQuery = MPMediaQuery.songs()
//        detailQuery.groupingType = .playlist
//        var lists = [Playlist]()
//        for coll in detailQuery.collections! {
//            if coll.value(forProperty: "isFolder") as! Bool {
//                lists.append(Playlist(collection: coll))
//            }else if coll.value(forProperty: "parentPersistentID") as? UInt64 == 0 {
//                lists.append(Playlist(collection: coll))
//            }
//        }
//        return lists
//    }
    
    func playlistsForParent(_ id: MPMediaEntityPersistentID) -> [Playlist] {
        detailQuery = MPMediaQuery.playlists()
        let predicate = MPMediaPropertyPredicate(value: id, forProperty: "parentPersistentID", comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        var lists = [Playlist]()
        for coll in detailQuery.collections! {
            if let list = coll as? MPMediaPlaylist {
                lists.append(Playlist(collection: list))
            }
        }
        return lists
    }
    
    /*func playlistsIncluding(artist: MPMediaEntityPersistentID) -> [Playlist]{
        detailQuery = MPMediaQuery.songs()
        detailQuery.groupingType = .playlist
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
    }*/
    
    func playlistForID(playlist: MPMediaEntityPersistentID) -> Playlist {
        detailQuery = MPMediaQuery.playlists()
        let predicate = MPMediaPropertyPredicate(value: playlist, forProperty: MPMediaPlaylistPropertyPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        let list = Playlist(collection: detailQuery.collections![0] as! MPMediaPlaylist)
        return list
    }
    
    func filterCloudItems(_ q: MPMediaQuery){
        let cloudPredicate = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyIsCloudItem)
        q.addFilterPredicate(cloudPredicate)
    }
    
    func songForID(ID: MPMediaEntityPersistentID) -> MPMediaItem{
        detailQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: ID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        detailQuery.addFilterPredicate(predicate)
        return (detailQuery.items?.first)!
    }
    
    func addToSpotlight(){
        print("Indeksowanie rozpoczete...")
        self.networkIndicator(true)
        var searchableItems = [CSSearchableItem]()
        var i: Float = 0.0
        spotlightProgress = 0
        let tmp = Float(currentSongsCount + playlists.count)
        DispatchQueue.global().async(execute: {
            for item in self.songs{
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.title = item.title
                attributeSet.contentDescription = "\(item.albumArtist ?? "Unknown artist") - \(item.albumTitle ?? "Unknown album")"
                attributeSet.rating = item.rating as NSNumber
                let artwork = item.artwork?.image(at: CGSize(width: 10, height: 10)) ?? #imageLiteral(resourceName: "no_music")
                let artworkData = UIImagePNGRepresentation(artwork)
                attributeSet.thumbnailData = artworkData
                let searchableItem = CSSearchableItem(uniqueIdentifier: "song \(item.persistentID)", domainIdentifier: "com.adw.plum", attributeSet: attributeSet)
                searchableItems.append(searchableItem)
                print("progress = \(self.spotlightProgress)")
                self.spotlightProgress = i / tmp
                i += 1.0
            }
            for list in self.playlists {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.title = list.name
                attributeSet.contentDescription = "Playlist - \(list.songsIn) songs"
                let artwork = list.image
                let artworkData = UIImagePNGRepresentation(artwork)
                attributeSet.thumbnailData = artworkData
                let searchableItem = CSSearchableItem(uniqueIdentifier: "list \(list.ID)", domainIdentifier: "com.adw.plum", attributeSet: attributeSet)
                searchableItems.append(searchableItem)
                print("progress = \(self.spotlightProgress)")
                self.spotlightProgress = i / tmp
                i += 1.0
            }
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully indexed!")
                }
            }
            self.networkIndicator(false)
        })
        print("Indeksowanie zakonczone!")
    }
    
    func networkIndicator(_ enabled: Bool) {
        if enabled {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func removeAllFromSpotlight(){
        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        })
    }
}

protocol MySpotlightDelegate {
    func indexingEnded()
}
