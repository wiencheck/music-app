//
//  AlbumsCollectionCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 25.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class AlbumsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    var rounded = true
    
    func setup(album: AlbumB){
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.numberOfLines = 1
        mainLabel.text = album.name
        //let count = album.songsIn
        //var st = ""
        let genre = album.items[0].albumArtist ?? ""
//        if genre != "" {
//            if count > 1 {
//                st = "\(genre) ･ \(count)"
//            }else{
//                st = "\(genre) ･ 1 song"
//            }
//        }else{
//            st = "\(count) songs"
//        }
        detailLabel.text = genre
        artwork.image = album.artwork
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        if rounded {
            artwork.layer.cornerRadius = 6.0
        }
        artwork.clipsToBounds = true
    }

    
}
