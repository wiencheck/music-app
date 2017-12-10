//
//  Structs:Classes.swift
//  wiencheck
//
//  Created by Adam Wienconek on 14.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

@objcMembers class Artist: NSObject{
    let collection: MPMediaItemCollection
    let ID: MPMediaEntityPersistentID!
    let name: String!
    let artwork: MPMediaItemArtwork?
    let albumsIn: Int
    let songsIn: Int
    var isCloud: Bool
    
    /*init(){
        collection = MPMediaItemCollection()
        albumsIn = Int()
        songsIn = Int()
        isCloud = Bool()
        artwork = MPMediaItemArtwork(image: UIImage())
        
    }*/
    init(Collection: MPMediaItemCollection){
        let item = Collection.representativeItem
        self.ID = item?.albumArtistPersistentID
        self.collection = Collection
        self.name = item?.albumArtist ?? "Unknown artist"
        self.artwork = item?.artwork
        self.songsIn = Collection.items.count
        albumsIn = musicQuery().artistAlbumsID(artist: self.ID).count
        isCloud = true
        for song in Collection.items{
            if !song.isCloudItem{
                isCloud = false
                break
            }
        }
    }
}

/*struct Album{
    let collection: MPMediaItemCollection
    let ID: MPMediaEntityPersistentID!
    let name: String!
    let artwork: MPMediaItemArtwork?
    let artist: String
    let songsIn: Int
    var year: String = "Data nieznana"
    var discs: Int
    init(Collection: MPMediaItemCollection){
        let item = Collection.representativeItem
        ID = item?.albumPersistentID
        self.collection = Collection
        self.name = item?.albumTitle
        self.artwork = item?.artwork
        self.artist = (item?.albumArtist)!
        self.songsIn = Collection.count
        let yearNumber: NSNumber = item!.value(forProperty: "year") as! NSNumber
        if (yearNumber.isKind(of: NSNumber.self)) {
            let _year = yearNumber.intValue
            if (_year != 0) {
                self.year = "\(_year)"
            }
        }
        self.discs = item?.discCount ?? 1
    }
}*/

@objcMembers class AlbumB: NSObject{
    let items: [MPMediaItem]
    let ID: MPMediaEntityPersistentID
    let name: String?
    let artwork: MPMediaItemArtwork?
    let artist: String?
    let songsIn: Int
    var year = ""
    var isCloud: Bool
    var manyArtists: Bool
    init(collection: MPMediaItemCollection){
        items = collection.items
        let item = items[0]
        ID = item.albumPersistentID
        name = item.albumTitle
        artwork = item.artwork
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
}

struct Playlist {
    let items: [MPMediaItem]
    let ID: MPMediaEntityPersistentID
    let name: String
    let songsIn: Int
    let image: UIImage
    private var images: [UIImage]!
    
    init(collection: MPMediaItemCollection){
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
        if images.count < 4{
            for song in items{
                if !albums.contains(song.albumTitle!) && song.artwork != nil{
                    albums.append(song.albumTitle!)
                    images.append((song.artwork?.image(at: CGSize(width: 200, height: 200)))!)
                    if images.count == 4 { break }
                }
            }
        }
        image = combineImages(images: images)
    }
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
    default:
        result = images[0]
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
