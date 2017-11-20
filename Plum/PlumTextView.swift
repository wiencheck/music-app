//
//  PlumTextView.swift
//  Plum
//
//  Created by Adam Wienconek on 14.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class PlumTextView: UITextView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}
