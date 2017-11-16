//
//  SearchCell.swift
//  Plum
//
//  Created by Adam Wienconek on 14.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    var artist: Artist?
    var album: AlbumB?
    
    func setup(song: MPMediaItem) {
        if let art = song.artwork {
            artwork.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artwork.image = #imageLiteral(resourceName: "no_music")
        }
        title.text = song.title ?? "Unknown title"
        if GlobalSettings.ratingMode {
            detail.textColor = GlobalSettings.tint.color
            detail.text = "\(song.albumArtist ?? "Unknown artist") - \(labelFromRating(item: song))"
        }else{
            detail.text = "\(song.playbackDuration.calculateFromTimeInterval().minute):\(song.playbackDuration.calculateFromTimeInterval().second) - \(song.albumTitle ?? "Unknown album")"
        }
    }
    
    func setup(artist: Artist) {
        if let art = artist.artwork {
            artwork.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artwork.image = #imageLiteral(resourceName: "no_music")
        }
        title.text = artist.name
        detail.text = "\(artist.albumsIn) albums, \(artist.songsIn) songs"
    }
    
    func setup(album: AlbumB) {
        if let art = album.artwork {
            artwork.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artwork.image = #imageLiteral(resourceName: "no_music")
        }
        title.text = album.name
        detail.text = "\(album.year) - \(album.songsIn) songs"
    }

    

}
