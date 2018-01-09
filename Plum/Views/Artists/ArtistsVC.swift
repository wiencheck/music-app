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
    var hideKeyboard = false
    var currentTheme: Theme!
    var searchVisible: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        currentTheme = GlobalSettings.theme
        grid = GlobalSettings.artistsGrid
        if musicQuery.shared.artistsSet {
            artists = musicQuery.shared.artists
        }else{
            artists = musicQuery.shared.allArtists()
        }
        if !artists.isEmpty {
            setupDict()
            searchVisible = true
            if !controllerSet {
                configureSearchController()
                controllerSet = true
            }
            if grid{
                setCollection()
                //correctCollectionSections()
                self.collectionIndexView.indexes = self.indexes
                self.collectionIndexView.collectionView = self.collectionView
                self.collectionIndexView.setup()
                //collectionIndexView.backgroundColor = .clear
                view.bringSubview(toFront: searchView)
                view.bringSubview(toFront: collectionIndexView)
            }else{
                setTable()
                tableIndexView.indexes = self.indexes
                tableIndexView.tableView = self.tableView
                tableIndexView.setup(color: UIColor.white)
                view.bringSubview(toFront: searchView)
                view.bringSubview(toFront: tableIndexView)
            }
            setHeaders()
        }
        print("Artists loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("list", message: "Swipe left on any cell to show more options", completion: nil)
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
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        definesPresentationContext = false
    }
    
    func setTable(){
        //self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        if currentTheme == .dark {
            tableView.backgroundColor = UIColor.darkBackground
            tableView.separatorColor = UIColor.black
        }else{
            tableView.backgroundColor = UIColor.lightBackground
            tableView.separatorColor = UIColor.lightSeparator
        }
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        for i in 0 ..< tableView.numberOfSections {
            tableTypes.append(Array<Int>(repeating: 0, count: tableView.numberOfRows(inSection: i)))
        }
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        tableIndexView.setup(color: UIColor.white)
        self.view.addSubview(tableIndexView)
    }
    
    func setCollection(){
        //self.collectionView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        if currentTheme == .dark {
            collectionView.backgroundColor = UIColor.darkBackground
        }else{
            collectionView.backgroundColor = UIColor.lightBackground
        }
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
            if currentTheme == .dark {
                cell.setup(artist: filteredArtists[indexPath.row], titColor: .white, detColor: .lightText)
            }else{
                cell.setup(artist: filteredArtists[indexPath.row], titColor: .black, detColor: .black)
            }
            return cell
        }else{
            if currentTheme == .dark {
                cell.setup(artist: result[indexes[indexPath.section]]![indexPath.row], titColor: .white, detColor: .lightText)
            }else{
                cell.setup(artist: result[indexes[indexPath.section]]![indexPath.row], titColor: .black, detColor: .black)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            pickedID = filteredArtists[indexPath.row].ID
        }else{
            pickedID = result[indexes[indexPath.section]]?[indexPath.row].ID
        }
        if(musicQuery.shared.artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery.shared.artistAlbumsID(artist: pickedID).first?.ID
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
        if(musicQuery.shared.artistAlbumsID(artist: pickedID).count > 1){
            performSegue(withIdentifier: "artistAlbums", sender: nil)
        }else{
            pickedID = musicQuery.shared.artistAlbumsID(artist: pickedID).first?.ID
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
                        result["\(secondStr.uppercased().first!)"]?.append(artist)
                    }else{
                        result["\(secondStr.uppercased().first!)"] = []
                        result["\(secondStr.uppercased().first!)"]?.append(artist)
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                if let prefi = article.first {
                    let prefix = "\(prefi)".uppercased()
                    if Int(prefix) != nil {
                        if result["#"] != nil {
                            result["#"]?.append(artist)
                        }else{
                            result["#"] = []
                            result["#"]?.append(artist)
                            anyNumber = true
                        }
                    }else if prefix.firstSpecial() {
                        if result["?"] != nil {
                            result["?"]?.append(artist)
                        }else{
                            result["?"] = []
                            result["?"]?.append(artist)
                            anySpecial = true
                        }
                    }else if result[prefix] != nil {
                        result[prefix]?.append(artist)
                    }else{
                        result[prefix] = []
                        result[prefix]?.append(artist)
                        indexes.append(prefix)
                    }
                }
            }
        }
        print(indexes)
        indexes = indexes.sorted {
            (s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
        }
        //indexes.sort(by: <)
        print(indexes)
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
    
    /*func correctCollectionSections(){
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
    }*/
    
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
                collectionTypes.append(Array<Int>(repeating: 0, count: r.count))
                to.append(index)
            }
        }
        self.indexes = to
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
        searchController.searchBar.isTranslucent = true
        searchView.addSubview(searchController.searchBar)
        
        let attributes: [NSLayoutAttribute] = [.top, .bottom, . left, .right]
        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: self.searchController.searchBar, attribute: $0, relatedBy: .equal, toItem: self.searchView, attribute: $0, multiplier: 1, constant: 0)})
        if UIDevice.current.modelName == "iPhone X" {
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
        collectionView.contentInset = UIEdgeInsetsMake(heightInset+4, 0, bottomInset, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset+4, 0, bottomInset, 0)
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -160 {
            searchController.searchBar.becomeFirstResponder()
        }else if scrollView.contentOffset.y > -80 {
            if hideKeyboard {
                searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if grid {
            collectionIndexView.isHidden = true
            collectionView.reloadData()
        }else{
            tableIndexView.isHidden = true
            tableView.reloadData()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        if grid {
            collectionIndexView.isHidden = false
            collectionView.reloadData()
        }else{
            tableIndexView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == ""{
            shouldShowResults = false
            tableIndexView.isHidden = false
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
        
        
        filteredArtists = (artists.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredArtists.count)
        if grid {
            collectionView.reloadData()
            if filteredArtists.count != 0 {
                hideKeyboard = false
                collectionView.contentOffset.y = -heightInset + 6
                hideKeyboard = true
            }
        }else{
            tableView.reloadData()
            if filteredArtists.count != 0 {
                hideKeyboard = false
                tableView.contentOffset.y = -heightInset
                hideKeyboard = true
            }
        }
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
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            let tool = UIToolbar(frame: v.frame)
            v.addSubview(tool)
            label.text = index
            if currentTheme == .dark {
                label.textColor = .white
                tool.barStyle = .blackTranslucent
            }else{
                label.textColor = UIColor.gray
                tool.barStyle = .default
            }
            v.addSubview(label)
            v.bringSubview(toFront: label)
            headers.append(v)
        }
    }
}

extension UIViewController {
    
    func instruct(_ key: String, message: String, completion: (() -> Void)?) {
        if !UserDefaults.standard.bool(forKey: key) {
            let a = UIAlertController(title: "Pro tip", message: message, preferredStyle: .alert)
            let got = UIAlertAction(title: "Got it", style: .default, handler: { _ in
                UserDefaults.standard.set(true, forKey: key)
            })
            let remind = UIAlertAction(title: "Remind me", style: .default, handler: { _ in
                UserDefaults.standard.set(false, forKey: key)
            })
            a.addAction(got)
            a.addAction(remind)
            present(a, animated: true, completion: completion)
        }
    }
}
