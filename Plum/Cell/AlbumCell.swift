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
        let genre = album.items[0].genre ?? ""
        if genre != "" {
            if songsCount > 1{
                detailLabel.text = "\(genre) ･ \(songsCount) songs"
            }else{
                detailLabel.text = "\(genre) ･ 1 song"
            }
        }else{
            if songsCount > 1{
                detailLabel.text = "\(songsCount) songs"
            }else{
                detailLabel.text = "1 song"
            }
        }
        titleLabel.text = album.name
    }
    
    
}
