//
//  CollectionViewCell.swift
//  SampleContactList
//
//  Created by Adam Wienconek on 14.10.2017.
//  Copyright © 2017 Stephen Lindauer. All rights reserved.
//

import UIKit
import MediaPlayer

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    var rounded = true
    
    func setup(artist: Artist){
        mainLabel.lineBreakMode = .byWordWrapping
        mainLabel.numberOfLines = 1
        mainLabel.text = artist.name
        let count = artist.songsIn
        let albums = artist.albumsIn
        var st = ""
//        if count > 1 {
//            st = "\(count) songs"
//        }else{
//            st = "1 song"
//        }
        if count > 1 {
            if albums > 1 {
                st = "\(albums) albums ･ \(count) songs"
            }else{
                st = "1 album ･ \(count) songs"
            }
        }else{
            if albums > 1 {
                st = "\(albums) albums ･ 1 song"
            }else{
                st = "1 album ･ 1 song"
            }
        }
        detailLabel.text = st
        artwork.image = artist.artwork
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        if rounded {
            artwork.layer.cornerRadius = 3.0
        }
        artwork.clipsToBounds = true
    }
}
