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
    let player = Plum.shared
    let defaults = UserDefaults.standard
    
    var searchController: UISearchController!
    var filteredArtists = [Artist]()
    var cellTypesSearch = [Int]()
    var activeSearchRow = 0
    var shouldShowResults = false
    var collectionTypes = [[Int]]()
    var tableTypes = [[Int]]()
    var activeSection = 0
    var activeRow = 0
    var indexes = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionIndexView: CollectionIndexView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var searchView: BlurView!
    var pickedID: MPMediaEntityPersistentID!
    var result = [String:[Artist]]()
    var artists: [Artist]!
    var gesture: UILongPressGestureRecognizer!
    var headers: [UIView]!
    var heightInset: CGFloat!
    var controllerSet = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        grid = GlobalSettings.artistsGrid
        setupDict()
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
            tableIndexView.indexes = self.indexes
            tableIndexView.tableView = self.tableView
            tableIndexView.setup()
            view.bringSubview(toFront: searchView)
            view.bringSubview(toFront: tableIndexView)
        }
        setHeaders()
        print("Artists loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        if grid != GlobalSettings.artistsGrid{
            viewDidLoad()
        }
        if grid {
            collectionView.reloadData()
        }else{
            tableView.reloadData()
        }
    }
    
    func setTable(){
        self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        for i in 0 ..< tableView.numberOfSections {
            tableTypes.append(Array<Int>(repeating: 0, count: tableView.numberOfRows(inSection: i)))
        }
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        tableIndexView.setup()
        self.view.addSubview(tableIndexView)
    }
    
    func setCollection(){
        self.collectionView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gesture.minimumPressDuration = 0.2
        gesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(gesture)
        for i in 0 ..< collectionView.numberOfSections {
            collectionTypes.append(Array<Int>(repeating: 0, count: collectionView.numberOfItems(inSection: i)))
        }
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionIndexView.indexes = self.indexes
        collectionIndexView.collectionView = self.collectionView
        collectionIndexView.setup()
        self.view.addSubview(collectionIndexView)
    }
    
}

extension ArtistsVC: UITableViewDelegate, UITableViewDataSource{    //Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return result.keys.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowResults {
            return UIView()
        }else{
            return headers[section]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldShowResults {
            return 0
        }else{
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredArtists.count
        }else{
            return (result[indexes[section]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if shouldShowResults {
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.pickedID = self.filteredArtists[path.row].ID
                self.playNowBtn()
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {__,path in
                self.pickedID = self.filteredArtists[path.row].ID
                self.playNextBtn()
                self.tableView.setEditing(false, animated: true)
            })
            next.backgroundColor = .orange
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.pickedID = self.filteredArtists[path.row].ID
                self.shuffleBtn()
                self.tableView.setEditing(false, animated: true)
            })
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }else{
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.pickedID = self.result[self.indexes[path.section]]?[path.row].ID
                self.playNowBtn()
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {__,path in
                self.pickedID = self.result[self.indexes[path.section]]?[path.row].ID
                self.playNextBtn()
                self.tableView.setEditing(false, animated: true)
            })
            next.backgroundColor = .orange
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.pickedID = self.result[self.indexes[path.section]]?[path.row].ID
                self.shuffleBtn()
                self.tableView.setEditing(false, animated: true)
            })
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistCell
        if shouldShowResults {
             cell.setup(artist: filteredArtists[indexPath.row])
            cell.backgroundColor = .clear
            return cell
        }else{
            cell.setup(artist: (result[indexes[indexPath.section]]?[indexPath.row])!)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            pickedID = filteredArtists[indexPath.row].ID
        }else{
            pickedID = result[indexes[indexPath.section]]?[indexPath.row].ID
        }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if shouldShowResults {
            let u = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if shouldShowResults {
            return 1
        }else {
            return indexes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredArtists.count
        }else{
            let contacts = result[indexes[section]]
            return contacts!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowResults {
            if cellTypesSearch[indexPath.row] != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionsCell", for: indexPath) as! CollectionActionCell
                cell.delegate = self
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
                let item = filteredArtists[indexPath.row]
                cell.setup(artist: item)
                return cell
            }
        }else{
            if collectionTypes[indexPath.section][indexPath.row] != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionsCell", for: indexPath) as! CollectionActionCell
                cell.delegate = self
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
                let item = result[indexes[indexPath.section]]?[indexPath.row]
                cell.setup(artist: item!)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if shouldShowResults {
            pickedID = filteredArtists[indexPath.row].ID
        }else{
            pickedID = result[indexes[indexPath.section]]?[indexPath.row].ID
        }
        if(musicQuery().artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery().artistAlbumsID(artist: pickedID).first?.ID
            performSegue(withIdentifier: "album", sender: nil)
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if shouldShowResults {
            if cellTypesSearch[activeSearchRow] != 0 {
                cellTypesSearch[activeSearchRow] = 0
                collectionView.reloadItems(at: [IndexPath(row: activeSearchRow, section: 0)])
            }
            if sender.state == .began {
                let point = sender.location(in: collectionView)
                if let path = collectionView.indexPathForItem(at: point) {
                    activeSearchRow = path.row
                    cellTypesSearch[activeSearchRow] = 1
                    pickedID = filteredArtists[activeSearchRow].ID
                    collectionView.reloadItems(at: [path])
                    gesture.removeTarget(self, action: #selector(longPress(_:)))
                }
            }
        }else{
            if collectionTypes[activeSection][activeRow] != 0 {
                collectionTypes[activeSection][activeRow] = 0
                collectionView.reloadItems(at: [IndexPath(row: activeRow, section: activeSection)])
            }
            if sender.state == .began {
                let point = sender.location(in: collectionView)
                if let path = collectionView.indexPathForItem(at: point) {
                    activeRow = path.row
                    activeSection = path.section
                    collectionTypes[activeSection][activeRow] = 1
                    pickedID = result[indexes[activeSection]]?[activeRow].ID
                    collectionView.reloadItems(at: [path])
                    gesture.removeTarget(self, action: #selector(longPress(_:)))
                }
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
        if shouldShowResults {
            cellTypesSearch[activeSearchRow] = 0
            let path = IndexPath(row: activeSearchRow, section: 0)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
        }else{
            collectionTypes[activeSection][activeRow] = 0
            let path = IndexPath(row: activeRow, section: activeSection)
            collectionView.reloadItems(at: [path])
            collectionView.deselectItem(at: path, animated: true)
        }
        gesture.addTarget(self, action: #selector(longPress(_:)))
    }
    
}

extension ArtistsVC{    //Other functions
    
    func playNowBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        if player.isShuffle {
            player.disableShuffle()
        }
        player.createDefQueue(items: songs)
        player.playFromDefQueue(index: 0, new: true)
        player.play()
    }
    
    func playNextBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        var i = songs.count - 1
        while i > -1 {
            player.addNext(item: songs[i])
            i -= 1
        }
    }
    
    func shuffleBtn() {
        let songs = musicQuery.shared.songsByArtistID(artist: pickedID)
        player.createDefQueue(items: songs)
        player.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if grid {
            if shouldShowResults {
                cellTypesSearch[activeSearchRow] = 0
                let path = IndexPath(row: activeSearchRow, section: 0)
                collectionView.reloadItems(at: [path])
                collectionView.deselectItem(at: path, animated: true)
                gesture.addTarget(self, action: #selector(longPress(_:)))
            }else{
                collectionTypes[activeSection][activeRow] = 0
                let path = IndexPath(row: activeRow, section: activeSection)
                collectionView.reloadItems(at: [path])
                collectionView.deselectItem(at: path, animated: true)
                gesture.addTarget(self, action: #selector(longPress(_:)))
            }
        }
    }
    
    func setupDict() {
        result = [String: [Artist]]()
        indexes = [String]()
        if musicQuery.shared.arraysSet {
            artists = musicQuery.shared.artists
        }else{
            artists = musicQuery.shared.allArtists()
        }
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for artist in artists {
            let objStr = artist.name!
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(artist)
                    }else{
                        result.updateValue([artist], forKey: "\(secondStr.first!)")
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                let prefix = "\(article.first!)".uppercased()
                if Int(prefix) != nil {
                    if result["#"] != nil {
                        result["#"]?.append(artist)
                    }else{
                        result.updateValue([artist], forKey: "#")
                        anyNumber = true
                    }
                }else if prefix.firstSpecial() {
                    if result["?"] != nil {
                        result["?"]?.append(artist)
                    }else{
                        result.updateValue([artist], forKey: "?")
                        anySpecial = true
                    }
                }else if result[prefix] != nil {
                    result[prefix]?.append(artist)
                }else{
                    result.updateValue([artist], forKey: prefix)
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
        artists.removeAll()
        for index in indexes {
            artists.append(contentsOf: result[index]!)
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

extension ArtistsVC: UITabBarControllerDelegate {
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

extension ArtistsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for artists"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchView.addSubview(searchController.searchBar)
        let attributes: [NSLayoutAttribute] = [.top, .bottom, . left, .right]
        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: self.searchController.searchBar, attribute: $0, relatedBy: .equal, toItem: self.searchView, attribute: $0, multiplier: 1, constant: 0)})
        heightInset = (navigationController?.navigationBar.frame.height)! + searchController.searchBar.frame.height
        heightInset = 120
        let bottomInset = 49 + GlobalSettings.bottomInset
        automaticallyAdjustsScrollViewInsets = false
        collectionView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
        tableIndexView.isHidden = false
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
            tableIndexView.isHidden = false
        }else{
            shouldShowResults = true
            self.tableView.separatorStyle = .singleLine
            //tableView.contentOffset.y = 0
            tableIndexView.isHidden = true
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
        
        
        filteredArtists = (artists.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredArtists.count)
        if grid {
            collectionView.reloadData()
        }else{
            tableView.reloadData()
        }
//        if filteredArtists.count != 0 {
//            if grid {
//                collectionView.reloadData()
//                collectionView.contentOffset.y = heightInset
//            }else{
//                tableView.reloadData()
//                tableView.contentOffset.y = heightInset
//            }
//        }
    }
    
}

extension ArtistsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.view.frame.size.height
        let width = self.view.frame.size.width
        let Waspect: CGFloat = 0.29
        let Haspect: CGFloat = 0.22
        return CGSize(width: width*Waspect, height: height*Haspect)
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
