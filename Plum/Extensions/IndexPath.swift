//
//  IndexPath.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension IndexPath{
    func absoluteRow(_ tableView: UITableView) -> Int{
        var rowCount = 0
        for s in 0 ..< section {
            rowCount += tableView.numberOfRows(inSection: s)
        }
        rowCount += row
        return rowCount
    }
    
    func isFirst() -> Bool {
        return (section == 0 && row == 0)
    }
    
    static let topRow = IndexPath(row: 0, section: 0)
}
