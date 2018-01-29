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
    var all: [Playlist]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    @IBOutlet weak var searchView: BlurView!
    var pickedID: MPMediaEntityPersistentID!
    var pickedList: Playlist!
    var gesture: UILongPressGestureRecognizer!
    var filteredPlaylists = [Playlist]()
    var searchController: UISearchController!
    var shouldShowResults = false
    var headers: [UIView]!
    var heightInset: CGFloat!
    var controllerSet = false
    var pickedName: String!
    var hideKeyboard = false
    var currentTheme = GlobalSettings.theme
    var cellSize = CGSize()
    let device = GlobalSettings.device

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        grid = GlobalSettings.playlistsGrid
        setTheme()
        setup()
        if !playlists.isEmpty {
            setupDict()
            indexes.sort { $0 < $1 }
            //setHeaders()
            if !controllerSet {
                configureSearchController()
                controllerSet = true
            }
            if grid{
                setCollection()
                self.collectionIndexView.indexes = self.indexes
                self.collectionIndexView.collectionView = self.collectionView
                self.collectionIndexView.setup()
                view.bringSubview(toFront: searchView)
                view.bringSubview(toFront: collectionIndexView)
            }else{
                setTable()
                tableView.tableFooterView = UIView(frame: .zero)
                tableView.separatorColor = UIColor.lightSeparator
                tableIndexView.indexes = self.indexes
                tableIndexView.tableView = self.tableView
                tableIndexView.setup(color: UIColor.white)
                view.bringSubview(toFront: searchView)
                view.bringSubview(toFront: tableIndexView)
            }
        }
        print("Playlists loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        self.definesPresentationContext = true
        if grid != GlobalSettings.playlistsGrid{
            controllerSet = false
            self.viewDidLoad()
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if grid {
//            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//        }else{
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.definesPresentationContext = false
    }
    
    
    func setTable(){
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        tableIndexView.setup()
        self.view.addSubview(tableIndexView)
    }
    
    func setCollection(){
        cellSize = calculateCollectionViewCellSize(itemsPerRow: 2, frame: self.view.frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        correctCollectionSections()
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
            d.receivedID = self.pickedID
            d.receivedList = pickedList
        }else if let d = segue.destination as? FolderVC {
            d.barTitle = self.pickedName
            d.receivedID = self.pickedID
        }
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
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! ArtistCell
            let item = filteredPlaylists[indexPath.row]
            if currentTheme == .dark {
                cell.setup(list: item, titColor: .white, detColor: .lightText)
            }else{
                cell.setup(list: item, titColor: .black, detColor: .black)
            }
            cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! ArtistCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            if currentTheme == .dark {
                cell.setup(list: item!, titColor: .white, detColor: .lightText)
            }else{
                cell.setup(list: item!, titColor: .black, detColor: .black)
            }
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            let item = filteredPlaylists[indexPath.row]
            pickedID = item.ID
            pickedList = item
            if item.isFolder {
                pickedName = item.name
                performSegue(withIdentifier: "folder", sender: nil)
            }else{
                performSegue(withIdentifier: "playlist", sender: nil)
            }
        }else{
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            pickedID = item?.ID
            pickedList = item
            if (item?.isFolder)! {
                pickedName = item?.name
                performSegue(withIdentifier: "folder", sender: nil)
            }else{
                performSegue(withIdentifier: "playlist", sender: nil)
            }
        }
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
            let item = filteredPlaylists[indexPath.row]
            pickedID = item.ID
            pickedList = item
            if item.isFolder {
                pickedName = item.name
                performSegue(withIdentifier: "folder", sender: nil)
            }else{
                performSegue(withIdentifier: "playlist", sender: nil)
            }
        }else{
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            pickedID = item?.ID
            if (item?.isFolder)! {
                pickedName = item?.name
                performSegue(withIdentifier: "folder", sender: nil)
            }else{
                performSegue(withIdentifier: "playlist", sender: nil)
            }
        }
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
        var to = [String]()
        for index in indexes {
            if (result[index]?.isEmpty)! {
                result.removeValue(forKey: index)
            }
        }
        for index in indexes {
            if let r = result[index] {
                cellTypes.append(Array<Int>(repeating: 0, count: r.count))
                to.append(index)
            }
        }
        self.indexes = to
    }
    
    func setupDict() {
        result = [String: [Playlist]]()
        indexes = [String]()
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in playlists {
            let objStr = song.name.trimmingCharacters(in: .whitespaces)
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result["\(secondStr.uppercased().first!)"] = []
                        result["\(secondStr.uppercased().first!)"]?.append(song)
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                let prefix = "\(article.first!)".uppercased()
                if Int(prefix) != nil {
                    if result["#"] != nil {
                        result["#"]?.append(song)
                    }else{
                        result["#"] = []
                        result["#"]?.append(song)
                        anyNumber = true
                    }
                }else if prefix.firstSpecial() {
                    if result["?"] != nil {
                        result["?"]?.append(song)
                    }else{
                        result["?"] = []
                        result["?"]?.append(song)
                        anySpecial = true
                    }
                }else if result[prefix] != nil {
                    result[prefix]?.append(song)
                }else{
                    result[prefix] = []
                    result[prefix]?.append(song)
                    indexes.append(prefix)
                }
            }
        }
        indexes.sort {
            (s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
        }
        if anyNumber {
            indexes.append("#")
        }
        if anySpecial {
            indexes.append("?")
        }
        playlists.removeAll()
        for index in indexes {
            playlists.append(contentsOf: result[index]!)
        }
        if playlists.isEmpty { indexes.append(" ") }
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
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchView.addSubview(searchController.searchBar)
        
        let attributes: [NSLayoutAttribute] = [.top, .bottom, . left, .right]
        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: self.searchController.searchBar, attribute: $0, relatedBy: .equal, toItem: self.searchView, attribute: $0, multiplier: 1, constant: 0)})
        if device == "iPhone X" {
            if grid {
                heightInset = 136
            }else{
                heightInset = 140
            }
        }else{
            heightInset = 112
        }
        let bottomInset = 49 + GlobalSettings.bottomInset
        automaticallyAdjustsScrollViewInsets = false
        collectionView.contentInset = UIEdgeInsetsMake(heightInset+14, 0, bottomInset, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset+14, 0, bottomInset, 0)
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -174 {
            searchController.searchBar.becomeFirstResponder()
        }else if scrollView.contentOffset.y > -94 {
            if hideKeyboard {
                searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if grid {
            collectionView.reloadData()
            collectionIndexView.isHidden = true
        }else{
            tableView.reloadData()
            tableIndexView.isHidden = true
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        if grid {
            collectionView.reloadData()
            collectionIndexView.isHidden = false
        }else{
            tableView.reloadData()
            tableIndexView.isHidden = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == ""{
            shouldShowResults = false
        }else{
            shouldShowResults = true
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
        
        
        filteredPlaylists = (musicQuery.shared.playlists.filter { finalCompoundPredicate.evaluate(with: $0) })
        searchCellTypes = Array<Int>(repeating: 0, count: filteredPlaylists.count)
        if grid {
            collectionView.reloadData()
            if filteredPlaylists.count != 0 {
                hideKeyboard = false
                collectionView.contentOffset.y = -heightInset + 6
                hideKeyboard = true
            }
        }else{
            tableView.reloadData()
            if filteredPlaylists.count != 0 {
                hideKeyboard = false
                tableView.contentOffset.y = -heightInset
                hideKeyboard = true
            }
        }
    }
    
}

extension PlaylistsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
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
            let tool = UIToolbar(frame: v.frame)
            v.addSubview(tool)
            label.text = index
            label.textColor = .black
            v.addSubview(label)
            v.bringSubview(toFront: label)
            headers.append(v)
        }
    }
    
    func setup() {
        playlists = [Playlist]()
        if musicQuery.shared.playlistsSet {
            for list in musicQuery.shared.playlists {
                if (list.isFolder || !list.isChild) && list.songsIn != 0 {
                    playlists.append(list)
                }
            }
        }else{
            musicQuery.shared.playlistsSet = true
            for list in musicQuery.shared.allPlaylists() {
                if (list.isFolder || !list.isChild) && list.songsIn != 0 {
                    playlists.append(list)
                }
            }
        }
    }
    
    func setTheme() {
        let tool = UIToolbar(frame: searchView.bounds)
        guard let bar = navigationController?.navigationBar else { return }
        switch currentTheme {
        case .light:
            tool.barStyle = .default
            tableIndexView.backgroundColor = UIColor.white
            collectionIndexView.backgroundColor = UIColor.white
            bar.barStyle = .default
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            tableView.backgroundColor = UIColor.lightBackground
            tableView.separatorColor = .lightGray
        case .dark:
            tool.barStyle = .blackTranslucent
            tableIndexView.backgroundColor = UIColor.darkGray
            collectionIndexView.backgroundColor = UIColor.darkGray
            bar.barStyle = .blackTranslucent
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            tableView.backgroundColor = UIColor.darkBackground
            tableView.separatorColor = .black
        default:
            tool.barStyle = .blackTranslucent
            tableIndexView.backgroundColor = UIColor.darkGray
            collectionIndexView.backgroundColor = UIColor.darkGray
            bar.barStyle = .blackTranslucent
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            tableView.backgroundColor = UIColor.lightBackground
            tableView.separatorColor = .lightGray
        }
        searchView.addSubview(tool)
        bar.tintColor = GlobalSettings.tint.color
    }
    
}
