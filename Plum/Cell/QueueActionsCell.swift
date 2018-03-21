//
//  QueueActionsCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 29.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

public enum SongAction{
    case playNow
    case playNext
    case playLast
}

protocol QueueCellDelegate {
    func cell(_ cell: QueueActionsCell, action: SongAction)
}

class QueueActionsCell: UITableViewCell {
    
    public var delegate: QueueCellDelegate?
    
    @IBAction func playNowClicked(_ sender: Any) {
        delegate?.cell(self, action: .playNow)
    }
    
    @IBAction func playNextClicked(_ sender: Any) {
        delegate?.cell(self, action: .playNext)
    }
    
    @IBAction func playLastClicked(_ sender: Any) {
        delegate?.cell(self, action: .playLast)
    }
}
