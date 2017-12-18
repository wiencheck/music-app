//
//  ArtistCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 03.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistCell: UITableViewCell {
        
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(artist: Artist){
        let albumsCount = artist.albumsIn
        let songsCount = artist.songsIn
        self.artistLabel.text = artist.name
        if(albumsCount == 1 && songsCount == 1){
            self.detailLabel.text = "1 album ･ 1 song"
        }else if(albumsCount == 1 && songsCount > 1){
            self.detailLabel.text = "1 album ･ \(songsCount) songs"
        }else if(albumsCount > 1 && songsCount > 1){
            self.detailLabel.text = "\(albumsCount) albums ･ \(songsCount) songs"
        }
        artistImage.image = artist.artwork
    }
    
    func setup(list: Playlist) {
        if list.isFolder {
            //let songsCount = musicQuery.shared.playlistsForParent(list.ID).count
            artistLabel.text = list.name
            detailLabel.text = "Folder"
            artistImage.image = #imageLiteral(resourceName: "folder")
        }else{
            let songsCount = list.songsIn
            artistLabel.text = list.name
            detailLabel.text = "\(songsCount) songs"
            artistImage.image = list.image
        }
    }

}
