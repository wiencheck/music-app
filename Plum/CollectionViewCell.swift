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
    
    func setup(artist: Artist){
        mainLabel.text = artist.name
        let count = artist.collection.count
        if (artist.collection.representativeItem?.isCloudItem)!{
            detailLabel.text = "Cloud item"
        }else{
            if count == 1{
                detailLabel.text = "1 song"
            }else{
                detailLabel.text = "\(count) songs"
            }
        }
        let art = artist.artwork?.image(at: artwork.bounds.size)
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
