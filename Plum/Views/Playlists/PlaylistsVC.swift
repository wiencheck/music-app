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
    let player = Plum.shared
    
    var cellTypes = [[Int]]()
    var activeSection = 0
    var activeRow = 0
    var indexes = [String]()
    var result = [String: [Playlist]]()
    var playlists: [Playlist]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    var pickedID: MPMediaEntityPersistentID!
    var pickedList: Playlist!
    var gesture: UILongPressGestureRecognizer!

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
        //self.view.addSubview(tableView)
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
        //self.view.addSubview(collectionView)
        print(GlobalSettings.slider.rawValue)
        setup()
        correctCollectionSections()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        collectionIndexView.indexes = self.indexes
        collectionIndexView.collectionView = self.collectionView
        collectionIndexView.setup()
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gesture.minimumPressDuration = 0.3
        gesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(gesture)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! ArtistCell
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        cell.setup(list: item!)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        pickedList = item
        performSegue(withIdentifier: "playlist", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
            self.pickedList = self.result[self.indexes[path.section]]?[path.row]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.pickedList = self.result[self.indexes[path.section]]?[path.row]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        next.backgroundColor = .orange
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.pickedList = self.result[self.indexes[path.section]]?[path.row]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }
}

extension PlaylistsVC: UICollectionViewDelegate, UICollectionViewDataSource, CollectionActionCellDelegate, UIGestureRecognizerDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellTypes[indexPath.section][indexPath.row] != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "queueCell", for: indexPath) as! CollectionActionCell
            cell.delegate = self
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlistCell", for: indexPath) as! PlaylistCell
            cell.setup(list: (result[indexes[indexPath.section]]?[indexPath.row])!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = result[indexes[indexPath.section]]?[indexPath.row]
        pickedList = item
        performSegue(withIdentifier: "playlist", sender: nil)
    }
    
    func cell(_ cell: CollectionActionCell, action: CollectionAction) {
        switch action {
        case .next:
            playNext()
        case .now:
            playNow()
        case .shuffle:
            shuffle()
        }
        cellTypes[activeSection][activeRow] = 0
        let path = IndexPath(row: activeRow, section: activeSection)
        collectionView.reloadItems(at: [path])
        collectionView.deselectItem(at: path, animated: true)
        gesture.addTarget(self, action: #selector(longPress(_:)))
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if cellTypes[activeSection][activeRow] != 0 {
            cellTypes[activeSection][activeRow] = 0
            collectionView.reloadItems(at: [IndexPath(row: activeRow, section: activeSection)])
        }
        if sender.state == .began {
            let point = sender.location(in: collectionView)
            if let path = collectionView.indexPathForItem(at: point) {
                activeRow = path.row
                activeSection = path.section
                cellTypes[activeSection][activeRow] = 1
                pickedList = result[indexes[activeSection]]?[activeRow]
                collectionView.reloadItems(at: [path])
                sender.removeTarget(self, action: #selector(longPress(_:)))
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if grid {
            cellTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
            gesture.addTarget(self, action: #selector(longPress(_:)))
        }
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
    
    func playNow() {
        let items = pickedList.items
        if player.isShuffle {
            player.disableShuffle()
        }
        player.createDefQueue(items: items)
        player.playFromDefQueue(index: 0, new: true)
        player.isShuffle = false
        player.play()
    }
    
    func playNext() {
        let items = pickedList.items
        var i = items.count - 1
        while i > -1 {
            player.addNext(item: items[i])
            i -= 1
        }
    }
    
    func shuffle() {
        let items = pickedList.items
        player.createDefQueue(items: items)
        player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
}
