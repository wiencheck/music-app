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
    let player = Plum.shared
    let defaults = UserDefaults.standard
    
    var cellTypes = [[Int]]()
    var searchCellTypes = [Int]()
    var searchActiveRow = 0
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
    var filteredPlaylists = [Playlist]()
    var searchController: UISearchController!
    var shouldShowResults = false
    var headers: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        grid = GlobalSettings.playlistsGrid
        if grid{
            setCollection()
        }else{
            setTable()
        }
        setHeaders()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        self.definesPresentationContext = true
        if grid != GlobalSettings.playlistsGrid{
            self.viewDidLoad()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.definesPresentationContext = false
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
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    func setCollection(){
        self.collectionView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
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
        collectionView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
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
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredPlaylists.count
        }else{
            return (result[indexes[section]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldShowResults {
            return 0
        }else{
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowResults {
            return UIView()
        }else{
            return headers[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! ArtistCell
            let item = filteredPlaylists[indexPath.row]
            cell.setup(list: item)
            cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! ArtistCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            cell.setup(list: item!)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            pickedList = filteredPlaylists[indexPath.row]
        }else{
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            pickedList = item
        }
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
        if shouldShowResults {
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.pickedList = self.filteredPlaylists[path.row]
                self.playNow()
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
                self.pickedList = self.filteredPlaylists[path.row]
                self.playNext()
                self.tableView.setEditing(false, animated: true)
            })
            next.backgroundColor = .orange
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.pickedList = self.filteredPlaylists[path.row]
                self.shuffle()
                self.tableView.setEditing(false, animated: true)
            })
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }else{
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
}

extension PlaylistsVC: UICollectionViewDelegate, UICollectionViewDataSource, CollectionActionCellDelegate, UIGestureRecognizerDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredPlaylists.count
        }else{
            return (result[indexes[section]]?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowResults {
            if searchCellTypes[indexPath.row] != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "queueCell", for: indexPath) as! CollectionActionCell
                cell.delegate = self
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlistCell", for: indexPath) as! PlaylistCell
                cell.setup(list: filteredPlaylists[indexPath.row])
                return cell
            }
        }else{
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if shouldShowResults {
            pickedList = filteredPlaylists[indexPath.row]
        }else{
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            pickedList = item
        }
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
        if shouldShowResults {
            searchCellTypes[searchActiveRow] = 0
            let path = IndexPath(row: searchActiveRow, section: 0)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
        }else{
            cellTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
        }
        gesture.addTarget(self, action: #selector(longPress(_:)))
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if shouldShowResults {
            if searchCellTypes[searchActiveRow] != 0 {
                searchCellTypes[searchActiveRow] = 0
                collectionView.reloadItems(at: [IndexPath(row: searchActiveRow, section: 0)])
            }
            if sender.state == .began {
                let point = sender.location(in: collectionView)
                if let path = collectionView.indexPathForItem(at: point) {
                    searchActiveRow = path.row
                    searchCellTypes[searchActiveRow] = 1
                    pickedList = filteredPlaylists[searchActiveRow]
                    collectionView.reloadItems(at: [path])
                    sender.removeTarget(self, action: #selector(longPress(_:)))
                }
            }
        }else{
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
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shouldShowResults {
            if grid {
                searchCellTypes[searchActiveRow] = 0
                let path = IndexPath(row: searchActiveRow, section: 0)
                collectionView.reloadItems(at: [path])
                collectionView.deselectItem(at: path, animated: true)
                gesture.addTarget(self, action: #selector(longPress(_:)))
            }
        }else{
            if grid {
                cellTypes[activeSection][activeRow] = 0
                let path = IndexPath(row: activeRow, section: activeSection)
                collectionView.reloadItems(at: [path])
                collectionView.deselectItem(at: path, animated: true)
                gesture.addTarget(self, action: #selector(longPress(_:)))
            }
        }
    }
    
}

extension PlaylistsVC {
    
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

extension PlaylistsVC: UITabBarControllerDelegate {
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

extension PlaylistsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for playlist"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        self.searchController.hidesNavigationBarDuringPresentation = false;
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController?.searchBar
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if grid {
            collectionView.reloadData()
        }else{
            tableView.reloadData()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
        if grid {
            collectionIndexView.isHidden = false
        }else{
            tableIndexView.isHidden = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowResults {
            shouldShowResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == ""{
            shouldShowResults = false
        }else{
            shouldShowResults = true
            self.tableView.separatorStyle = .singleLine
            if grid && filteredPlaylists.count != 0 {
                if filteredPlaylists.count != 0 {
                    collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }else if !grid && filteredPlaylists.count != 0 {
                    tableView.scrollToRow(at: IndexPath(row:0, section: 0), at: .top, animated: false)
                }
            }
        }
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchString!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        var searchItemsPredicate = [NSPredicate]()
        
        let songsMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            let titleExpression = NSExpression(forKeyPath: "name")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: songsMatchPredicates)
        
        
        filteredPlaylists = (playlists.filter { finalCompoundPredicate.evaluate(with: $0) })
        self.tableView.reloadData()
        if filteredPlaylists.count != 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -104 {
            searchController.searchBar.becomeFirstResponder()
        }else if scrollView.contentOffset.y > 1 {
            searchController.searchBar.resignFirstResponder()
        }
    }
    
}

extension PlaylistsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.view.frame.size.height
        let width = self.view.frame.size.width
        let Waspect: CGFloat = 0.45
        let Haspect: CGFloat = 0.35
        return CGSize(width: width*Waspect, height: height*Haspect)
    }
    
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if shouldShowResults {
            let u = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            u.alpha = 0.0
     return u
        }else{
            if kind == UICollectionElementKindSectionHeader {
                let u = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
                u.addSubview(headers[indexPath.section])
                return u
            }else{
                return UICollectionReusableView()
            }
        }
    }*/
    
    func setHeaders() {
        headers = [UIView]()
        for index in indexes {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 27))
            v.backgroundColor = .clear
            let label = UILabel(frame: CGRect(x: 12, y: 3, width: v.frame.width, height: 21))
            let imv = UIImageView(frame: v.frame)
            imv.contentMode = .scaleToFill
            imv.image = #imageLiteral(resourceName: "headerBack")
            v.addSubview(imv)
            label.text = index
            label.textColor = .black
            v.addSubview(label)
            headers.append(v)
        }
    }
    
}
