//
//  PlaylistsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 02.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistsVC: UIViewController {
    
    var grid: Bool!
    var initialGrid: Bool!
    
    var indexes = [String]()
    var result = [String: [Playlist]]()
    var playlists: [Playlist]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    var pickedID: MPMediaEntityPersistentID!
    var pickedList: Playlist!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        readSettings()
        if grid{
            setCollection()
        }else{
            setTable()
        }
        initialGrid = grid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        readSettings()
        if initialGrid != grid{
            initialGrid = grid
            self.viewDidLoad()
        }
    }
    
    func setTable(){
        self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        setup()
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        
        tableIndexView.setup()
        self.view.addSubview(tableIndexView)
    }
    
    func setCollection(){
        self.collectionView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        setup()
        correctCollectionSections()
        collectionIndexView.indexes = self.indexes
        collectionIndexView.collectionView = self.collectionView
        
        collectionIndexView.setup()
        self.view.addSubview(collectionIndexView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let d = segue.destination as? PlaylistVC{
            d.receivedList = self.pickedList
        }
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
        
    }

}

extension PlaylistsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        cell.textLabel?.text = item?.name
        cell.detailTextLabel?.text = "\(item?.songsIn)"
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        //pickedID = item?.ID
        pickedList = item
        performSegue(withIdentifier: "playlist", sender: nil)
    }
    
}

extension PlaylistsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlistCell", for: indexPath) as! PlaylistCell
        cell.setup(list: (result[indexes[indexPath.section]]?[indexPath.row])!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        pickedList = item
        performSegue(withIdentifier: "playlist", sender: nil)
    }
}

extension PlaylistsVC {
    
    func readSettings(){
        let defaults = UserDefaults.standard
        if let val = defaults.value(forKey: "playlistsGrid") as? Bool{
            grid = val
        }else{
            print("Value not found!")
        }
    }
    
    func correctCollectionSections(){
        for sect in 0 ..< indexes.count{
            if (result[indexes[sect]]?.count)! % 2 == 1{
                if sect != indexes.count-1{
                    let tmp = result[indexes[sect]]?.last
                    result[indexes[sect + 1]]?.insert(tmp!, at: 0)
                    result[indexes[sect]]?.removeLast()
                }
            }
        }
    }
    
    func setup(){
        let letters = Array("aąbcćdeęfghijklmnoópqrsśtuvwxyzżź".characters)
        let numbers = Array("0123456789".characters)
        playlists = musicQuery.shared.playlists
        let bcount = playlists.count
        result["#"] = []
        result["?"] = []
        var inLetters = 0
        var stoppedAt = 0
        while inLetters < letters.count{
            let smallLetter = letters[inLetters]
            let letter = String(letters[inLetters]).uppercased()
            result[letter] = []
            for i in stoppedAt ..< bcount{
                let curr = playlists[i]
                let layLow = curr.name.lowercased()
                if layLow.firstLetter() == smallLetter{
                    result[letter]?.append(curr)
                    if !indexes.contains(letter) {indexes.append(letter)}
                }else if numbers.contains((layLow.firstLetter())){
                    result["#"]?.append(curr)
                    if !indexes.contains("#") {indexes.append("#")}
                }else if layLow.firstLetter() == "_"{
                    result["?"]?.append(curr)
                    if !indexes.contains("?") {indexes.append("?")}
                }else{
                    stoppedAt = i
                    break
                }
            }
            inLetters += 1
        }
    }
    
}
