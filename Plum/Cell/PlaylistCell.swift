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
    var rounded = true
    
    func setup(list: Playlist){
        title.textColor = UIColor.mainLabel
        detail.textColor = UIColor.detailLabel
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 1
        title.text = list.name
        if list.isFolder {
            artwork.image = #imageLiteral(resourceName: "folder")
            //let songsCount = musicQuery.shared.playlistsForParent(list.ID).count
            detail.text = "Folder"
        }else{
            artwork.image = list.image
            detail.text = "\(list.songsIn) songs"
        }
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
