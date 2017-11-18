//
//  SetRatingsVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class SetRatingsVC: UITableViewController {
    
    var titles = ["1 star", "2 stars", "3 stars", "4 stars", "5 stars", "Show lyrics"]
    var active = [Int]()
    var notActive = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        active.append(0)
        active.append(2)
        active.append(4)
        notActive.append(1)
        notActive.append(3)
        notActive.append(5)
        clearsSelectionOnViewWillAppear = true
        self.tableView.setEditing(true, animated: false)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Active"
        }else{
            return "Not active"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return active.count
        }else{
            return notActive.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = titles[active[indexPath.row]]
        }else{
            cell.textLabel?.text = titles[notActive[indexPath.row]]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 && active.count == 3 {
            return IndexPath(row: 0, section: 1)
        }else{
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var toMove: Int
        if sourceIndexPath.section == 0 {
            toMove = active[sourceIndexPath.row]
            active.remove(at: sourceIndexPath.row)
        }else{
            toMove = notActive[sourceIndexPath.row]
            notActive.remove(at: sourceIndexPath.row)
        }
        if destinationIndexPath.section == 0 {
            active.insert(toMove, at: destinationIndexPath.row)
        }else{
            notActive.insert(toMove, at: destinationIndexPath.row)
        }
        toMove = 0
        tableView.reloadSections([0,1], with: .left)
    }

}
