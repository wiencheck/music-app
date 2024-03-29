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
    
    func setup(item: MPMediaItem){
        if item.albumTrackNumber < 1 {
            trackNumberLabel.text = ""
        }else{
            trackNumberLabel.text = "\(item.albumTrackNumber)"
        }
        titleLabel.text = item.title
        if GlobalSettings.rating{
            durationLabel.textColor = GlobalSettings.tint.color
            durationLabel.text = item.labelFromRating()
        }else{
            durationLabel.textColor = UIColor.mainLabel
            durationLabel.text = "\(item.playbackDuration.calculateFromTimeInterval().minute):\(item.playbackDuration.calculateFromTimeInterval().second)"
        }
        self.item = item
        artistLabel?.textColor = UIColor.detailLabel
        titleLabel.textColor = UIColor.mainLabel
        trackNumberLabel.textColor = UIColor.mainLabel
    }
    
    func setupA(item: MPMediaItem){
        if item.albumTrackNumber < 1 {
            trackNumberLabel.text = ""
        }else{
            trackNumberLabel.text = "\(item.albumTrackNumber)"
        }
        titleLabel.text = item.title
        artistLabel?.text = item.artist
        if GlobalSettings.rating{
            durationLabel.textColor = GlobalSettings.tint.color
            durationLabel.text = item.labelFromRating()
        }else{
            durationLabel.textColor = UIColor.mainLabel
            durationLabel.text = "\(item.playbackDuration.calculateFromTimeInterval().minute):\(item.playbackDuration.calculateFromTimeInterval().second)"
        }
        self.item = item
        artistLabel?.textColor = UIColor.detailLabel
        titleLabel.textColor = UIColor.mainLabel
        trackNumberLabel.textColor = UIColor.mainLabel
    }

}
