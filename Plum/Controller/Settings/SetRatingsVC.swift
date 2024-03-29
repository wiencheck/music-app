//
//  SetRatingsVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

public enum Rating: String {
    case one = "★☆☆☆☆"
    case two = "★★☆☆☆"
    case three = "★★★☆☆"
    case four = "★★★★☆"
    case five = "★★★★★"
    case stop = "Disable rating mode"
    case previous = "Previous song"
    case show = "Show lyrics"
    case stopLyrics = "Disable lyrics mode"
}

class SetRatingsVC: UITableViewController {
    
    var ratings: [Rating] = [.one, .two, .three, .four, .five, .stop, .previous]
    var active = [Rating]()
    var notActive = [Rating]()

    override func viewDidLoad() {
        super.viewDidLoad()
        for rating in ratings {
            if GlobalSettings.ratings.contains(rating) {
                active.append(rating)
            }else{
                notActive.append(rating)
            }
        }
        clearsSelectionOnViewWillAppear = true
        tableView.setEditing(true, animated: false)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.allowsSelectionDuringEditing = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 4 {
            return "Settings"
        }else if section == 0 {
            return "Active"
        }else{
            return "Not active"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "Unfortunately, Apple does not allow more than three buttons on lockscreen, so please choose the ones which you use most often"
        }else{
            return String()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return 2
        }else if section == 0 {
            return active.count
        }else{
            return notActive.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = active[indexPath.row].rawValue
        }else if indexPath.section == 1{
            cell.textLabel?.text = notActive[indexPath.row].rawValue
        }else{
            if indexPath.row == 0 {
                cell.textLabel?.text = "Ratings in-app and on lockscreen"
            }else{
                cell.textLabel?.text = "Only in app"
            }
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if indexPath.section == 0 {
//            return indexPath
//        }else{
//            return nil
//        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 {
//            return true
//        }else{
//            return false
//        }
        return false
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            GlobalSettings.full = true
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.accessoryType = .none
//        }else{
//            GlobalSettings.full = false
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
//        }
//        //GlobalSettings.changeRating(GlobalSettings.rating, full: GlobalSettings.full)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 {
//            return false
//        }else{
//            return true
//        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if tableView.numberOfRows(inSection: proposedDestinationIndexPath.section) == 3 {
            return IndexPath(row: 0, section: 1)
        }
//        else if proposedDestinationIndexPath.section == 0 {
//            return IndexPath(row: 0, section: 2)
//        }
        else{
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moving: Rating
        if sourceIndexPath.section == 0 {
            moving = active[sourceIndexPath.row]
            active.remove(at: sourceIndexPath.row)
        }else{
            moving = notActive[sourceIndexPath.row]
            notActive.remove(at: sourceIndexPath.row)
        }
        if destinationIndexPath.section == 0 {
            active.insert(moving, at: destinationIndexPath.row)
        }else if destinationIndexPath.section == 1{
            notActive.insert(moving, at: destinationIndexPath.row)
        }
        GlobalSettings.updateRatings(active)
        for rating in GlobalSettings.ratings {
            print(rating.rawValue)
        }
        GlobalSettings.changeRating(!GlobalSettings.rating)
    }

}
