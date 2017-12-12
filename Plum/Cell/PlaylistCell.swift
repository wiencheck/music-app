//
//  PlaylistCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 02.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class PlaylistCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    
    func setup(list: Playlist){
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 1
        title.text = list.name
        detail.text = "\(list.songsIn) songs"
        artwork.image = list.image
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        artwork.layer.cornerRadius = 6.0
        artwork.clipsToBounds = true
    }
    
}
