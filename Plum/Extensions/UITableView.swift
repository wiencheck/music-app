//
//  UITableView.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension UITableView {
    func scrollToFirstRow(animated: Bool) {
        scrollToRow(at: IndexPath(row:0, section: 0), at: .top, animated: animated)
    }
}
