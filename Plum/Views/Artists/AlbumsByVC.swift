//
//  ArtistAlbumsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsByVC: UITableViewController {
    
    var receivedID: MPMediaEntityPersistentID!
    var als: [AlbumB]!
    var pickedID: MPMediaEntityPersistentID!

    @IBOutlet weak var upperBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        als = musicQuery.shared.artistAlbumsID(artist: receivedID)
        als = als.sorted(by:{ ($0.name! > $1.name!)})
        als.reverse()
        upperBar.title = als.first?.artist
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return als.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "allSongsCell", for: indexPath)
            cell.textLabel?.text = "All songs"
            cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell
            cell?.setup(album: als[indexPath.row - 1])
            cell?.backgroundColor = .clear
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }else {
            return 94
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            performSegue(withIdentifier: "allSongs", sender: nil)
        }else{
            pickedID = als[indexPath.row - 1].ID
            performSegue(withIdentifier: "album", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }else if let destination = segue.destination as? ArtistSongs{
            destination.receivedID = receivedID
        }
    }
    @IBAction func NPBtnPressed(_ sender: Any) {
        
    }

}
