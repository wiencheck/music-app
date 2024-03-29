//
//  ArtistUpVCB.swift
//  Plum
//
//  Created by Adam Wienconek on 09.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistUpVCB: UIViewController {
    
    let player = Plum.shared
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    @IBOutlet weak var upperBar: UIToolbar!
    @IBOutlet weak var shufBtn: UIButton!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var ratingBtn: UIButton!
    
    var result = [String: [MPMediaItem]]()
    var indexes = [String]()
    var cellTypes = [[Int]]()
    var songs = [MPMediaItem]()
    var activeRow = 0
    var activeSection = 0
    var absoluteRow = 0
    var receivedID: MPMediaEntityPersistentID!
    var lightTheme: Bool!
    var fxView: UIVisualEffectView!
    var statusBarStyle: UIStatusBarStyle!
    var separatorColor: UIColor!
    var toScroll = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDict()
        setup()
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0)
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .playbackChanged, object: nil)
        separatorColor = tableView.separatorColor
        setColors()
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(indexView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .playbackChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarStyle = UIApplication.shared.statusBarStyle
        setupDict()
        setup()
        reload()
        tableView.scrollToRow(at: toScroll, at: .top, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("deploy", message: "Tap on now playing song to to immediately set current playing queue to the artist", completion: nil)
        instruct("upslider", message: "Slider on the right edge of the screen works even here!", completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    @IBAction func ratingPressed() {
        GlobalSettings.changeRating(!GlobalSettings.rating)
        tableView.reloadData()
    }
    
    func setup() {
        artistLabel.text = songs[0].albumArtist ?? "Unknown artist"
        tableView.dataSource = self
        tableView.delegate = self
        indexView.indexes = [String]()
        indexView.indexes = self.indexes
        indexView.tableView = self.tableView
        indexView.setup()
        if lightTheme {
            indexView.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
        }else{
            indexView.backgroundColor = UIColor(red: 0.105882352941176, green: 0.105882352941176, blue: 0.105882352941176, alpha: 0.8)
        }
    }
    
    func setupDict() {
        result = [String: [MPMediaItem]]()
        cellTypes = [[Int]]()
        songs = [MPMediaItem]()
        indexes = [String]()
        songs = musicQuery.shared.songsByArtistID(artist: (player.currentItem?.albumArtistPersistentID)!)
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in songs {
            let objStr = song.title!.trimmingCharacters(in: .whitespaces)
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result["\(secondStr.first!)"] = []
                        result["\(secondStr.first!)"]?.append(song)
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

}

extension ArtistUpVCB: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellTypes[indexPath.section][indexPath.row] == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! ArtistUpCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            cell.setup(item: item!)
            if indexPath == toScroll{
                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.8)
                cell.title.textColor = GlobalSettings.tint.bar
                cell.album.textColor = GlobalSettings.tint.bar
                cell.duration.textColor = GlobalSettings.tint.bar
            }else{
                cell.backgroundColor = .clear
                if !lightTheme{
                    cell.title.textColor = .white
                    cell.album.textColor = .white
                    cell.duration.textColor = .white
                }else{
                    cell.title.textColor = .black
                    cell.album.textColor = .black
                    cell.duration.textColor = .black
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellTypes[activeSection][activeRow] != 0 {
            cellTypes[activeSection][activeRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .fade)
        }
        activeSection = indexPath.section
        activeRow = indexPath.row
        absoluteRow = indexPath.absoluteRow(tableView)
        if cellTypes[activeSection][activeRow] == 0 {
            if player.isPlayin() {
                let item = result[indexes[activeSection]]?[activeRow]
                if item?.persistentID != player.currentItem?.persistentID {
                    cellTypes[activeSection][activeRow] = 1
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else{
                    player.landInArtist(item!, new: false)
                }
            }else{
                if player.isShuffle {
                    player.disableShuffle()
                    player.createDefQueue(items: songs)
                    player.defIndex = absoluteRow
                    player.shuffleCurrent()
                    player.playFromShufQueue(index: 0, new: true)
                }else{
                    player.createDefQueue(items: songs)
                    player.playFromDefQueue(index: absoluteRow, new: true)
                }
                player.play()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == indexes.count - 1 {
//            let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
//            v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
//            return v
//        }else{
//            return UIView()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1
//    }
}

extension ArtistUpVCB {
    
    @objc func reload() {
        cellTypes = [[Int]]()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        findCurrent()
        tableView.reloadData()
    }
    
    func findCurrent() {
        for section in 0 ..< indexes.count {
            for row in 0 ..< (result[indexes[section]]?.count)! {
                if result[indexes[section]]![row].persistentID == player.currentItem?.persistentID {
                    toScroll = IndexPath(row: row, section: section)
                    break
                }
            }
        }
//        var section = 0
//        var row = 0
//        for index in indexes {
//            for item in result[index]! {
//                if item.persistentID == player.currentItem?.persistentID {
//                    toScroll = IndexPath(row: row, section: section)
//                    print("toScroll: \(toScroll.row) \(toScroll.section)")
//                    break
//                }
//                row += 1
//            }
//            section += 1
//        }
    }
}

extension ArtistUpVCB {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off = scrollView.contentOffset.y + 64
        upperBar.alpha = 1 + off/100
        if off < -120 {
            doneBtnPressed()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeSection][activeRow] = 0
        let indexPath = IndexPath(row: activeRow, section: activeSection)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func shuffleArtist(){
        player.landInArtist(player.currentItem!, new: false)
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: false)
    }
    
    @IBAction func playNextBtn(_ sender: Any) {
        player.addNext(item: songs[absoluteRow])
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    @IBAction func playLastBtn(_ sender: Any) {
        player.addLast(item: songs[absoluteRow])
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    @IBAction func playNowBtn(_ sender: Any) {
        if(player.isUsrQueue){
            player.clearQueue()
        }
        if(player.isShuffle){
            player.disableShuffle()
            player.defIndex = absoluteRow
            player.createDefQueue(items: songs)
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
        }else{
            player.createDefQueue(items: songs)
            player.playFromDefQueue(index: absoluteRow, new: true)
        }
        player.play()
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    
    func doneBtnPressed(){
        let bar = self.tabBarController as! UpNextTabBarController
        bar.finish()
        //dismissDetail()
    }
    
    @IBAction func shufBtnPressed(_ sender: Any){
        shuffleArtist()
    }
    
    func setColors(){
        if !lightTheme {
            dark()
        }else {
            light()
        }
        ratingBtn.tintColor = GlobalSettings.tint.color
        fxView.frame = self.view.frame
        view.backgroundColor = .clear
        view.addSubview(fxView)
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        view.addSubview(upperBar)
    }
    
    func dark() {
        //upperBar.backgroundColor = UIColor(red: 0.105882352941176, green: 0.105882352941176, blue: 0.105882352941176, alpha: 0.8)
        upperBar.barStyle = .blackTranslucent
        artistLabel.textColor = .white
        shufBtn.setImage(#imageLiteral(resourceName: "shuffle").imageScaled(toFit: CGSize(width: 32, height: 16)).tintPictogram(with: GlobalSettings.tint.color), for: .normal)
        UIApplication.shared.statusBarStyle = .lightContent
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.tableView.separatorColor = UIColor.darkSeparator
        tabBarController?.tabBar.barStyle = .blackOpaque
        indexView.backgroundColor = UIColor(red: 0.105882352941176, green: 0.105882352941176, blue: 0.105882352941176, alpha: 0.8)
    }
    
    func light() {
        //upperBar.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
        upperBar.barStyle = .default
        artistLabel.textColor = .black
        shufBtn.setImage(#imageLiteral(resourceName: "shuffle").imageScaled(toFit: CGSize(width: 32, height: 16)).tintPictogram(with: GlobalSettings.tint.color), for: .normal)
        UIApplication.shared.statusBarStyle = .default
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        self.tableView.separatorColor = UIColor.lightSeparator
        tabBarController?.tabBar.barStyle = .default
        indexView.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
    }
    
}
