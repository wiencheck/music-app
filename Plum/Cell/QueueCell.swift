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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
            /*switch item.rating {
            case 1:
                self.artist.text = "\(item.artist ?? "Unknown artist") - ★☆☆☆☆"
            case 2:
                self.artist.text = "\(item.artist ?? "Unknown artist") - ★★☆☆☆"
            case 3:
                self.artist.text = "\(item.artist ?? "Unknown artist") - ★★★☆☆"
            case 4:
                self.artist.text = "\(item.artist ?? "Unknown artist") - ★★★★☆"
            case 5:
                self.artist.text = "\(item.artist ?? "Unknown artist") - ★★★★★"
            default:
                self.artist.text = "\(item.artist ?? "Unknown artist")"
            }*/
        }else{
            self.artist.text = item.artist ?? "Unknown artist"
        }
        self.artwork.image = item.artwork?.image(at: artwork.bounds.size) ?? UIImage(named: "no_music.jpg")
    }
    
    func redText(){
        self.textLabel?.textColor = .red
    }
    
    func blackText(){
        self.textLabel?.textColor = .black
    }

}
