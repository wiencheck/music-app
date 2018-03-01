//
//  PlaylistInfoCell.swift
//  Plum
//
//  Created by Adam Wienconek on 27.02.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class PlaylistInfoCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    func setup(list: Playlist) {
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        mainLabel.textColor = UIColor.mainLabel
        detailLabel.textColor = UIColor.detailLabel
        textView.textColor = UIColor.detailLabel
        artwork.image = list.image
        textView.text = list.userDescription
        mainLabel.text = list.name
        backgroundImage.image = list.image
        if GlobalSettings.theme == .dark {
            toolbar.barStyle = .blackTranslucent
        }else{
            toolbar.barStyle = .default
        }
        detailLabel.text = "\(list.songsIn) songs, \(list.albumsIn) albums"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
