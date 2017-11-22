//
//  MoreActionsCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 29.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

public enum MoreActions{
    case artist
    case album
}

protocol MoreActionsCellDelegate {
    func cell(_ cell: MoreActionsCell, action: MoreActions)
}

class MoreActionsCell: UITableViewCell {
    
    public var delegate: MoreActionsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func albumPressed(_ sender: UIButton){
        delegate?.cell(self, action: .album)
    }
    
    @IBAction func artistPressed(_ sender: UIButton){
        delegate?.cell(self, action: .artist)
    }

}
