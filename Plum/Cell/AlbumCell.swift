//
//  AlbumCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 25.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(album: AlbumB){
        let songsCount = album.songsIn
        self.artworkImage.image = album.artwork
        titleLabel.text = album.name ?? "Unknown album"
        let genre = album.items[0].albumArtist ?? ""
        let attYear = NSMutableAttributedString(string: genre)
        let attYearR = NSRange(location: 0, length: attYear.length)
        attYear.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: attYearR)
        var st = ", "
        let attComa = NSMutableAttributedString(string: st)
        let attComaR = NSRange(location: 0, length: attComa.length)
        attComa.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: attComaR)
        
        //Songs
        let attCount = NSMutableAttributedString(string: "\(songsCount)")
        let attCountR = NSRange(location: 0, length: attCount.length)
        attCount.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: attCountR)
        st = ""
        if songsCount > 1 {
            st = " songs"
        }else{
            st = " song"
        }
        let attSongs = NSMutableAttributedString(string: st)
        let attSongsR = NSRange(location: 0, length: attSongs.length)
        attSongs.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: attSongsR)
        
        attYear.append(attComa)
        attYear.append(attCount)
        attYear.append(attSongs)
        
        detailLabel.attributedText = attYear
    }
    
    func setupArtist(album: AlbumB){
        let songsCount = album.songsIn
        self.artworkImage.image = album.artwork
        titleLabel.text = album.name ?? "Unknown album"
        let genre = album.year ?? ""
        //Year
        let attYear = NSMutableAttributedString(string: genre)
        var attComa = NSMutableAttributedString(string: "")
        var st = ""
        if genre != "" {
            //let attYear = NSMutableAttributedString(string: genre)
            let attYearR = NSRange(location: 0, length: attYear.length)
            attYear.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: attYearR)
            st = ", "
            attComa = NSMutableAttributedString(string: st)
            let attComaR = NSRange(location: 0, length: attComa.length)
            attComa.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: attComaR)
        }
        
        //Songs
        let attCount = NSMutableAttributedString(string: "\(songsCount)")
        let attCountR = NSRange(location: 0, length: attCount.length)
        attCount.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: attCountR)
        st = ""
        if songsCount > 1 {
            st = " songs"
        }else{
            st = " song"
        }
        let attSongs = NSMutableAttributedString(string: st)
        let attSongsR = NSRange(location: 0, length: attSongs.length)
        attSongs.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: attSongsR)
        
        attYear.append(attComa)
        attYear.append(attCount)
        attYear.append(attSongs)
        
        detailLabel.attributedText = attYear
    }
    
    
}
