//
//  SongInAlbumCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 29.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SongInAlbumCell: UITableViewCell {
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel?
    var item: MPMediaItem!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(item: MPMediaItem){
        trackNumberLabel.text = "\(item.albumTrackNumber)"
        titleLabel.text = item.title
        if GlobalSettings.ratingMode{
            durationLabel.textColor = GlobalSettings.theme
            switch item.rating{
            case 1:
                durationLabel.text = "★☆☆☆☆"
            case 2:
                durationLabel.text = "★★☆☆☆"
            case 3:
                durationLabel.text = "★★★☆☆"
            case 4:
                durationLabel.text = "★★★★☆"
            case 5:
                durationLabel.text = "★★★★★"
            default:
                durationLabel.text = "☆☆☆☆☆"
            }
        }else{
            durationLabel.text = "\(item.playbackDuration.calculateFromTimeInterval().minute):\(item.playbackDuration.calculateFromTimeInterval().second)"
        }
        self.item = item
    }
    
    func setupA(item: MPMediaItem){
        trackNumberLabel.text = "\(item.albumTrackNumber)"
        titleLabel.text = item.title
        artistLabel?.text = item.artist
        if GlobalSettings.ratingMode{
            durationLabel.textColor = GlobalSettings.theme
            switch item.rating{
            case 1:
                durationLabel.text = "★☆☆☆☆"
            case 2:
                durationLabel.text = "★★☆☆☆"
            case 3:
                durationLabel.text = "★★★☆☆"
            case 4:
                durationLabel.text = "★★★★☆"
            case 5:
                durationLabel.text = "★★★★★"
            default:
                durationLabel.text = "\(item.playbackDuration.calculateFromTimeInterval().minute):\(item.playbackDuration.calculateFromTimeInterval().second)"
            }
        }else{
            durationLabel.text = "\(item.playbackDuration.calculateFromTimeInterval().minute):\(item.playbackDuration.calculateFromTimeInterval().second)"
        }
        self.item = item
    }

}
