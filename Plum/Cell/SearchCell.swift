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
        title.textColor = UIColor.mainLabel
        detail.textColor = UIColor.detailLabel
        if let art = song.artwork {
            artwork.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artwork.image = #imageLiteral(resourceName: "no_music")
        }
        title.text = song.title ?? "Unknown title"
        if GlobalSettings.rating {
            detail.text = "\(song.albumArtist ?? "Unknown artist") - \(song.labelFromRating())"
        }else{
            detail.text = "\(song.albumTitle ?? "Unknown album") - \(song.playbackDuration.calculateFromTimeInterval().minute):\(song.playbackDuration.calculateFromTimeInterval().second)"
        }
    }
    
    func setup(artist: Artist) {
        title.textColor = UIColor.mainLabel
        detail.textColor = UIColor.detailLabel
        artwork.image = artist.artwork
        title.text = artist.name
        detail.text = "\(artist.albumsIn) albums, \(artist.songsIn) songs"
    }
    
    func setup(album: AlbumB) {
        title.textColor = UIColor.mainLabel
        detail.textColor = UIColor.detailLabel
        artwork.image = album.artwork
        title.text = album.name
        if album.year == "" {
            detail.text = "\(album.songsIn) songs"
        }else{
            detail.text = "\(album.year) - \(album.songsIn) songs"
        }
    }

    

}
