//
//  AlbumUpVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 25.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumUpVC: UIViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upperBar: UIToolbar!
    @IBOutlet weak var shufBtn: UIButton!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var ratingBtn: UIButton!
    
    var cellTypes = [Int]()
    var songs = [MPMediaItem]()
    var index: Int = 0
    var previousIndex = 0
    var receivedID: MPMediaEntityPersistentID!
    var lightTheme: Bool!
    var fxView: UIVisualEffectView!
    var statusBarStyle: UIStatusBarStyle!
    var separatorColor: UIColor!
    var toScroll = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0)
        separatorColor = tableView.separatorColor
        setColors()
        setup()
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .playbackChanged, object: nil)
    }
    
    @IBAction func ratingPressed() {
        GlobalSettings.changeRating(!GlobalSettings.rating)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("deploy", message: "Tap on now playing song to to immediately set current playing queue to the album", completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    func setup(){
        let item = Plum.shared.currentItem
        songs = musicQuery.shared.songsByAlbumID(album: item!.albumPersistentID)
        cellTypes = Array<Int>(repeating: 0, count: songs.count)
        artistLabel.text = item!.albumArtist ?? "Unknown artist"
        albumLabel.text = item!.albumTitle ?? "Unknown album"
    }
    
    func doneBtnPressed(){
        let bar = self.tabBarController as! UpNextTabBarController
        bar.finish()
        //dismissDetail()
    }
    
    @IBAction func shufBtnPressed(_ sender: Any){
        shuffleAlbum()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarStyle = UIApplication.shared.statusBarStyle
        setup()
        findCurrent()
        tableView.reloadData()
        tableView.scrollToRow(at: toScroll, at: .top, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    func findCurrent(){
        var i = 0
        for song in songs{
            if song.persistentID == Plum.shared.currentItem?.persistentID{
                toScroll = IndexPath(row: i, section: 0)
                break
            }
            i += 1
        }
    }

}

extension AlbumUpVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(cellTypes[indexPath.row] == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongInAlbumCell
            cell.setup(item: songs[indexPath.row])
            if indexPath == toScroll{
                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.8)
                cell.titleLabel.textColor = GlobalSettings.tint.bar
                cell.trackNumberLabel.textColor = GlobalSettings.tint.bar
                cell.durationLabel.textColor = GlobalSettings.tint.bar
            }else{
                cell.backgroundColor = .clear
                if !lightTheme{
                    cell.titleLabel.textColor = .white
                    cell.trackNumberLabel.textColor = .white
                    cell.durationLabel.textColor = .white
                }else{
                    cell.titleLabel.textColor = .black
                    cell.trackNumberLabel.textColor = .black
                    cell.durationLabel.textColor = .black
                }
            }
            return cell
        }else if cellTypes[indexPath.row] == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.alpha = 0.5
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(cellTypes[previousIndex] == 1){
            cellTypes[previousIndex] = 0
            tableView.reloadRows(at: [IndexPath(row: previousIndex, section: 0)], with: .fade)
        }
        var rows = 0
        if indexPath.section > 0{
            for section in 0 ..< indexPath.section{
                rows += tableView.numberOfRows(inSection: section)
            }
            index = rows + indexPath.row
        }else{
            index = indexPath.row
        }
        previousIndex = index
        if(cellTypes[indexPath.row] == 0){
            let item = songs[indexPath.row]
            if(Plum.shared.isPlayin() && item.assetURL != Plum.shared.currentItem?.assetURL){
                cellTypes[indexPath.row] = 1
                tableView.reloadRows(at: [indexPath], with: .fade)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    if(self.cellTypes[indexPath.row] == 1){
                        self.cellTypes[indexPath.row] = 0
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                })
            }else{
                if item.assetURL == Plum.shared.currentItem?.assetURL{
                    Plum.shared.landInAlbum(item, new: false)
                }else{
                    Plum.shared.landInAlbum(item, new: true)
                }
                Plum.shared.play()
            }
        }else{
            cellTypes[indexPath.row] = 0
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off = scrollView.contentOffset.y + 64
        upperBar.alpha = 1 + off/100
        if off < -120 {
            doneBtnPressed()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[index] = 0
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func shuffleAlbum(){
        Plum.shared.landInAlbum(Plum.shared.currentItem!, new: false)
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: false)
    }
    
    @IBAction func playNextBtn(_ sender: Any) {
        Plum.shared.addNext(item: songs[index])
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    @IBAction func playLastBtn(_ sender: Any) {
        Plum.shared.addLast(item: songs[index])
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    @IBAction func playNowBtn(_ sender: Any) {
        if(Plum.shared.isUsrQueue){
            Plum.shared.clearQueue()
        }
        if(Plum.shared.isShuffle){
            Plum.shared.disableShuffle()
            Plum.shared.defIndex = index
            Plum.shared.createDefQueue(items: songs)
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }else{
            Plum.shared.createDefQueue(items: songs)
            Plum.shared.playFromDefQueue(index: index, new: true)
        }
        Plum.shared.play()
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    
    @objc func reload(){
        cellTypes = Array<Int>(repeating: 0, count: cellTypes.count)
        findCurrent()
        self.tableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
//        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
//        return v
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1
//    }
    
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
        albumLabel.textColor = .white
        shufBtn.setImage(#imageLiteral(resourceName: "shuffle").imageScaled(toFit: CGSize(width: 32, height: 16)).tintPictogram(with: GlobalSettings.tint.color), for: .normal)
        UIApplication.shared.statusBarStyle = .lightContent
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.tableView.separatorColor = UIColor.darkSeparator
        tabBarController?.tabBar.barStyle = .blackOpaque
    }
    
    func light() {
        //upperBar.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
        upperBar.barStyle = .default
        artistLabel.textColor = .black
        albumLabel.textColor = .black
        shufBtn.setImage(#imageLiteral(resourceName: "shuffle").imageScaled(toFit: CGSize(width: 32, height: 16)).tintPictogram(with: GlobalSettings.tint.color), for: .normal)
        UIApplication.shared.statusBarStyle = .default
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        self.tableView.separatorColor = UIColor.lightSeparator
        tabBarController?.tabBar.barStyle = .default
    }
}
