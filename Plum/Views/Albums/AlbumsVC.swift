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
    var initialGrid: Bool!
    let player = Plum.shared
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    var albums: [AlbumB]!
    var indexes = [String]()
    var result = [String: [AlbumB]]()
    var picked: AlbumB!
    var selected: AlbumB!

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
        self.view.addSubview(collectionView)
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
            self.selected = self.result[self.indexes[path.section]]?[path.row]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.selected = self.result[self.indexes[path.section]]?[path.row]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        next.backgroundColor = .orange
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.selected = self.result[self.indexes[path.section]]?[path.row]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }

}

extension AlbumsVC: UICollectionViewDelegate, UICollectionViewDataSource{       //Collection
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumsCollectionCell
        cell.setup(album: (result[indexes[indexPath.section]]?[indexPath.row])!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = result[indexes[indexPath.section]]?[indexPath.row]
        picked = album
        performSegue(withIdentifier: "album", sender: nil)
    }
    
}

extension AlbumsVC{     //Other functions
    
    func playNow() {
        let items = selected.items
        player.createDefQueue(items: items)
        player.defIndex = 0
        player.playFromDefQueue(index: 0, new: true)
        player.play()
    }
    
    func playNext() {
        let items = selected.items
        var i = items.count - 1
        while i > -1 {
            player.addNext(item: items[i])
            i -= 1
        }
    }
    
    func shuffle() {
        let items = selected.items
        player.createDefQueue(items: items)
        player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
    
    func readSettings(){
        let defaults = UserDefaults.standard
        if let val = defaults.value(forKey: "albumsGrid") as? Bool{
            if val{
                grid = true
            }else{
                grid = false
            }
        }else{
            print("Value not found!")
        }
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
