//
//  ArtistsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 31.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistsVC: UIViewController, UIGestureRecognizerDelegate {
    
    var grid: Bool!
    var initialGrid: Bool!
    
    var collectionTypes = [[Int]]()
    var tableTypes = [[Int]]()
    var activeSection = 0
    var activeRow = 0
    var indexes = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var NPBtn: UIBarButtonItem!
    var pickedID: MPMediaEntityPersistentID!
    var result = [String:[Artist]]()
    var artists = [Artist]()

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
        //self.tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        setup2()
        for i in 0 ..< tableView.numberOfSections {
            tableTypes.append(Array<Int>(repeating: 0, count: tableView.numberOfRows(inSection: i)))
        }
        if GlobalSettings.slider == .alphabetical {
            tableIndexView.indexes = self.indexes
            tableIndexView.tableView = self.tableView
            tableIndexView.setup()
            self.view.addSubview(tableIndexView)
        }else{
            tableView.addScrollBar(tint: GlobalSettings.tint.color)
        }
    }
    
    func setCollection(){
        self.collectionView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        //self.collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.2
        longPress.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(longPress)
        setup2()
        for i in 0 ..< collectionView.numberOfSections {
            collectionTypes.append(Array<Int>(repeating: 0, count: collectionView.numberOfItems(inSection: i)))
        }
        //correctCollectionSections()
        if GlobalSettings.slider == .alphabetical {
            collectionIndexView.indexes = self.indexes
            collectionIndexView.collectionView = self.collectionView
            collectionIndexView.setup()
            self.view.addSubview(collectionIndexView)
        }else{
            collectionView.addScrollBar(tint: GlobalSettings.tint.color)
        }
    }
    
}

extension ArtistsVC: UITableViewDelegate, UITableViewDataSource{    //Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistCell
        cell.setup(artist: (result[indexes[indexPath.section]]?[indexPath.row])!)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickedID = result[indexes[indexPath.section]]?[indexPath.row].ID
        if(musicQuery().artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery().artistAlbumsID(artist: pickedID).first?.ID
            performSegue(withIdentifier: "album", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ArtistsVC: UICollectionViewDelegate, UICollectionViewDataSource, CollectionActionCellDelegate{  //Collection
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return indexes
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contacts = result[indexes[section]]
        return contacts!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionTypes[indexPath.section][indexPath.row] != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionscell", for: indexPath) as! CollectionActionCell
            cell.delegate = self
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            cell.setup(artist: item!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedID = result[indexes[indexPath.section]]?[indexPath.row].ID
        if(musicQuery().artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery().artistAlbumsID(artist: pickedID).first?.ID
            performSegue(withIdentifier: "album", sender: nil)
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if collectionTypes[activeSection][activeRow] != 0 {
            collectionTypes[activeSection][activeRow] = 0
            collectionView.reloadItems(at: [IndexPath(row: activeRow, section: activeSection)])
        }
        if sender.state == .recognized {
            let point = sender.location(in: collectionView)
            if let path = collectionView.indexPathForItem(at: point) {
                activeRow = path.row
                activeSection = path.section
                collectionTypes[activeSection][activeRow] = 1
                pickedID = result[indexes[activeSection]]?[activeRow].ID
                collectionView.reloadItems(at: [path])
            }
        }
    }
    
    func cell(_ cell: CollectionActionCell, action: CollectionAction) {
        switch action {
        case .now:
            playNowBtn()
        case .next:
            playNextBtn()
        case .shuffle:
            shuffleBtn()
        }
    }
    
}

extension ArtistsVC{    //Other functions
    
    func playNowBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        Plum.shared.disableShuffle()
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.playFromDefQueue(index: 0, new: true)
        Plum.shared.play()
        let path = IndexPath(row: activeRow, section: activeSection)
        if grid {
            collectionView.reloadItems(at: [path])
        }else{
            tableView.reloadRows(at: [path], with: .fade)
        }
    }
    
    func playNextBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        var i = songs.count - 1
        while i > -1 {
            Plum.shared.addNext(item: songs[i])
            i -= 1
        }
        let path = IndexPath(row: activeRow, section: activeSection)
        if grid {
            collectionView.reloadItems(at: [path])
        }else{
            tableView.reloadRows(at: [path], with: .fade)
        }
    }
    
    func shuffleBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
        Plum.shared.play()
        let path = IndexPath(row: activeRow, section: activeSection)
        if grid {
            collectionView.reloadItems(at: [path])
        }else{
            tableView.reloadRows(at: [path], with: .fade)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if grid {
            collectionTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
        }else{
            tableTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            tableView.reloadRows(at: [path], with: .fade)
            tableView.deselectRow(at: path, animated: true)
        }
    }
    
        func setup2(){
        let letters = Array("aąbcćdeęfghijklmnoópqrsśtuvwxyzżź".characters)
        let numbers = Array("0123456789".characters)
        artists = musicQuery.shared.artists
        let bcount = artists.count
        result["#"] = []
        result["?"] = []
        var inLetters = 0
        var stoppedAt = 0
        while inLetters < letters.count{
            let smallLetter = letters[inLetters]
            let letter = String(letters[inLetters]).uppercased()
            result[letter] = []
            for i in stoppedAt ..< bcount{
                let curr = artists[i]
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
                    //print("stopped = \(songs[i].title)")
                    break
                }
            }
            inLetters += 1
        }
    }
    
    func readSettings(){
        let defaults = UserDefaults.standard
        if let val = defaults.value(forKey: "artistsGrid") as? Bool{
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
        var tmp: Artist!
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
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let nav = segue.destination as! UINavigationController
        if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = pickedID
        }else if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }
    }

}
