//
//  AlbumInfoCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 20.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

protocol InfoCellDelegate {
    func playPressed()
}

class AlbumInfoCell: UITableViewCell {
    
    var delegate: InfoCellDelegate?
    @IBOutlet weak var songsLabel:UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var tool: UIToolbar!
    var songs: [MPMediaItem]!
    var album: AlbumB!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(album: AlbumB, play: Bool){
        self.contentView.isUserInteractionEnabled = true
        artwork.isUserInteractionEnabled = true
        songsLabel.textColor = UIColor.mainLabel
        titleLabel.textColor = UIColor.mainLabel
        yearLabel.textColor = UIColor.mainLabel
        if GlobalSettings.theme == .dark {
            tool.barStyle = .blackTranslucent
        }else{
            tool.barStyle = .default
        }
        self.album = album
        songs = album.items
        titleLabel.text = album.name
        yearLabel.text = album.year
        artwork.image = album.artwork
        artwork.layer.cornerRadius = 6.0
        let count = NSMutableAttributedString(string: "\(album.songsIn)")
        let countR = NSRange(location: 0, length: count.length)
        count.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: countR)
        var songsL = ""
        if album.songsIn == 1 {
            songsL = " song, "
        }else{
            songsL = " songs, "
        }
        let songsAtt = NSMutableAttributedString(string: songsL)
        let songsR = NSRange(location: 0, length: songsAtt.length)
        songsAtt.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: songsR)
        let minutes = "\(calcDuration(items: songs))"
        let minutesAtt = NSMutableAttributedString(string: minutes)
        let minR = NSRange(location: 0, length: minutesAtt.length)
        minutesAtt.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: minR)
        let minAtt = NSMutableAttributedString(string: " minutes")
        let mineR = NSRange(location: 0, length: minAtt.length)
        minAtt.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: mineR)
        count.append(songsAtt)
        count.append(minutesAtt)
        count.append(minAtt)
        songsLabel.attributedText = count
    }
    
    func calcDuration(items: [MPMediaItem]) -> String{
        var duration: TimeInterval = 0
        for i in 0...items.count-1{
            duration = duration + items[i].playbackDuration
        }
        return duration.calculateFromTimeInterval().minute
    }
    
    @IBAction func playBtn() {
        delegate?.playPressed()
    }
    
    @IBAction func shufBtnPressed(_ sender: UIButton){
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = 0
        if Plum.shared.currentItem?.albumTitle == album.name{
            var i = 0
            for song in songs{
                if Plum.shared.currentItem?.persistentID == song.persistentID{
                    Plum.shared.defIndex = i
                    Plum.shared.shuffleCurrent()
                    Plum.shared.playFromShufQueue(index: 0, new: false)
                    break
                }
                i += 1
            }
        }else{
            Plum.shared.defIndex = 0
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }
        Plum.shared.play()
    }
    
}
