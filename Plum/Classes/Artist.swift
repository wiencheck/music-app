//
//  Artist.swift
//  Plum
//
//  Created by Adam Wienconek on 03.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

fileprivate struct ArtistKey {
    static let id = "id"
    static let name = "name"
    static let artwork = "artwork"
    static let albums = "albums"
    static let songs = "songs"
    static let cloud = "cloud"
}

@objcMembers class Artist: NSObject{
    let ID: MPMediaEntityPersistentID!
    let name: String!
    let artwork: UIImage
    let albumsIn: Int
    let songsIn: Int
    var isCloud: Bool
    
    init(Collection: MPMediaItemCollection){
        let item = Collection.representativeItem
        self.ID = item?.albumArtistPersistentID
        self.name = item?.albumArtist ?? "Unknown artist"
        if let art = item?.artwork?.image(at: CGSize(width: 200, height: 200)) {
            artwork = art
        }else{
            artwork = #imageLiteral(resourceName: "no_music")
        }
        self.songsIn = Collection.items.count
        albumsIn = musicQuery.shared.artistAlbumsID(artist: self.ID).count
        isCloud = true
        for song in Collection.items{
            if !song.isCloudItem{
                isCloud = false
                break
            }
        }
    }
    
    /*func encode(with aCoder: NSCoder) {
     aCoder.encode(ID, forKey: ArtistKey.id)
     aCoder.encode(name, forKey: ArtistKey.name)
     aCoder.encode(artwork, forKey: ArtistKey.artwork)
     aCoder.encode(albumsIn, forKey: ArtistKey.albums)
     aCoder.encode(songsIn, forKey: ArtistKey.songs)
     aCoder.encode(isCloud, forKey: ArtistKey.cloud)
     }
     
     required convenience init?(coder aDecoder: NSCoder) {
     guard let id = aDecoder.decodeObject(forKey: ArtistKey.id) as? MPMediaEntityPersistentID else {
     return nil
     }
     guard let nam = aDecoder.decodeObject(forKey: ArtistKey.name) as? String else { return nil }
     guard let art = aDecoder.decodeObject(forKey: ArtistKey.artwork) as? UIImage else { return nil }
     let alb = aDecoder.decodeInteger(forKey: ArtistKey.albums)
     let son = aDecoder.decodeInteger(forKey: ArtistKey.songs)
     let cloud = aDecoder.decodeBool(forKey: ArtistKey.cloud)
     self.init(id: id, nam: nam, art: art, alb: alb, son: son, cloud: cloud)
     }
     
     init(id: MPMediaEntityPersistentID, nam: String, art: UIImage, alb: Int, son: Int, cloud: Bool) {
     ID = id
     name = nam
     artwork = art
     albumsIn = alb
     songsIn = son
     isCloud = cloud
     }
     
     //MARK: Archiving Paths
     
     static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
     static let ArchiveURL = DocumentsDirectory.appendingPathComponent("artists")*/
}
