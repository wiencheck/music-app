/*import UIKit
import MediaPlayer
import LNPopupController

class SongsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, QueueCellDelegate, MoreActionsCellDelegate {
    var cellTypes = [[Int]]()
    var indexes = [String]()
    var songs = [MPMediaItem]()
    var result = [String: [MPMediaItem]]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SongsVC.longPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        tableView.addGestureRecognizer(longPress)
        view.addSubview(tableView)
        indexView.indexes = self.indexes
        indexView.tableView = self.tableView
        indexView.setup()
        view.addSubview(indexView)
    }
    
    deinit {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return result.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if cellTypes[indexPath.section][indexPath.row] != 0{
            return nil
        }else{
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        absoluteIndex = indexPath.absoluteRow(tableView)
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
        }else if cellTypes[indexPath.section][indexPath.row] == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
            cell?.delegate = self
            cell?.backgroundColor = .clear
            return cell!
        }else if cellTypes[indexPath.section][indexPath.row] == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as? MoreActionsCell
            cell?.delegate = self
            cell?.backgroundColor = .clear
            return cell!
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellTypes[activeIndexSection][activeIndexRow] != 0 {
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        }
        activeIndexRow = indexPath.row
        activeIndexSection = indexPath.section
        absoluteIndex = indexPath.absoluteRow(tableView)
        print("Absolute index = \(absoluteIndex)")
        if(cellTypes[indexPath.section][indexPath.row] == 0){
            if(Plum.shared.isPlayin()){
                cellTypes[indexPath.section][indexPath.row] = 1
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
            cellTypes[indexPath.section][indexPath.row] = 0
            tableView.reloadRows(at: [indexPath], with: .right)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedAlbumID
        }else if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = pickedArtistID
        }else if let destination = segue.destination as? SongsByVC {
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
    }
    
    func cell(_ cell: MoreActionsCell, action: MoreActions){
        switch action {
        case .album:
            albumBtn()
        case .artist:
            artistBtn()
        }
    }
    
    func playNextBtn() {
        Plum.shared.addNext(item: songs[absoluteIndex])
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playLastBtn() {
        Plum.shared.addLast(item: songs[absoluteIndex])
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playNowBtn() {
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
        Plum.shared.play()
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func albumBtn(){
        cellTypes[activeIndexSection][activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        cellTypes[activeIndexSection][activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: self.activeIndexRow, section: activeIndexSection)], with: .fade)
        performSegue(withIdentifier: "artist", sender: nil)
    }
    @objc func longPress(_ longPress: UIGestureRecognizer){
        if cellTypes[activeIndexSection][activeIndexRow] != 0{
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .left)
        }
        if longPress.state == .recognized{
            let touchPoint = longPress.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                activeIndexSection = indexPath.section
                activeIndexRow = indexPath.row
                pickedAlbumID = result[indexes[activeIndexSection]]![activeIndexRow].albumPersistentID
                pickedArtistID = result[indexes[activeIndexSection]]![activeIndexRow].albumArtistPersistentID
                self.cellTypes[activeIndexSection][activeIndexRow] = 2
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeIndexSection][activeIndexRow] = 0
        let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

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
    setupDict()
    tableView.delegate = self
    tableView.dataSource = self
    //self.view.addSubview(tableView)
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
    collectionView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
    //self.collectionView.backgroundColor = .clear
    setupDict()
    collectionView.delegate = self
    collectionView.dataSource = self
    self.view.addSubview(collectionView)
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
    longPress.minimumPressDuration = 0.2
    longPress.numberOfTouchesRequired = 1
    collectionView.addGestureRecognizer(longPress)
    for i in 0 ..< collectionView.numberOfSections {
        collectionTypes.append(Array<Int>(repeating: 0, count: collectionView.numberOfItems(inSection: i)))
    }
    //correctCollectionSections()
    collectionIndexView.indexes = self.indexes
    collectionIndexView.collectionView = self.collectionView
    collectionIndexView.setup()
    self.view.addSubview(collectionIndexView)
}*/
