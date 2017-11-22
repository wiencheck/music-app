//
//  artistAlbumCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class artistAlbumCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(collection: MPMediaItemCollection){
        self.textLabel?.text = collection.representativeItem?.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
    }
    
    func setupA(_ album: AlbumB){
        self.textLabel?.text = album.name
    }

}
