//
//  SongsVC.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer
import LNPopupController

class SongsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, QueueCellDelegate {
    var cellTypes = [[Int]]()
    var indexes = [String]()
    var songs = [MPMediaItem]()
    var result = [String: [MPMediaItem]]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    let defaults = UserDefaults.standard
    var pickedAlbumID: MPMediaEntityPersistentID!
    var pickedArtistID: MPMediaEntityPersistentID!
    var searchController: UISearchController!
    var filteredSongs = [MPMediaItem]()
    var shouldShowResults = false
    var cellTypesSearch = [Int]()
    var searchActiveRow = 0
    var headers: [UIView]!
    var heightInset: CGFloat!
    var hideKeyboard = false
    
    let backround = #imageLiteral(resourceName: "background_se")
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    @IBOutlet weak var searchView: BlurView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        //navigationController?.interactivePopGestureRecognizer?.delegate = nil
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.separatorStyle = .none
        setupDict()
        setHeaders()
        indexes.insert("", at: 0)
        result[""] = [MPMediaItem()]
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        //tableView.backgroundView = UIImageView(image: backround)
        tableView.backgroundColor = UIColor.lightBackground
        //tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "gradient_background"))
        //tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        indexView.indexes = self.indexes
        indexView.tableView = self.tableView
        indexView.setup()
        configureSearchController()
        view.bringSubview(toFront: indexView)
        print("Songs loaded")
        print("Nav:\((navigationController?.navigationBar.frame.height)!)")
        print("search:\(searchView.frame.height)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("songs", message: "Swipe left on a song to quickly go to corresponding album or artist page", completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
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
            if section == 0 {
                return UIView()
            }else{
                return headers[section-1]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredSongs.count
        }else{
            if section == 0 {
                return 1
            }else{
                return (result[indexes[section]]?.count)!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if shouldShowResults {
            let album = UITableViewRowAction(style: .default, title: "Album", handler: {_,path in
                let item = self.filteredSongs[path.row]
                self.pickedAlbumID = item.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.albumBtn()
            })
            album.backgroundColor = .albumGreen
            let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
                let item = self.filteredSongs[path.row]
                self.pickedArtistID = item.albumArtistPersistentID
                self.pickedAlbumID = item.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.artistBtn()
            })
            artist.backgroundColor = .artistBlue
            return [album, artist]
        }else{
            let album = UITableViewRowAction(style: .default, title: "Album", handler: {_,path in
                let item = self.result[self.indexes[path.section]]?[path.row]
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.albumBtn()
            })
            album.backgroundColor = .albumGreen
            let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
                let item = self.result[self.indexes[path.section]]?[path.row]
                self.pickedArtistID = item?.albumArtistPersistentID
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.artistBtn()
            })
            artist.backgroundColor = .artistBlue
            return [album, artist]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowResults {
            if cellTypesSearch[indexPath.row] != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                cell.delegate = self
                cell.backgroundColor = .clear
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                let item = filteredSongs[indexPath.row]
                cell.setup(item: item)
                cell.backgroundColor = .clear
                return cell
            }
        }else{
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath)
                cell.backgroundColor = UIColor(red: 0.964705882352941, green: 0.964705882352941, blue: 0.964705882352941, alpha: 1.0)
                return cell
            }else{
                if(cellTypes[indexPath.section][indexPath.row] == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
                    let item = result[indexes[indexPath.section]]?[indexPath.row]
                    if(item != Plum.shared.currentItem){
                        cell?.setup(item: item!)
                    }else{
                        cell?.setup(item: item!)
                    }
                    cell?.backgroundColor = .clear
                    return cell!
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                    cell?.delegate = self
                    cell?.backgroundColor = .clear
                    return cell!
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowResults {
            return 62
        }else{
            if indexPath.section == 0 {
                return 44
            }else{
                return 62
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            if cellTypesSearch[searchActiveRow] != 0 {
                cellTypesSearch[searchActiveRow] = 0
                tableView.reloadRows(at: [IndexPath(row: searchActiveRow, section: 0)], with: .fade)
            }else{
                searchActiveRow = indexPath.row
                if cellTypesSearch[searchActiveRow] == 0 {
                    if Plum.shared.isPlayin() {
                        cellTypesSearch[searchActiveRow] = 1
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }else{
                        if Plum.shared.isShuffle {
                            Plum.shared.disableShuffle()
                            Plum.shared.createDefQueue(items: songs)
                            let item = filteredSongs[searchActiveRow]
                            for i in 0 ..< songs.count {
                                if item == songs[i] {
                                    absoluteIndex = i
                                    break
                                }
                            }
                            Plum.shared.defIndex = absoluteIndex
                            Plum.shared.shuffleCurrent()
                            Plum.shared.playFromShufQueue(index: 0, new: true)
                        }else{
                            Plum.shared.createDefQueue(items: songs)
                            let item = filteredSongs[searchActiveRow]
                            for i in 0 ..< songs.count {
                                if item == songs[i] {
                                    absoluteIndex = i
                                    break
                                }
                            }
                            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
                        }
                        Plum.shared.play()
                    }
                }else{
                    cellTypesSearch[searchActiveRow] = 0
                    tableView.reloadRows(at: [indexPath], with: .right)
                }
            }
        }else{
            if cellTypes[activeIndexSection][activeIndexRow] != 0 {
                cellTypes[activeIndexSection][activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection+1)], with: .fade)
            }
            if indexPath.section == 0 {
                shuffleAll()
            }else{
                absoluteIndex = indexPath.absoluteRow(tableView) - 1
                activeIndexRow = indexPath.row
                activeIndexSection = indexPath.section
                if(cellTypes[activeIndexSection][activeIndexRow] == 0){
                    if(Plum.shared.isPlayin()){
                        cellTypes[activeIndexSection][activeIndexRow] = 1
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }else{
                        if(Plum.shared.isShuffle){
                            Plum.shared.disableShuffle()
                            Plum.shared.createDefQueue(items: songs)
                            Plum.shared.defIndex = absoluteIndex
                            Plum.shared.shuffleCurrent()
                            Plum.shared.playFromShufQueue(index: 0, new: true)
                        }else{
                            Plum.shared.createDefQueue(items: songs)
                            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
                        }
                        Plum.shared.play()
                    }
                }else{
                    cellTypes[activeIndexSection][activeIndexRow] = 0
                    tableView.reloadRows(at: [indexPath], with: .right)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedAlbumID
        }else if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = pickedArtistID
        }else if let destination = segue.destination as? ArtistSongs {
            destination.receivedID = pickedArtistID
        }
    }
    
    func cell(_ cell: QueueActionsCell, action: SongAction) {
        switch action {
        case .playNow:
            playNowBtn()
        case .playNext:
            playNextBtn()
        case.playLast:
            playLastBtn()
        }
        if shouldShowResults {
            cellTypesSearch[searchActiveRow] = 0
            tableView.reloadRows(at: [IndexPath(row: searchActiveRow, section: 0)], with: .right)
        }else{
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
        }
    }
    
    func playNextBtn() {
        if shouldShowResults {
            Plum.shared.addNext(item: filteredSongs[searchActiveRow])
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
        }
    }
    func playLastBtn() {
        if shouldShowResults {
            Plum.shared.addLast(item: filteredSongs[searchActiveRow])
        }else{
            Plum.shared.addLast(item: songs[absoluteIndex])
        }
    }
    func playNowBtn() {
        if shouldShowResults {
            if Plum.shared.isUsrQueue {
                Plum.shared.clearQueue()
            }
            if Plum.shared.isShuffle {
                let item = filteredSongs[searchActiveRow]
                for i in 0 ..< songs.count {
                    if songs[i] == item {
                        absoluteIndex = i
                        break
                    }
                }
                Plum.shared.disableShuffle()
                Plum.shared.defIndex = absoluteIndex
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.shuffleCurrent()
                Plum.shared.playFromShufQueue(index: 0, new: true)
            }else{
                let item = filteredSongs[searchActiveRow]
                for i in 0 ..< songs.count {
                    if songs[i] == item {
                        absoluteIndex = i
                        break
                    }
                }
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
            }
        }else{
            if(Plum.shared.isUsrQueue){
                Plum.shared.clearQueue()
            }
            if(Plum.shared.isShuffle){
                Plum.shared.disableShuffle()
                Plum.shared.defIndex = absoluteIndex
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.shuffleCurrent()
                Plum.shared.playFromShufQueue(index: 0, new: true)
            }else{
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
            }
        }
        Plum.shared.play()
    }
    func albumBtn(){
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        performSegue(withIdentifier: "artist", sender: nil)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shouldShowResults {
            cellTypesSearch[searchActiveRow] = 0
            let indexPath = IndexPath(row: searchActiveRow, section: 0)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }else{
            cellTypes[activeIndexSection][activeIndexRow] = 0
            //print("section \(activeIndexSection) row \(activeIndexRow)")
            let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension SongsVC {
    
    func setupDict() {
        if musicQuery.shared.songsSet{
            songs = musicQuery.shared.songs
        }else{
            songs = musicQuery.shared.allSongs()
        }
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in songs {
            let objStr = song.title!
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.uppercased().first!)"] != nil {
                        result["\(secondStr.uppercased().first!)"]?.append(song)
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
        if anyNumber {
            indexes.append("#")
        }
        if anySpecial {
            indexes.append("?")
        }
        songs.removeAll()
        for index in indexes {
            songs.append(contentsOf: result[index]!)
        }
    }
    
    func shuffleAll() {
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
        Plum.shared.play()
    }
}

extension String {
    func firstSpecial() -> Bool {
        if prefix(1).rangeOfCharacter(from: NSCharacterSet.alphanumerics.inverted) != nil {
            return true
        }else{
            return false
        }
    }
    
    func firstNumber() -> Bool {
        return Int(prefix(1)) != nil
    }
}

public extension LazyMapCollection  {
    
    func toArray() -> [Element]{
        return Array(self)
    }
}

extension SongsVC: UITabBarControllerDelegate {
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

extension SongsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for songs"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        searchController.searchBar.contentMode = .scaleAspectFill
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchView.frame.size.height = searchController.searchBar.frame.height
        searchView.addSubview(searchController.searchBar)
        
        let attributes: [NSLayoutAttribute] = [.top, .bottom, . left, .right]
        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: self.searchController.searchBar, attribute: $0, relatedBy: .equal, toItem: self.searchView, attribute: $0, multiplier: 1, constant: 0)})
        //heightInset = (navigationController?.navigationBar.frame.height)! + 58
        heightInset = 112
        automaticallyAdjustsScrollViewInsets = false
        let bottomInset = 49 + GlobalSettings.bottomInset
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -160 {
            searchController.searchBar.becomeFirstResponder()
        }
        else if scrollView.contentOffset.y > -heightInset + 20 {
            if hideKeyboard {
                searchController.searchBar.resignFirstResponder()
            }
        }
        //print(scrollView.contentOffset.y)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
        indexView.isHidden = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
        indexView.isHidden = false
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
            let titleExpression = NSExpression(forKeyPath: "title")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: songsMatchPredicates)
        
        
        filteredSongs = (songs.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredSongs.count)
        tableView.reloadData()
        if filteredSongs.count != 0 {
            hideKeyboard = false
            tableView.contentOffset.y = -heightInset
            hideKeyboard = true
        }
//        if filteredSongs.count != 0 {
//            tableView.reloadData()
//            tableView.contentOffset.y = heightInset
//        }
    }
    
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
    
}
