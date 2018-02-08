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
    
    let player = Plum.shared
    var receivedID: MPMediaEntityPersistentID!
    var als: [AlbumB]!
    var picked: AlbumB!
    var pickedID: MPMediaEntityPersistentID!
    let defaults = UserDefaults.standard
    var currentSort: Sort!
    @IBOutlet weak var themeBtn: UIBarButtonItem!
    var titleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        //tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        tableView.backgroundColor = UIColor.lightBackground
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *){
            tableView.contentInsetAdjustmentBehavior = .never
        }
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49+GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.separatorColor = UIColor.lightSeparator
        als = musicQuery.shared.artistAlbumsID(artist: receivedID)
        currentSort = GlobalSettings.artistAlbumsSort
        sort()
        setTitleButton()
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        updateTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return als.count + 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }else{
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        next.backgroundColor = .orange
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "allSongsCell", for: indexPath)
            cell.textLabel?.text = "All songs"
            cell.textLabel?.textColor = UIColor.mainLabel
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell
            cell?.setupArtist(album: als[indexPath.row - 1])
            return cell!
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
//        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
//        return v
//    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1
//    }
    
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
    
    func playNow() {
        let items = picked.items
        if player.isShuffle {
            player.disableShuffle()
        }
        player.createDefQueue(items: items)
        player.playFromDefQueue(index: 0, new: true)
        player.play()
    }
    
    func playNext() {
        let items = picked.items
        var i = items.count - 1
        while i > -1 {
            player.addNext(item: items[i])
            i -= 1
        }
    }
    
    func shuffle() {
        let items = picked.items
        player.createDefQueue(items: items)
        player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }

}

extension AlbumsByVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        if (changed) {
            print("New tab order:")
            for i in 0 ..< viewControllers.count {
                defaults.set(viewControllers[i].tabBarItem.tag, forKey: String(i))
                print("\(i): \(viewControllers[i].tabBarItem.title!) (\(viewControllers[i].tabBarItem.tag))")
            }
        }
    }
}

extension AlbumsByVC { //Sortowanie
    
    @IBAction func sortBtnPressed(){
        presentAlert()
    }
    
    func sort() {
        switch currentSort {
        case .alphabetically:
            als.sort(by:{ ($0.name < $1.name)})
        case .yearAscending:
//            als.sort(by:{
//                guard let year0 = $0.year, let year1 = $1.year else { return false }
//                return year0 < year1
//            })
            als.sort(by:{ ($0.year < $1.year)})
        case .yearDescending:
            als.sort(by:{ ($0.year > $1.year)})
        default:
            print("default")
        }
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Choose sorting method", message: "", preferredStyle: .actionSheet)
        let alpha = UIAlertAction(title: "Alphabetically", style: .default) { _ in
            GlobalSettings.changeArtistAlbumsSort(.alphabetically)
            self.currentSort = .alphabetically
            self.sort()
            self.tableView.reloadData()
        }
        alert.addAction(alpha)
        let yearA = UIAlertAction(title: "Year ascending", style: .default) { _ in
            GlobalSettings.changeArtistAlbumsSort(Sort.yearAscending)
            self.currentSort = .yearAscending
            self.sort()
            self.tableView.reloadData()
        }
        alert.addAction(yearA)
        let yearD = UIAlertAction(title: "Year descending", style: .default) { _ in
            GlobalSettings.changeArtistAlbumsSort(Sort.yearDescending)
            self.currentSort = .yearDescending
            self.sort()
            self.tableView.reloadData()
        }
        alert.addAction(yearD)
        present(alert, animated: true, completion: nil)
    }
    
    func setTitleButton() {
        let attributedH = NSAttributedString(string: "Sort", attributes: [NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
        titleButton = UIButton(type: .system)
        titleButton.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
        titleButton.addTarget(self, action: #selector(sortBtnPressed), for: .touchUpInside)
        titleButton.setAttributedTitle(attributedH, for: .highlighted)
        navigationItem.titleView = titleButton
    }
    
    @objc func updateTheme() {
        guard let bar = navigationController?.navigationBar else { return }
        switch GlobalSettings.theme {
        case .light:
            bar.barStyle = .default
            themeBtn.image = #imageLiteral(resourceName: "light_bar")
            let attributedH = NSAttributedString(string: (als.first?.artist)!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
            titleButton.setAttributedTitle(attributedH, for: .normal)
        case .dark:
            bar.barStyle = .blackTranslucent
            themeBtn.image = #imageLiteral(resourceName: "dark_bar")
            let attributedH = NSAttributedString(string: (als.first?.artist)!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium)])
            titleButton.setAttributedTitle(attributedH, for: .normal)
        default:
            bar.barStyle = .blackTranslucent
        }
        bar.tintColor = GlobalSettings.tint.color
        tableView.backgroundColor = UIColor.background
        tableView.separatorColor = UIColor.separator
        tableView.reloadData()
    }
    
    @IBAction func themeBtnPressed(_ sender: UIBarButtonItem) {
        if GlobalSettings.theme == .dark {
            GlobalSettings.changeTheme(.light)
        }else{
            GlobalSettings.changeTheme(.dark)
        }
    }
}
