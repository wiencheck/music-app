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
    private var query: MPMediaQuery
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
        query = MPMediaQuery()
        print("Musicquery init start")
        print("Musicquery init end")
    }
    
    func setArrays(){
        if !playlistsSet{
            _ = allPlaylists()
        }
        if !artistsSet {
            _ = allArtists()
        }
        if !albumsSet {
            _ = allAlbums()
        }
        if !songsSet {
            _ = allSongs()
        }
        arraysSet = true
    }
    
    private func filterQuery() {
        let cloudPredicate = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyIsCloudItem, comparisonType: .equalTo)
        let drmPredicate = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyHasProtectedAsset, comparisonType: .equalTo)
        query.addFilterPredicate(cloudPredicate)
        query.addFilterPredicate(drmPredicate)
    }
    
    func allSongs() -> [MPMediaItem]{
        query = MPMediaQuery.songs()
        filterQuery()
        let songs = query.items
        currentSongsCount = songs?.count
        self.songs = songs
        songsSet = true
        return songs!
    }
    
    func songsByArtistID(artist: MPMediaEntityPersistentID) -> [MPMediaItem]{
        query = MPMediaQuery.songs()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return query.items!
    }
    
    func allArtists() -> [Artist]{
        query = MPMediaQuery.songs()
        query.groupingType = .albumArtist
        filterQuery()
        var artists = [Artist]()
        for collection in query.collections!{
            artists.append(Artist(Collection: collection))
        }
        self.artists = artists
        artistsSet = true
        return artists
    }
    
    func artistAlbumsID(artist: MPMediaEntityPersistentID) -> [AlbumB]{
        query = MPMediaQuery.albums()
        filterQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtistPersistentID, comparisonType: .equalTo))
        var albums = [AlbumB]()
        if let det = query.collections{
            for i in 0 ..< det.count{
                albums.append(AlbumB(collection: det[i]))
            }
        }
        return albums
    }
    
    func allAlbums() -> [AlbumB]{
        query = MPMediaQuery.songs()
        filterQuery()
        query.groupingType = .album
        var albums = [AlbumB]()
        for album in query.collections!{
            let a = AlbumB(collection: album)
            albums.append(a)
        }
        self.albums = albums
        albumsSet = true
        return albums
    }
    
    func albumID(album: MPMediaEntityPersistentID) -> AlbumB{
        query = MPMediaQuery.albums()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return AlbumB(collection: (query.collections?.first)!)
    }
    
    func songsByAlbumID(album: MPMediaEntityPersistentID) -> [MPMediaItem]{
        query = MPMediaQuery.songs()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return query.items!
    }
    
    func albumBy(item: MPMediaItem) -> AlbumB{
        query = MPMediaQuery.albums()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: item.albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return AlbumB(collection: (query.collections?.first)!)
    }
    
    func artistBy(item: MPMediaItem) -> Artist{
        query = MPMediaQuery.artists()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: item.artistPersistentID, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return Artist(Collection: (query.collections?.first)!)
    }
    
    func allPlaylists() -> [Playlist] {
        query = MPMediaQuery.songs()
        filterQuery()
        query.groupingType = .playlist
        var lists = [Playlist]()
        for list in query.collections! {
            if let l = list as? MPMediaPlaylist {
                lists.append(Playlist(collection: l))
            }
        }
        self.playlists = lists
        playlistsSet = true
        return lists
    }
    
    func playlistsForParent(_ id: MPMediaEntityPersistentID) -> [Playlist] {
        query = MPMediaQuery.playlists()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: id, forProperty: "parentPersistentID", comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        var lists = [Playlist]()
        for coll in query.collections! {
            if let list = coll as? MPMediaPlaylist {
                lists.append(Playlist(collection: list))
            }
        }
        return lists
    }
    
    /*func playlistsIncluding(artist: MPMediaEntityPersistentID) -> [Playlist]{
        query = MPMediaQuery.songs()
        query.groupingType = .playlist
        var playlists = [Playlist]()
        for collection in query.collections!{
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
        query = MPMediaQuery.playlists()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: playlist, forProperty: MPMediaPlaylistPropertyPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        let list = Playlist(collection: query.collections![0] as! MPMediaPlaylist)
        return list
    }
    
    func songForID(ID: MPMediaEntityPersistentID) -> MPMediaItem{
        query = MPMediaQuery.songs()
        filterQuery()
        let predicate = MPMediaPropertyPredicate(value: ID, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return (query.items?.first)!
    }
    
    func allPodcasts() -> [MPMediaItem] {
        query = MPMediaQuery.podcasts()
        filterQuery()
        return query.items!
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
                //print("progress = \(self.spotlightProgress)")
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
            print("Indeksowanie zakonczone!")
            self.delegate?.indexingEnded()
            self.networkIndicator(false)
        })
    }
    
    func networkIndicator(_ enabled: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = enabled
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
