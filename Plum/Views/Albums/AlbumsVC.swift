//
//  AlbumsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 31.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsVC: UIViewController {
    
    var grid: Bool!
    let player = Plum.shared
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    var albums: [AlbumB]!
    var indexes = [String]()
    var result = [String: [AlbumB]]()
    var picked: AlbumB!
    var gesture: UILongPressGestureRecognizer!
    var cellTypes = [[Int]]()
    var activeSection = 0
    var activeRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        grid = GlobalSettings.albumsGrid
        if grid{
            setCollection()
        }else{
            setTable()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        if grid != GlobalSettings.albumsGrid{
            self.viewDidLoad()
        }
    }
    
    func setTable(){
        setup()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        self.view.addSubview(tableView)
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        tableIndexView.setup()
        self.view.addSubview(tableIndexView)
    }
    
    func setCollection(){
        setup()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        correctCollectionSections()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        self.view.addSubview(collectionView)
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gesture.minimumPressDuration = 0.2
        gesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(gesture)
        self.collectionIndexView.indexes = self.indexes
        self.collectionIndexView.collectionView = self.collectionView
        self.collectionIndexView.setup()
        self.view.addSubview(collectionIndexView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.received = self.picked
        }
    }
    
    @IBAction func NPBtnPressed(_ sender: Any){
        
    }

}

extension AlbumsVC: UITableViewDelegate, UITableViewDataSource{     //Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumCell
        cell.setup(album: (result[indexes[indexPath.section]]?[indexPath.row])!)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = result[indexes[indexPath.section]]?[indexPath.row]
        picked = album
        performSegue(withIdentifier: "album", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
            self.picked = self.result[self.indexes[path.section]]?[path.row]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.picked = self.result[self.indexes[path.section]]?[path.row]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        next.backgroundColor = .orange
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.picked = self.result[self.indexes[path.section]]?[path.row]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }

}

extension AlbumsVC: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, CollectionActionCellDelegate{       //Collection
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if cellTypes[indexPath.section][indexPath.row] == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumsCollectionCell
            cell.setup(album: (result[indexes[indexPath.section]]?[indexPath.row])!)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "queueCell", for: indexPath) as! CollectionActionCell
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = result[indexes[indexPath.section]]?[indexPath.row]
        picked = album
        performSegue(withIdentifier: "album", sender: nil)
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
                picked = result[indexes[activeSection]]?[activeRow]
                collectionView.reloadItems(at: [path])
                gesture.removeTarget(self, action: #selector(longPress(_:)))
            }
        }else if sender.state == .ended {
            print("ended")
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
    
    func cell(_ cell: CollectionActionCell, action: CollectionAction) {
        switch action {
        case .now:
            playNow()
        case .next:
            playNext()
        case .shuffle:
            shuffle()
        }
        cellTypes[activeSection][activeRow] = 0
        let path = IndexPath(row: activeRow, section: activeSection)
        collectionView.reloadItems(at: [path])
        collectionView.deselectItem(at: path, animated: true)
        gesture.addTarget(self, action: #selector(longPress(_:)))
    }
    
}

extension AlbumsVC{     //Other functions
    
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
    
    func correctCollectionSections(){
        var tmp: AlbumB!
        for sect in 0 ..< indexes.count - 1{
            if (result[indexes[sect]]?.count)! % 3 == 1{
                if sect != indexes.count-1{
                    tmp = result[indexes[sect]]?.last
                    result[indexes[sect + 1]]?.insert(tmp!, at: 0)
                    result[indexes[sect]]?.removeLast()
                }
            }else if (result[indexes[sect]]?.count)! % 3 == 2{
                tmp = result[indexes[sect]]?.last
                result[indexes[sect + 1]]?.insert(tmp!, at: 0)
                result[indexes[sect]]?.removeLast()
                tmp = result[indexes[sect]]?.last
                result[indexes[sect + 1]]?.insert(tmp!, at: 0)
                result[indexes[sect]]?.removeLast()
            }
        }
        
//        var tmp: Artist!
//        for sect in 0 ..< indexes.count{
//            if (result[indexes[sect]]?.count)! % 3 == 1{
//                if sect != indexes.count-1{
//                    tmp = result[indexes[sect]]?.last
//                    result[indexes[sect + 1]]?.insert(tmp!, at: 0)
//                    result[indexes[sect]]?.removeLast()
//                }
//            }else if (result[indexes[sect]]?.count)! % 3 == 2{
//                tmp = result[indexes[sect]]?.last
//                result[indexes[sect + 1]]?.insert(tmp!, at: 0)
//                result[indexes[sect]]?.removeLast()
//                tmp = result[indexes[sect]]?.last
//                result[indexes[sect + 1]]?.insert(tmp!, at: 0)
//                result[indexes[sect]]?.removeLast()
//            }
//        }
    }
    
    func setup(){
        let letters = Array("aąbcćdeęfghijklmnoópqrsśtuvwxyzżź".characters)
        let numbers = Array("0123456789".characters)
        albums = musicQuery.shared.albums
        let bcount = albums.count
        result["#"] = []
        result["?"] = []
        var inLetters = 0
        var stoppedAt = 0
        while inLetters < letters.count{
            let smallLetter = letters[inLetters]
            let letter = String(letters[inLetters]).uppercased()
            result[letter] = []
            for i in stoppedAt ..< bcount{
                let curr = albums[i]
                let layLow = curr.name?.lowercased()
                if layLow?.firstLetter() == smallLetter{
                    result[letter]?.append(curr)
                    if !indexes.contains(letter) {indexes.append(letter)}
                }else if numbers.contains((layLow!.firstLetter())){
                    result["#"]?.append(curr)
                    if !indexes.contains("#") {indexes.append("#")}
                }else if layLow?.firstLetter() == "_"{
                    result["?"]?.append(curr)
                    if !indexes.contains("?") {indexes.append("?")}
                }else{
                    //print("stopped at: \(curr.name)")
                    stoppedAt = i
                    break
                }
            }
            inLetters += 1
        }
    }
    
}

extension AlbumsVC: UITabBarControllerDelegate {
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
