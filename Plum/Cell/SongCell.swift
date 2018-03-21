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
    
    func setup(item: MPMediaItem){
        titleLabel.text = item.title
        titleLabel.textColor = UIColor.mainLabel
        if let art = item.artwork {
            artworkView.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            artworkView.image = #imageLiteral(resourceName: "no_music")
        }
        let art = item.albumArtist ?? "Unknown"
        let range = NSRange(location: 0, length: art.count)
        let nart = NSMutableAttributedString(string: art)
        nart.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.mainLabel, range: range)
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
            nalb.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.detailLabel, range: range2)
            nart.append(nalb)
        }
        artAlLabel.attributedText = nart
    }
    
    func artSetup(item: MPMediaItem){
        titleLabel.text = item.title
        titleLabel.textColor = UIColor.mainLabel
        if let art = item.artwork {
            artworkView.image = art.image(at: CGSize(width: 30, height: 30))
        }else{
            if GlobalSettings.theme == .dark {
                artworkView.image = #imageLiteral(resourceName: "no_now")
            }else{
                artworkView.image = #imageLiteral(resourceName: "no_music")
            }
        }
        let art = item.albumTitle ?? "Unknown"
        let range = NSRange(location: 0, length: art.count)
        let nart = NSMutableAttributedString(string: art)
        nart.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.detailLabel, range: range)
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

}
