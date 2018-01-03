//
//  SongsCell.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SongCell: UITableViewCell {

    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artAlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(item: MPMediaItem, titColor: UIColor, artColor: UIColor, albColor: UIColor){
        titleLabel.text = item.title
        titleLabel.textColor = titColor
        if let art = item.artwork {
            artworkView.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artworkView.image = #imageLiteral(resourceName: "no_music")
        }
        let art = item.albumArtist ?? "Unknown"
        let range = NSRange(location: 0, length: art.count)
        let nart = NSMutableAttributedString(string: art)
        nart.addAttribute(NSAttributedStringKey.foregroundColor, value: artColor, range: range)
        var alb = ""
        if GlobalSettings.rating {
            alb = " " + item.labelFromRating()
            let nalb = NSMutableAttributedString(string: alb)
            let range2 = NSRange(location: 0, length: alb.count)
            nalb.addAttribute(NSAttributedStringKey.foregroundColor, value: GlobalSettings.tint.color, range: range2)
            nart.append(nalb)
        }else{
            alb = " " + (item.albumTitle ?? "Unknown")
            let nalb = NSMutableAttributedString(string: alb)
            let range2 = NSRange(location: 0, length: alb.count)
            nalb.addAttribute(NSAttributedStringKey.foregroundColor, value: albColor, range: range2)
            nart.append(nalb)
        }
        artAlLabel.attributedText = nart
    }
    
    func artSetup(item: MPMediaItem, titColor: UIColor, artColor: UIColor, albColor: UIColor){
        titleLabel.text = item.title
        titleLabel.textColor = titColor
        if let art = item.artwork {
            artworkView.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artworkView.image = #imageLiteral(resourceName: "no_music")
        }
        let art = item.albumTitle ?? "Unknown"
        let range = NSRange(location: 0, length: art.count)
        let nart = NSMutableAttributedString(string: art)
        nart.addAttribute(NSAttributedStringKey.foregroundColor, value: artColor, range: range)
        var alb = ""
        if GlobalSettings.rating {
            alb = " " + item.labelFromRating()
            let nalb = NSMutableAttributedString(string: alb)
            let range2 = NSRange(location: 0, length: alb.count)
            nalb.addAttribute(NSAttributedStringKey.foregroundColor, value: GlobalSettings.tint.color, range: range2)
            nart.append(nalb)
        }
        artAlLabel.attributedText = nart
    }
    
    /*func editString(artAl: String, artistLetters: Int, albumLetters: Int) -> NSMutableAttributedString{
        var editedArtAl: NSMutableAttributedString
        let range = NSRange(location: artistLetters, length: albumLetters)
        editedArtAl = NSMutableAttributedString(string: artAl)
        editedArtAl.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: range)
        return editedArtAl
    }*/

}
