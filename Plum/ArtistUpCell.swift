//
//  ArtistUpCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 27.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistUpCell: UITableViewCell {
    
    var item: MPMediaItem!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var duration: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(item: MPMediaItem){
        self.title.text = item.title
        self.album.text = item.albumTitle ?? "Unknown Album"
        self.artwork.image = item.artwork?.image(at: artwork.bounds.size) ?? #imageLiteral(resourceName: "no_music")
        self.item = item
        if GlobalSettings.ratingMode{
            duration.textColor = GlobalSettings.tint.color
            switch item.rating{
            case 1:
                duration.text = "★☆☆☆☆"
            case 2:
                duration.text = "★★☆☆☆"
            case 3:
                duration.text = "★★★☆☆"
            case 4:
                duration.text = "★★★★☆"
            case 5:
                duration.text = "★★★★★"
            default:
                duration.text = "☆☆☆☆☆"
            }
        }else{
            let d = item.playbackDuration.calculateFromTimeInterval()
            self.duration.text = "\(d.minute):\(d.second)"
        }
    }

}
