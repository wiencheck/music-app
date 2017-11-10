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
        self.artworkImage.image = album.artwork?.image(at: artworkImage.bounds.size) ?? #imageLiteral(resourceName: "no_music")
        if songsCount > 1{
            detailLabel.text = "\(songsCount) songs"
        }else{
            detailLabel.text = "1 song"
        }
        titleLabel.text = album.name
    }
    /*
    func setup(artist: Artist){
        let albumsCount = artist.albumsIn
        let songsCount = artist.songsIn
        self.artistLabel.text = artist.name
        if(albumsCount == 1 && songsCount == 1){
            self.detailLabel.text = "1 album 1 song"
        }else if(albumsCount == 1 && songsCount > 1){
            self.detailLabel.text = "1 album \(songsCount) songs"
        }else if(albumsCount > 1 && songsCount > 1){
            self.detailLabel.text = "\(albumsCount) albums \(songsCount) songs"
        }
        let image = artist.artwork
        artistImage.image = image?.image(at: artistImage.bounds.size) ?? #imageLiteral(resourceName: "no_music")
    }
    */
}
