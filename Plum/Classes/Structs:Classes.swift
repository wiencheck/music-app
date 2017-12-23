//
//  Structs:Classes.swift
//  wiencheck
//
//  Created by Adam Wienconek on 14.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

struct ArtistKey {
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
        if let img = item.artwork?.image(at: CGSize(width: 200, height: 200)){
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

/*struct PlaylistKey {
    static let items = "items"
    static let id = "id"
    static let name = "name"
    static let songsIn = "songsIn"
    static let image = "image"
    static let isFolder = "isFolder"
    static let isChild = "isChild"
    static let parentID = "parentID"
}*/

@objcMembers class Playlist: NSObject {
    let items: [MPMediaItem]
    let ID: MPMediaEntityPersistentID
    let name: String
    let songsIn: Int
    let albumsIn: Int
    let image: UIImage
    private var images: [UIImage]!
    var isFolder: Bool
    var isChild: Bool
    var parentID: UInt64
    
    /*init(items: [MPMediaItem], id: MPMediaEntityPersistentID, name: String, songs: Int, image: UIImage?, folder: Bool, child: Bool, parent: UInt64) {
        self.items = items
        self.ID = id
        self.name = name
        self.songsIn = songs
        if image != nil {
            self.image = image!
        }else{
            self.image = #imageLiteral(resourceName: "no_music")
        }
        self.isFolder = folder
        self.isChild = child
        self.parentID = parent
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(items, forKey: PlaylistKey.items)
        aCoder.encode(ID, forKey: PlaylistKey.id)
        aCoder.encode(name, forKey: PlaylistKey.name)
        aCoder.encode(songsIn, forKey: PlaylistKey.songsIn)
        aCoder.encode(image, forKey: PlaylistKey.image)
        aCoder.encode(isFolder, forKey: PlaylistKey.isFolder)
        aCoder.encode(isChild, forKey: PlaylistKey.isChild)
        aCoder.encode(parentID, forKey: PlaylistKey.parentID)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let itemy = aDecoder.decodeObject(forKey: PlaylistKey.items) as? [MPMediaItem]
            else {
                print("Fail z items")
                return nil
        }
        guard let id = aDecoder.decodeObject(forKey: PlaylistKey.id) as? UInt64
            else {
                return nil
        }
        guard let nam = aDecoder.decodeObject(forKey: PlaylistKey.name) as? String
            else {
                return nil
        }
        let songsy = aDecoder.decodeInteger(forKey: PlaylistKey.songsIn)
        guard let img = aDecoder.decodeObject(forKey: PlaylistKey.image) as? UIImage
            else {
                return nil
        }
        let folder = aDecoder.decodeBool(forKey: PlaylistKey.isFolder)
        let child = aDecoder.decodeBool(forKey: PlaylistKey.isChild)
        guard let parent = aDecoder.decodeObject(forKey: PlaylistKey.parentID) as? UInt64
            else {
                return nil
        }
        self.init(items: itemy, id: id, name: nam, songs: songsy, image: img, folder: folder, child: child, parent: parent)
    }*/
    
    init(collection: MPMediaPlaylist){
        items = collection.items
        ID = collection.persistentID
        if let n = collection.value(forProperty: MPMediaPlaylistPropertyName) as? String{
            name = n
        }else{
            name = "Nie ma"
        }
        images = [UIImage]()
        songsIn = items.count
        var albums = [String]()
        for song in items{
            if let al = song.albumTitle {
                if !albums.contains(al){
                    albums.append(al)
                    if images.count <= 3 {
                        if let art = song.artwork?.image(at: CGSize(width: 200, height: 200)) {
                            images.append(art)
                        }
                    }
                }
            }
        }
        albumsIn = albums.count
        image = combineImages(images: images)
        parentID = 0
        if let n = collection.value(forProperty: "parentPersistentID") as? NSNumber {
            parentID = n.uint64Value
        }
        isFolder = collection.value(forProperty: "isFolder") as! Bool
        if parentID != 0 {
            isChild = true
        }else{
            isChild = false
        }
        print("name: \(name)\nfolder: \(isFolder)\nchild: \(isChild)\nparent: \(parentID)\nid: \(ID)\n\n")
    }
    
    //MARK: NSCoding
    
    //MARK: Archiving Paths
    
    //static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //static let ArchiveURL = DocumentsDirectory.appendingPathComponent("playlists")
    
}

extension UIColor{
    static let plumGreen = UIColor(red: 0.223529411764706, green: 0.584313725490196, blue: 0.392156862745098, alpha: 1.0)
    static let appleRed = UIColor(red: 0.917647063732147, green: 0.266666680574417, blue: 0.34901961684227, alpha: 1.0)
}

fileprivate func combineImages(images: [UIImage]) -> UIImage{
    let howMany = images.count
    var result: UIImage!
    switch howMany{
    case 2:
        let imgWidth = images[0].size.width/2
        let imgHeight = images[1].size.height
        let leftImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        let rightImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        let left = images[0].cgImage?.cropping(to: leftImgFrame)
        let right = images[1].cgImage?.cropping(to: rightImgFrame)
        let leftImg = UIImage(cgImage: left!)
        let rightImg = UIImage(cgImage: right!)
        UIGraphicsBeginImageContext(CGSize(width: 1000, height: 1000))
        leftImg.draw(in: CGRect(x: 0, y: 0, width: 500, height: 1000))
        rightImg.draw(in: CGRect(x: 500, y: 0, width: 500, height: 1000))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    case 3:
        let imgWidth = images[0].size.width/3
        let imgHeight = images[0].size.height
        let leftImgFrame = CGRect(x: images[0].size.width/3, y: 0, width: imgWidth, height: imgHeight)
        let midImgFrame = CGRect(x: images[1].size.width/3, y: 0, width: imgWidth, height: imgHeight)
        let rightImgFrame = CGRect(x: images[2].size.width/3, y: 0, width: imgWidth, height: imgHeight)
        let left = images[0].cgImage?.cropping(to: leftImgFrame)
        let mid = images[1].cgImage?.cropping(to: midImgFrame)
        let right = images[2].cgImage?.cropping(to: rightImgFrame)
        let leftImg = UIImage(cgImage: left!)
        let midImg = UIImage(cgImage: mid!)
        let rightImg = UIImage(cgImage: right!)
        UIGraphicsBeginImageContext(CGSize(width: 600, height: 600))
        leftImg.draw(in: CGRect(x: 0, y: 0, width: 200, height: 600))
        midImg.draw(in: CGRect(x: 200, y: 0, width: 200, height: 600))
        rightImg.draw(in: CGRect(x: 400, y: 0, width: 200, height: 600))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    case 4:
        UIGraphicsBeginImageContext(CGSize(width: 800, height: 800))
        images[0].draw(in: CGRect(x: 0, y: 0, width: 400, height: 400))
        images[1].draw(in: CGRect(x: 400, y: 0, width: 400, height: 400))
        images[2].draw(in: CGRect(x: 0, y: 400, width: 400, height: 400))
        images[3].draw(in: CGRect(x: 400, y: 400, width: 400, height: 400))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    case 9:
        UIGraphicsBeginImageContext(CGSize(width: 900, height: 900))
        images[0].draw(in: CGRect(x: 0, y: 0, width: 300, height: 300))
        images[1].draw(in: CGRect(x: 300, y: 0, width: 300, height: 300))
        images[2].draw(in: CGRect(x: 600, y: 0, width: 300, height: 300))
        images[3].draw(in: CGRect(x: 0, y: 300, width: 300, height: 300))
        images[4].draw(in: CGRect(x: 300, y: 300, width: 300, height: 300))
        images[5].draw(in: CGRect(x: 600, y: 300, width: 300, height: 300))
        images[6].draw(in: CGRect(x: 0, y: 600, width: 300, height: 300))
        images[7].draw(in: CGRect(x: 300, y: 600, width: 300, height: 300))
        images[8].draw(in: CGRect(x: 600, y: 600, width: 300, height: 300))
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    case 1:
        result = images[0]
    default:
        result = #imageLiteral(resourceName: "no_music")
    }
    return result
}

public func labelFromRating(item: MPMediaItem) -> String {
    switch item.rating{
    case 1:
        return "★☆☆☆☆"
    case 2:
        return "★★☆☆☆"
    case 3:
        return "★★★☆☆"
    case 4:
        return "★★★★☆"
    case 5:
        return "★★★★★"
    default:
        return "☆☆☆☆☆"
    }
}
