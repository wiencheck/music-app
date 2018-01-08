//
//  Playlist.swift
//  Plum
//
//  Created by Adam Wienconek on 03.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

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
                        if let art = song.artwork?.image(at: CGSize(width: 120, height: 120)) {
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
