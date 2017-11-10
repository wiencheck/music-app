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
    
    var cellTypes = [Int]()
    var songs = [MPMediaItem]()
    var index: Int = 0
    var previousIndex = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upperBar: UIView!
    @IBOutlet weak var shufBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    var receivedID: MPMediaEntityPersistentID!
    var delegate: UpNextProtocol?
    var style: viewLayout!
    var statusBarStyle: UIStatusBarStyle!
    var separatorColor: UIColor!
    var settings = UpNextSettings()
    var toScroll = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        separatorColor = tableView.separatorColor
        loadSettings()
        setColors()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    func setup(){
        songs = musicQuery.shared.songsByAlbumID(album: (Plum.shared.currentItem?.albumPersistentID)!)
        cellTypes = Array<Int>(repeating: 0, count: songs.count)
        let item = songs[0]
        artistLabel.text = item.albumArtist ?? "Unknown artist"
        albumLabel.text = item.albumTitle ?? "Unknown album"
    }
    
    @IBAction func doneBtnPressed(_ sender: Any){
        if let d = self.delegate{
            d.updateQueueInfo(true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shufBtnPressed(_ sender: Any){
        shuffleAlbum()
    }
    
    func setColors(){
        if settings.upperBarColored{
            upperBar.backgroundColor = style.upperBar
            albumLabel.textColor = style.mainLabel
            artistLabel.textColor = style.mainLabel
            doneBtn.setTitleColor(style.accessories, for: .normal)
            shufBtn.setTitleColor(style.accessories, for: .normal)
        }else{
            upperBar.backgroundColor = .white
            albumLabel.textColor = .black
            artistLabel.textColor = .black
            doneBtn.setTitleColor(GlobalSettings.theme, for: .normal)
            shufBtn.setTitleColor(GlobalSettings.theme, for: .normal)
        }
        var fxView: UIVisualEffectView!
        if settings.adaptiveTableView{
            if style.dark{
                fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                UIApplication.shared.statusBarStyle = .lightContent
                self.tableView.separatorColor = .black
            }else{
                fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
                UIApplication.shared.statusBarStyle = .default
                self.tableView.separatorColor = separatorColor
            }
        }else if settings.alwaysBlack{
            fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            self.tableView.separatorColor = .black
            UIApplication.shared.statusBarStyle = .lightContent
        }else if settings.alwaysLight{
            fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            self.tableView.separatorColor = separatorColor
            UIApplication.shared.statusBarStyle = .lightContent
        }
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        fxView.frame = self.view.frame
        self.tableView.backgroundView = fxView
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
                cell.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
                cell.titleLabel.textColor = .white
                cell.trackNumberLabel.textColor = .white
                cell.durationLabel.textColor = .white
            }else{
                cell.backgroundColor = .clear
                if style.dark{
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
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    @IBAction func playLastBtn(_ sender: Any) {
        Plum.shared.addLast(item: songs[index])
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
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
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func loadSettings(){
        settings.alwaysLight = true
        if settings.alwaysLight{
            style.dark = false
        }
        settings.upperBarColored = false
        settings.alwaysBlack = false
        if settings.alwaysBlack{
            style.dark = true
        }
        settings.adaptiveTableView = false
    }
    
    @objc func reload(){
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 1))
        v.backgroundColor = tableView.separatorColor
        return v
    }
}
