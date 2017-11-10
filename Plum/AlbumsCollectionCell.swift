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
    
    func setup(album: AlbumB){
        mainLabel.text = album.name
        let count = album.songsIn
        if album.isCloud{
            detailLabel.text = "Cloud item"
        }else{
            if count == 1{
                detailLabel.text = "1 song"
            }else{
                detailLabel.text = "\(count) songs"
            }
        }
        let art = album.artwork?.image(at: CGSize(width: 50, height: 50))
        if art == nil{
            artwork.image = #imageLiteral(resourceName: "no_music")
        }else{
            artwork.image = art
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        artwork.layer.cornerRadius = 6.0
        artwork.clipsToBounds = true
    }

    
}
