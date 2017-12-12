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
    var searchActiveRow = 0
    var searchController: UISearchController!
    var filteredAlbums = [AlbumB]()
    var cellTypesSearch = [Int]()
    var shouldShowResults = false
    var headers: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        grid = GlobalSettings.albumsGrid
        setupDict()
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
        if grid != GlobalSettings.albumsGrid{
            self.viewDidLoad()
        }
    }
    
    func setTable(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        self.view.addSubview(tableView)
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        tableIndexView.setup()
        self.view.addSubview(tableIndexView)
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    func setCollection(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        //correctCollectionSections()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        self.view.addSubview(collectionView)
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gesture.minimumPressDuration = 0.2
        gesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(gesture)
        self.collectionIndexView.indexes = self.indexes
        self.collectionIndexView.collectionView = self.collectionView
        self.collectionIndexView.setup()
        self.view.addSubview(collectionIndexView)
        collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
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
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredAlbums.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumCell
        if shouldShowResults {
            cell.setup(album: filteredAlbums[indexPath.row])
        }else{
            cell.setup(album: (result[indexes[indexPath.section]]?[indexPath.row])!)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            let album = filteredAlbums[indexPath.row]
            picked = album
        }else{
            let album = result[indexes[indexPath.section]]?[indexPath.row]
            picked = album
        }
        performSegue(withIdentifier: "album", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if shouldShowResults {
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.picked = self.filteredAlbums[indexPath.row]
                self.playNow()
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
                self.picked = self.filteredAlbums[indexPath.row]
                self.playNext()
                self.tableView.setEditing(false, animated: true)
            })
            next.backgroundColor = .orange
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.picked = self.filteredAlbums[indexPath.row]
                self.shuffle()
                self.tableView.setEditing(false, animated: true)
            })
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }else{
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

}

extension AlbumsVC: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, CollectionActionCellDelegate{       //Collection
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredAlbums.count
        }else{
            return (result[indexes[section]]?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowResults {
            if cellTypesSearch[indexPath.row] != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "queueCell", for: indexPath) as! CollectionActionCell
                cell.delegate = self
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumsCollectionCell
                cell.setup(album: filteredAlbums[indexPath.row])
                return cell
            }
        }else{
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if shouldShowResults {
            picked = filteredAlbums[indexPath.row]
        }else{
            let album = result[indexes[indexPath.section]]?[indexPath.row]
            picked = album
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "album", sender: nil)
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if shouldShowResults {
            if cellTypesSearch[searchActiveRow] != 0 {
                cellTypesSearch[searchActiveRow] = 0
                collectionView.reloadItems(at: [IndexPath(row: searchActiveRow, section: 0)])
            }
            if sender.state == .began {
                let point = sender.location(in: collectionView)
                if let path = collectionView.indexPathForItem(at: point) {
                    searchActiveRow = path.row
                    cellTypesSearch[searchActiveRow] = 1
                    picked = filteredAlbums[searchActiveRow]
                    collectionView.reloadItems(at: [path])
                    gesture.removeTarget(self, action: #selector(longPress(_:)))
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
                    picked = result[indexes[activeSection]]?[activeRow]
                    collectionView.reloadItems(at: [path])
                    gesture.removeTarget(self, action: #selector(longPress(_:)))
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shouldShowResults {
            if grid {
                cellTypesSearch[searchActiveRow] = 0
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
    
    func cell(_ cell: CollectionActionCell, action: CollectionAction) {
        switch action {
        case .now:
            playNow()
        case .next:
            playNext()
        case .shuffle:
            shuffle()
        }
        if shouldShowResults {
            cellTypesSearch[searchActiveRow] = 0
            let path = IndexPath(row: searchActiveRow, section: 0)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
            gesture.addTarget(self, action: #selector(longPress(_:)))
        }else{
            cellTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
            gesture.addTarget(self, action: #selector(longPress(_:)))
        }
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

extension AlbumsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for album"
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
        tableIndexView.isHidden = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        if grid {
            collectionView.reloadData()
        }else{
            tableView.reloadData()
        }
        tableIndexView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowResults {
            shouldShowResults = true
            if grid {
                collectionView.reloadData()
            }else{
                tableView.reloadData()
            }
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
            if grid {
                collectionIndexView.isHidden = true
                //collectionView.contentOffset.y = 0
            }else{
                tableIndexView.isHidden = true
                //tableView.contentOffset.y = 0
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
        
        
        filteredAlbums = (albums.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredAlbums.count)
        if grid {
            collectionView.reloadData()
        }else{
            tableView.reloadData()
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

extension AlbumsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.view.frame.size.height
        let width = self.view.frame.size.width
        let Waspect: CGFloat = 0.29
        let Haspect: CGFloat = 0.22
        return CGSize(width: width*Waspect, height: height*Haspect)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    }
    
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

extension AlbumsVC {
    
    func setupDict() {
        albums = musicQuery.shared.albums
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in albums {
            let objStr = song.name!
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "\(secondStr.first!)")
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                let prefix = "\(article.first!)".uppercased()
                if Int(prefix) != nil {
                    if result["#"] != nil {
                        result["#"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "#")
                        anyNumber = true
                    }
                }else if prefix.firstSpecial() {
                    if result["?"] != nil {
                        result["?"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "?")
                        anySpecial = true
                    }
                }else if result[prefix] != nil {
                    result[prefix]?.append(song)
                }else{
                    result.updateValue([song], forKey: prefix)
                    indexes.append(prefix)
                }
            }
        }
        //indexes = Array(result.keys).sorted(by: <)
        if anyNumber {
            indexes.append("#")
        }
        if anySpecial {
            indexes.append("?")
        }
        albums.removeAll()
        for index in indexes {
            albums.append(contentsOf: result[index]!)
        }
        //songs = result.flatMap(){ $0.1 }
    }
}



