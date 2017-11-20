//
//  SearchHeader.swift
//  wiencheck
//
//  Created by Adam Wienconek on 07.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class SearchHeader: UITableViewCell {
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    var callback: ((SearchHeader) -> ())?
    func setup(title: String, count: Int){
        if count > 0 {
            label.text = "\(count) \(title)"
        }else{
            label.text = "\(title)"
        }
        if count > 3{
            moreBtn.isHidden = false
            moreBtn.setTitle("show more", for: .normal)
            moreBtn.addTarget(self, action: #selector(buttonPressed(_:)), for: UIControlEvents.touchUpInside)
        }else{
            moreBtn.isHidden = true
        }
    }
    
    @objc func buttonPressed(_ sender: UIButton){
        callback?(self)
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
