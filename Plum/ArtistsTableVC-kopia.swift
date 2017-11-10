//
//  AlbumArtistsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 28.08.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumArtistsVC: UITableViewController {
    
    var pickedID: MPMediaEntityPersistentID!
    var titles = [String]()
    var result = [String:[Artist]]()
    var artists = [Artist]()
    var art = [MPMediaItemCollection]()

    @IBOutlet weak var NPBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.navigationController?.view.backgroundColor = UIColor.white
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        //return "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".characters.map({ String($0) })
        return titles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return titles.index(of: title)!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[titles[section]]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistCell
        //cell.setup(collection: (result[titles[indexPath.section]]?[indexPath.row].collection)!)
        cell.setup(artist: (result[titles[indexPath.section]]?[indexPath.row])!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickedID = result[titles[indexPath.section]]?[indexPath.row].ID
        if(musicQuery().artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery().artistAlbumsID(artist: pickedID).first?.ID
            performSegue(withIdentifier: "album", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = pickedID
        }else if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }
    }
    @IBAction func NPBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNP", sender: nil)
    }

    func setup(){
        var alphabet = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz".characters.map({ String($0) })
        artists = musicQuery().allArtistsB()
        var inAlphabet = 0
        var bigLetter: String
        var smallLetter: String
        var stoppedAt = 0
        let bcount = artists.count
        result["#"] = []
        while(inAlphabet < alphabet.count){
            bigLetter = alphabet[inAlphabet]
            smallLetter = alphabet[inAlphabet+1]
            result[bigLetter] = []
            for i in stoppedAt ..< bcount{
                bigLetter = alphabet[inAlphabet]
                smallLetter = alphabet[inAlphabet+1]
                let curr = artists[i]
                if curr.name.hasPrefix(bigLetter) || curr.name.hasPrefix(smallLetter) || curr.name.hasPrefix("The \(bigLetter)") || curr.name.hasPrefix("The \(smallLetter)"){
                    result[bigLetter]?.append(artists[i])
                    titles.append(bigLetter)
                }else if curr.name.hasPrefix("0") || curr.name.hasPrefix("1") || curr.name.hasPrefix("2") || curr.name.hasPrefix("3") || curr.name.hasPrefix("4") || curr.name.hasPrefix("5") || curr.name.hasPrefix("6") || curr.name.hasPrefix("7") || curr.name.hasPrefix("8") || curr.name.hasPrefix("9"){
                    result["#"]?.append(artists[i])
                }
                else{
                    stoppedAt = i
                    break
                }
            }
            inAlphabet += 2
        }
    }
}
