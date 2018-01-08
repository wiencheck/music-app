//
//  AlbumB.swift
//  Plum
//
//  Created by Adam Wienconek on 03.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

/*struct AlbumKey {
 static let items = "items"
 static let id = "id"
 static let name = "name"
 static let artwork = "artwork"
 static let artist = "artist"
 static let songs = "songs"
 static let year = "year"
 static let cloud = "cloud"
 static let many = "many"
 }*/

@objcMembers class AlbumB: NSObject{
    let items: [MPMediaItem]
    let ID: MPMediaEntityPersistentID
    let name: String?
    let artwork: UIImage?
    let artist: String?
    let songsIn: Int
    var year: String!
    var isCloud: Bool
    var manyArtists: Bool
    
    //MARK: NSCoding
    
    /*func encode(with aCoder: NSCoder) {
     aCoder.encode(items, forKey: AlbumKey.items)
     aCoder.encode(ID, forKey: AlbumKey.id)
     aCoder.encode(name, forKey: AlbumKey.name)
     aCoder.encode(artwork, forKey: AlbumKey.artwork)
     aCoder.encode(artist, forKey: AlbumKey.artist)
     aCoder.encode(songsIn, forKey: AlbumKey.songs)
     aCoder.encode(year, forKey: AlbumKey.year)
     aCoder.encode(isCloud, forKey: AlbumKey.cloud)
     aCoder.encode(manyArtists, forKey: AlbumKey.many)
     }
     
     required convenience init?(coder aDecoder: NSCoder) {
     guard let itemy = aDecoder.decodeObject(forKey: AlbumKey.items) as? [MPMediaItem]
     else {
     return nil
     }
     guard let id = aDecoder.decodeObject(forKey: AlbumKey.id) as? MPMediaEntityPersistentID else {
     return nil
     }
     guard let nam = aDecoder.decodeObject(forKey: AlbumKey.name) as? String else {
     return nil
     }
     guard let art = aDecoder.decodeObject(forKey: AlbumKey.artwork) as? UIImage else{
     return nil
     }
     let songs = aDecoder.decodeInteger(forKey: AlbumKey.songs)
     guard let ye = aDecoder.decodeObject(forKey: AlbumKey.year) as? String else {
     return nil
     }
     let cloud = aDecoder.decodeBool(forKey: AlbumKey.cloud)
     let many = aDecoder.decodeBool(forKey: AlbumKey.many)
     guard let arti = aDecoder.decodeObject(forKey: AlbumKey.artist) as? String else {
     return nil
     }
     self.init(itemy: itemy, arti: arti, id: id, nam: nam, art: art, songs: songs, ye: ye, cloud: cloud, many: many)
     }
     
     init(itemy: [MPMediaItem], arti: String, id: MPMediaEntityPersistentID, nam: String, art: UIImage, songs: Int, ye: String, cloud: Bool, many: Bool) {
     self.items = itemy
     self.ID = id
     self.name = nam
     self.artwork = art
     self.songsIn = songs
     self.year = ye
     self.isCloud = cloud
     self.manyArtists = many
     self.artist = arti
     }*/
    
    init(collection: MPMediaItemCollection){
        items = collection.items
        let item = items[0]
        ID = item.albumPersistentID
        name = item.albumTitle
        if let img = item.artwork?.image(at: CGSize(width: 80, height: 80)){
            artwork = img
        }else{
            artwork = #imageLiteral(resourceName: "no_music")
        }
        artist = item.albumArtist
        manyArtists = false
        for item in items{
            if item.artist != self.artist{
                manyArtists = true
                break
            }
        }
        songsIn = items.count
        let yearNumber: NSNumber = item.value(forProperty: "year") as! NSNumber
        if (yearNumber.isKind(of: NSNumber.self)) {
            let _year = yearNumber.intValue
            if (_year != 0) {
                self.year = "\(_year)"
            }
        }
        isCloud = true
        for item in items{
            if !item.isCloudItem{
                isCloud = false
                break
            }
        }
    }
    
    //MARK: Archiving Paths
    
    //static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //static let ArchiveURL = DocumentsDirectory.appendingPathComponent("albums")
}
