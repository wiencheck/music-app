//
//  TableIndexView.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class TableIndexView: UIView {
    
    var indexes: [String]!
    var tableView: UITableView!
    //var result: [String: [String]]!
    
    func setup() {
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.indexBackground
        translatesAutoresizingMaskIntoConstraints = false
        var views = [String:UILabel]()
        var verticalLayoutString = "V:|"
        
        for i in 0..<indexes.count {
            let label = UILabel(frame: CGRect(x: 0, y: i * 20, width: 20, height: 20))
            label.text = indexes[i]
            label.textColor = GlobalSettings.tint.color
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            views["label\(i)"] = label
            
            if i == 0 {
                verticalLayoutString += "[label\(i)]"
            }
            else {
                verticalLayoutString += "[label\(i)(==label0)]"
            }
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label\(i)]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: [:], views: views))
        }
        
        verticalLayoutString += "|"
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString, options: NSLayoutFormatOptions.alignAllCenterX, metrics: [:], views: views))
        
        let gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(indexViewWasDragged))
        addGestureRecognizer(gestureRecogniser)
        self.alpha = 0.02
        //self.alpha = 0.0
    }
    
    @objc func indexViewWasDragged(_ gesture: UIPanGestureRecognizer){
        if gesture.state == .began{
            show()
        }else if gesture.state == .ended{
            hide()
        }else{
            let point = gesture.location(in: self)
            let index = max(min(Int(point.y / frame.height * CGFloat(indexes.count)), indexes.count-1), 0)
            let percentInSection = max(point.y / frame.height * CGFloat(indexes.count) - CGFloat(index), 0)
            scrollToIndex(index, percentInSection: percentInSection)
        }
    }
    
    func scrollToIndex(_ index: Int, percentInSection: CGFloat) {
        var section = index
        var rows = self.tableView.dataSource!.tableView(tableView, numberOfRowsInSection: section)
        var row = Int(CGFloat(rows) * percentInSection)
        let numberOfSectionsInTable = tableView.dataSource!.numberOfSections!(in: tableView)
        
        while (rows == 0 && section < numberOfSectionsInTable-1) {
            section += 1
            rows = self.tableView.dataSource!.tableView(tableView, numberOfRowsInSection: section)
            row = 0
        }
        
        if (rows != 0 && row < rows) {
            let indexPath = IndexPath(row: row, section: section)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func show(){
        self.alpha = 1.0
    }
    
    func hide(){
        self.alpha = 0.02
    }
}
