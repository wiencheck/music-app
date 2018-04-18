//
//  QueueCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 20.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class QueueCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    var tapCallback: ((QueueCell) -> ())?
    
    func addTap(){
        if self.gestureRecognizers == nil{
            let gesture = UITapGestureRecognizer(target: self, action: #selector(artworkTap(_:)))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            artwork.addGestureRecognizer(gesture)
            artwork.isUserInteractionEnabled = true
        }
    }
    
    @objc func artworkTap(_ sender: UITapGestureRecognizer){
        tapCallback?(self)
    }
    
    func setup(item: MPMediaItem){
        self.title.text = item.title
        if GlobalSettings.rating {
            self.artist.text = "\(item.artist ?? "Unknown artist") - \(item.labelFromRating())"
        }else{
            self.artist.text = item.artist ?? "Unknown artist"
        }
        self.artwork.image = item.artwork?.image(at: artwork.bounds.size) ?? UIImage(named: "no_music.jpg")
    }

}
