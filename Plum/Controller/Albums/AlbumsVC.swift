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
    var themeBtn: UIBarButtonItem!

    var albums = [AlbumB]()
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
    var headers = [UIView]()
    var heightInset: CGFloat = 0
    var hideKeyboard = false
    var currentTheme = Theme.light
    var cellSize = CGSize()
    let device = GlobalSettings.device
    var titleButton: UIButton!
    var searchView: SearchBarContainerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        tableIndexView.isHidden = true
        collectionIndexView.isHidden = true
        grid = GlobalSettings.albumsGrid
        setInsets()
        loadData()
        if !albums.isEmpty {
            setupDict()
            reload()
            hideTable()
            //setHeaders()
        }
        configureSearchController()
        setTitleButton()
        updateTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)

        print("Albums loaded")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
    
    private func reload() {
        grid = GlobalSettings.albumsGrid
//        if grid{
//            setCollection()
//        }else{
//            setTable()
//        }
        setCollection()
        setTable()
    }
    
    private func loadData() {
        if musicQuery.shared.albumsSet {
            albums = musicQuery.shared.albums
        }else{
            albums = musicQuery.shared.allAlbums()
        }
    }
    
    func setInsets() {
        if device == "iPhone X" {
            heightInset = 88
        }else{
            heightInset = 64
        }
        automaticallyAdjustsScrollViewInsets = false
        let bottomInset = 49 + GlobalSettings.bottomInset
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        if grid != GlobalSettings.albumsGrid{
            grid = GlobalSettings.albumsGrid
            //reload()
            hideTable()
        }
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        definesPresentationContext = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if grid {
            instruct("grid", message: "As you can see this screen is organized in grid, but you can easily change it in settings!\nPress and hold on any item to see more options", completion: nil)
        }
    }
    
    func setTable(){
        tableView.delegate = self
        tableView.dataSource = self
        tableIndexView.tableView = tableView
        tableIndexView.indexes = indexes
        tableIndexView.setup()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func hideTable() {
        tableView.isHidden = grid
        tableIndexView.isHidden = grid
        collectionView.isHidden = !grid
        collectionIndexView.isHidden = !grid
    }
    
    func setCollection(){
        cellSize = calculateCollectionViewCellSize(itemsPerRow: 3, frame: self.view.frame, device: GlobalSettings.device)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionIndexView.collectionView = collectionView
        collectionIndexView.indexes = indexes
        collectionIndexView.setup()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        layout?.headerReferenceSize = CGSize(width: view.frame.width, height: 27)
        layout?.sectionInset = UIEdgeInsetsMake(10, 6, 10, 6)
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gesture.minimumPressDuration = 0.2
        gesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(gesture)
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
            let index = indexes[section]
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
            v.clipsToBounds = true
            return v
            //return headers[section]
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
    
//    func correctCollectionSections(){
//        var tmp: AlbumB!
//        for sect in 0 ..< indexes.count - 1{
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
//    }
    
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
        searchController.searchBar.placeholder = "Search for albums"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchView = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -heightInset - 104 {
            showSearchBar()
        }else if scrollView.contentOffset.y > -heightInset + 24 {
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
            collectionIndexView.isHidden = false
            collectionView.reloadData()
        }else{
            tableIndexView.isHidden = false
            tableView.reloadData()
        }
        navigationItem.titleView = nil
        navigationItem.titleView = titleButton
        navigationItem.rightBarButtonItem = themeBtn
    }
    
    func setTitleButton() {
        titleButton = UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        titleButton.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        let attributedH = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color])
        titleButton.setAttributedTitle(attributedH, for: .highlighted)
        navigationItem.titleView = titleButton
        themeBtn = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(themeBtnPressed(_:)))
        navigationItem.rightBarButtonItem = themeBtn
    }
    
    @objc func showSearchBar() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.titleView = searchView
        searchController.searchBar.becomeFirstResponder()
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
            if grid {
                if filteredAlbums.count != 0 {
                    collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                //collectionView.contentOffset.y = -heightInset
            }else{
                if filteredAlbums.count != 0 {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                //tableView.contentOffset.y = -heightInset
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
            
            let artistExpression = NSExpression(forKeyPath: "artist")
            let artistSearchComparisionPredicate = NSComparisonPredicate(leftExpression: artistExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(artistSearchComparisionPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: songsMatchPredicates)
        
        
        filteredAlbums = (albums.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredAlbums.count)
        if grid {
            collectionView.reloadData()
            if filteredAlbums.count != 0 {
                hideKeyboard = false
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                hideKeyboard = true
            }
        }else{
            tableView.reloadData()
            if filteredAlbums.count != 0 {
                hideKeyboard = false
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                hideKeyboard = true
            }
        }
    }
    
}

extension AlbumsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if shouldShowResults {
            return CGSize.zero
        }else{
            return CGSize(width: view.frame.width, height: 27)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if shouldShowResults {
            let u = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            return u
        }else{
            if kind == UICollectionElementKindSectionHeader {
                let u = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
                let index = indexes[indexPath.section]
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
                v.clipsToBounds = true
                u.addSubview(v)
                return u
            }else{
                return UICollectionReusableView()
            }
        }
    }
    
    func setHeaders() {
        headers = [UIView]()
        headers.removeAll()
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
            v.clipsToBounds = true
            headers.append(v)
        }
    }
    
    @objc func themeBtnPressed(_ sender: UIBarButtonItem) {
        if GlobalSettings.theme == .dark {
            GlobalSettings.changeTheme(.light)
        }else{
            GlobalSettings.changeTheme(.dark)
        }
    }
    
    @objc func updateTheme() {
        currentTheme = GlobalSettings.theme
        guard let bar = navigationController?.navigationBar else { return }
        let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        switch currentTheme {
        case .light:
            bar.barStyle = .default
            let attributedN = NSAttributedString(string: "Albums", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.black])
            titleButton.setAttributedTitle(attributedN, for: .normal)
            themeBtn.image = #imageLiteral(resourceName: "light_bar")
            textField?.textColor = .black
        case .dark:
            bar.barStyle = .blackTranslucent
            let attributedN = NSAttributedString(string: "Albums", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.white])
            titleButton.setAttributedTitle(attributedN, for: .normal)
            themeBtn.image = #imageLiteral(resourceName: "dark_bar")
            textField?.textColor = .white
        default:
            bar.barStyle = .blackTranslucent
        }
        tableView.backgroundColor = UIColor.background
        tableView.separatorColor = UIColor.separator
        collectionView.backgroundColor = UIColor.background
        bar.tintColor = GlobalSettings.tint.color
        tableView.backgroundColor = UIColor.background
        tableIndexView.backgroundColor = UIColor.indexBackground
        collectionIndexView.backgroundColor = UIColor.indexBackground
        setHeaders()
        tableView.reloadData()
        collectionView.reloadData()
    }
}

extension AlbumsVC {
    
    func setupDict() {
        result = [String: [AlbumB]]()
        indexes = [String]()
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in albums {
            let objStr = song.name.trimmingCharacters(in: .whitespaces)
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if secondStr.firstNumber() {
                        if result["#"] != nil {
                            result["#"]?.append(song)
                        }else{
                            result["#"] = []
                            result["#"]?.append(song)
                            anyNumber = true
                        }
                    }else{
                        if result["\(secondStr.first!)"] != nil {
                            result["\(secondStr.uppercased().first!)"]?.append(song)
                        }else{
                            result["\(secondStr.uppercased().first!)"] = []
                            result["\(secondStr.uppercased().first!)"]?.append(song)
                            indexes.append("\(secondStr.uppercased().first!)")
                        }
                    }
                }
            }else{
                if let prefi = article.first {
                    let prefix = "\(prefi)".uppercased()
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
        albums.removeAll()
        for index in indexes {
            albums.append(contentsOf: result[index]!)
        }
    }
}

/* Handle purchase events */
//extension AlbumsVC {
//
//    func registerTrialObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleUnlockChangedNotification(_:)), name: .unlockChanged, object: nil)
//    }
//
//    func unregisterTrialObserver() {
//        NotificationCenter.default.removeObserver(self, name: .unlockChanged, object: nil)
//    }
//
//    @objc func handleUnlockChangedNotification(_ sender: Notification) {
//        shouldUnlockFeatures(GlobalSettings.unlock)
//    }
//
//    func shouldUnlockFeatures(_ should: Bool) {
//        themeBtn.isEnabled = should
//        updateTheme()
//        grid = GlobalSettings.albumsGrid
//        hideTable()
//    }
//}
