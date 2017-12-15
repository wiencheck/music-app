//
//  QueueVC.swift
//  Plum
//
//  Created by Adam Wienconek on 18.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

struct Section {
    var name: String
    var songs: [MPMediaItem]
    init(name: String, songs: [MPMediaItem]) {
        self.name = name
        self.songs = songs
    }
}

protocol UpNextDelegate {
    func backFromUpNext()
}

class QueueVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upperBar: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    
    let player = Plum.shared
    var sections: [Section]!
    var mediaPicker: MPMediaPickerController!
    var lightTheme: Bool!
    var fxView: UIVisualEffectView!
    var headers: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQueue()
        setHeaders()
        setupTable()
        setColors()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("delete", message: "Tap on song's artwork to quickly delete it from queue or drag it to change queue's order", completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupQueue()
        setHeaders()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
    }
    
    func doneBtnPressed(){
        let bar = self.tabBarController as! UpNextTabBarController
        bar.finish()
    }
    
    @objc func reload() {
        setupQueue()
        tableView.reloadData()
    }

}

extension QueueVC: UITableViewDelegate, UITableViewDataSource {     //TableView sprawy
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].songs.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QueueCell
        let item = sections[indexPath.section].songs[indexPath.row]
        cell.setup(item: item)
        if !lightTheme{
            if indexPath.section == 1{
                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.5)
                cell.artist.textColor = GlobalSettings.tint.bar
                cell.title.textColor = GlobalSettings.tint.bar
            }
            if indexPath.section != 1{
                cell.backgroundColor = .clear
                cell.artist.textColor = .white
                cell.title.textColor = .white
            }
        }else{
            if indexPath.section == 1{
                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.8)
                cell.artist.textColor = GlobalSettings.tint.bar
                cell.title.textColor = GlobalSettings.tint.bar
            }
            if indexPath.section != 1{
                cell.backgroundColor = .clear
                cell.artist.textColor = .black
                cell.title.textColor = .black
            }
        }
        if indexPath.section == 2 || indexPath.section == 3 {
            cell.addTap()
            cell.tapCallback = { theCell in
                if let path = tableView.indexPath(for: theCell){
                    self.deleteByTap(tableView, indexPath: path)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 || proposedDestinationIndexPath.section == 1 {
            return IndexPath(row: 0, section: 2)
        }else{
            return proposedDestinationIndexPath
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var zeros = [Bool]()
        for i in 0 ..< tableView.numberOfSections {
            if tableView.numberOfRows(inSection: i) == 0 {
                zeros.append(true)
            }else{
                zeros.append(false)
            }
        }
        let movingItem = sections[fromIndexPath.section].songs[fromIndexPath.row]
        var help = 0
        if tableView.numberOfSections == 4 {
            if fromIndexPath.section == 0 {
                if player.isShuffle {
                    help = player.shufIndex - (tableView.numberOfRows(inSection: 0) - fromIndexPath.row) - 1
                    player.shufQueue.remove(at: help)
                }else{
                    help = player.defIndex - (tableView.numberOfRows(inSection: 0) - fromIndexPath.row) - 1
                    player.defQueue.remove(at: help)
                }
            }else if fromIndexPath.section == 2 {
                help = fromIndexPath.row + player.usrIndex + 1
                player.usrQueue.remove(at: help)
            }else if fromIndexPath.section == 3 {
                if player.isShuffle {
                    help = player.shufIndex + fromIndexPath.row + 1
                    player.shufQueue.remove(at: help)
                }else{
                    help = player.defIndex + fromIndexPath.row + 1
                    player.defQueue.remove(at: help)
                }
            }
            
            if to.section == 2 {
                help = to.row + player.usrIndex + 1
                player.usrQueue.insert(movingItem, at: help)
            }else if to.section == 3 {
                if player.isShuffle {
                    help = player.shufIndex + to.row + 1
                    player.shufQueue.insert(movingItem, at: help)
                }else{
                    help = player.defIndex + to.row + 1
                    player.defQueue.insert(movingItem, at: help)
                }
            }
            
        }else{
            if fromIndexPath.section == 0 {
                if player.isShuffle {
                    help = player.shufIndex - (tableView.numberOfRows(inSection: 0) - fromIndexPath.row) - 1
                    player.shufQueue.remove(at: help)
                    player.shufIndex! -= 1
                }else{
                    help = player.defIndex - (tableView.numberOfRows(inSection: 0) - fromIndexPath.row) - 1
                    player.defQueue.remove(at: help)
                    player.defIndex! -= 1
                }
            }else if fromIndexPath.section == 2 {
                if player.isShuffle {
                    help = player.shufIndex + fromIndexPath.row + 1
                    player.shufQueue.remove(at: help)
                }else{
                    help = player.defIndex + fromIndexPath.row + 1
                    player.defQueue.remove(at: help)
                }
            }
            
            if to.section == 2 {
                if player.isShuffle {
                    help = player.shufIndex + to.row + 1
                    player.shufQueue.insert(movingItem, at: help)
                }else{
                    help = player.defIndex + to.row + 1
                    player.defQueue.insert(movingItem, at: help)
                }
            }
        }
        setupQueue()
        var zeros2 = [Bool]()
        for i in 0 ..< tableView.numberOfSections {
            if tableView.numberOfRows(inSection: i) == 0 {
                zeros2.append(true)
            }else{
                zeros2.append(false)
            }
        }
        if zeros != zeros2 { tableView.reloadData() }
        player.writeQueue()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var tmpindex = 0
        if tableView.numberOfSections == 3 && player.isUsrQueue {
            if indexPath.section == 2 {
                if player.usrIndex > 0 {
                    if player.isShuffle{
                        tmpindex = player.shufIndex
                        player.playFromShufQueue(index: player.shufIndex + indexPath.row + 2, new: true)
                        player.shufIndex = tmpindex
                    }else{
                        tmpindex = player.defIndex
                        player.playFromDefQueue(index: player.defIndex + indexPath.row + 2, new: true)
                        player.defIndex = tmpindex
                    }
                }else{
                    if player.isShuffle{
                        tmpindex = player.shufIndex
                        player.playFromShufQueue(index: player.shufIndex + indexPath.row + 1, new: true)
                        player.shufIndex = tmpindex
                    }else{
                        tmpindex = player.defIndex
                        player.playFromDefQueue(index: player.defIndex + indexPath.row + 1, new: true)
                        player.defIndex = tmpindex
                    }
                }
            }
        }else if tableView.numberOfSections == 4 {
            if indexPath.section == 0 {
                if player.isShuffle {
                    player.playFromShufQueue(index: player.shufIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
                }else{
                    player.playFromDefQueue(index: player.defIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
                }
            }else if indexPath.section == 2 {
                player.playFromUsrQueue(index: player.usrIndex + indexPath.row + 1)
            }else if indexPath.section == 3 {
                if player.usrIndex > 0 {
                    if player.isShuffle{
                        tmpindex = player.shufIndex
                        player.playFromShufQueue(index: player.shufIndex + indexPath.row + 2, new: true)
                        player.shufIndex = tmpindex
                    }else{
                        tmpindex = player.defIndex
                        player.playFromDefQueue(index: player.defIndex + indexPath.row + 2, new: true)
                        player.defIndex = tmpindex
                    }
                }else{
                    if player.isShuffle{
                        tmpindex = player.shufIndex
                        player.playFromShufQueue(index: player.shufIndex + indexPath.row + 1, new: true)
                        player.shufIndex = tmpindex
                    }else{
                        tmpindex = player.defIndex
                        player.playFromDefQueue(index: player.defIndex + indexPath.row + 1, new: true)
                        player.defIndex = tmpindex
                    }
                }
            }
        }else{
            if indexPath.section == 0 {
                if player.isShuffle {
                    player.playFromShufQueue(index: player.shufIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
                }else{
                    player.playFromDefQueue(index: player.defIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
                }
            }else if indexPath.section == 2 {
                if player.isShuffle{
                    player.playFromShufQueue(index: player.shufIndex + indexPath.row + 1, new: true)
                }else{
                    player.playFromDefQueue(index: player.defIndex + indexPath.row + 1, new: true)
                }
            }
        }
        player.play()
        setupQueue()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].songs.isEmpty {
            return 0
        }else{
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return false
        }else{
            return true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        upperBar.alpha = 1 + scrollView.contentOffset.y/100
        if scrollView.contentOffset.y < -120 {
            doneBtnPressed()
        }
    }
}

extension QueueVC {     //Ustawianie kolejek
    
    func setupQueue() {
        var tmp = [MPMediaItem]()
        var previousStart = 0
        var previousMeta = 0
        var nextStart = 0
        var nextMeta = 0
        sections = [Section]()
        ///////////////////////////// PREVIOUS
        if(player.isShuffle){
            if player.shufIndex < 10{
                previousStart = 0
                previousMeta = player.shufIndex
                //toScroll = player.shufIndex
            }else{
                previousStart = player.shufIndex - 10
                previousMeta = previousStart + 10
                //toScroll = 10
            }
            if player.usrIndex > 0 {previousMeta += 1}
            for i in previousStart ..< previousMeta{
                tmp.append(player.shufQueue[i])
            }
        }else{
            if player.defIndex < 10{
                previousStart = 0
                previousMeta = player.defIndex
                //toScroll = player.defIndex
            }else{
                previousStart = player.defIndex - 10
                previousMeta = previousStart + 10
                //toScroll = 10
            }
            if player.usrIndex > 0 {previousMeta += 1}
            for i in previousStart ..< previousMeta{
                tmp.append(player.defQueue[i])
            }
        }
        sections.append(Section(name: "Previous", songs: tmp))
        tmp.removeAll()
        //////////////////////////////// NOW
        
        sections.append(Section(name: "Now Playing", songs: [player.currentItem!]))
        
        //////////////////////////////// NEXT
        
        nextStart = previousMeta + 1
        if(player.defIndex > player.defQueueCount - 40 || player.shufIndex > player.shufQueueCount - 40){
            nextMeta = player.defQueueCount
        }else{
            nextMeta = player.defIndex + 40
        }
        if nextStart <= nextMeta {
            if(!player.isShuffle){
                for i in nextStart ..< nextMeta{
                    if player.defQueue[i].assetURL != nil {
                        tmp.append(player.defQueue[i])
                    }
                }
            }else{
                for i in nextStart ..< nextMeta{
                    if player.shufQueue[i].assetURL != nil {
                        tmp.append(player.shufQueue[i])
                    }
                }
            }
        }
        sections.append(Section(name: "Next", songs: tmp))
        tmp.removeAll()
        ////////////////////////// USER
        
        if player.isUsrQueue && player.usrIsAnyAfter {
            for i in player.usrIndex + 1 ..< player.usrQueue.count {
                if player.usrQueue[i].assetURL != nil {
                    tmp.append(player.usrQueue[i])
                }
            }
            sections.insert(Section(name: "User Queue", songs: tmp), at: 2)
            tmp.removeAll()
        }
    }
    
    func deleteByTap(_ tableView: UITableView, indexPath: IndexPath){
        if tableView.numberOfSections == 4 {
            if indexPath.section == 2 {
                player.usrQueue.remove(at: player.usrIndex + indexPath.row + 1)
                sections[2].songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }else if indexPath.section == 3 {
                if player.isShuffle {
                    player.shufQueue.remove(at: player.shufIndex + indexPath.row + 1)
                }else{
                    player.defQueue.remove(at: player.defIndex + indexPath.row + 1)
                }
                sections[3].songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }else if tableView.numberOfSections == 3 {
            if indexPath.section == 2 {
                if player.isShuffle {
                    player.shufQueue.remove(at: player.shufIndex + indexPath.row + 1)
                }else{
                    player.defQueue.remove(at: player.defIndex + indexPath.row + 1)
                }
                sections[2].songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension QueueVC: MPMediaPickerControllerDelegate {    //Media Picker
    
    @IBAction func addBtnPressed(_ sender: UIButton){
        presentPicker()
    }
    
    func presentPicker() {
        mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.showsCloudItems = false
        mediaPicker.prompt = "Please Pick a Song"
        mediaPicker.modalTransitionStyle = .coverVertical
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for picked in mediaItemCollection.items{
            player.addLast(item: picked)
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        setupQueue()
        tableView.reloadData()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func setColors(){
        if !lightTheme {
            dark()
        }else{
            light()
        }
        fxView.frame = self.view.frame
        self.view.backgroundColor = .clear
        view.addSubview(fxView)
        self.tableView.backgroundColor = .clear
        view.addSubview(tableView)
        view.addSubview(upperBar)
    }
    
    func dark() {
        upperBar.backgroundColor = UIColor(red: 0.105882352941176, green: 0.105882352941176, blue: 0.105882352941176, alpha: 0.8)
        mainLabel.textColor = .white
        addBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
        UIApplication.shared.statusBarStyle = .lightContent
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.tableView.separatorColor = .black
        tabBarController?.tabBar.barStyle = .blackOpaque
    }
    
    func light() {
        upperBar.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
        mainLabel.textColor = .black
        addBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
        UIApplication.shared.statusBarStyle = .default
        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        self.tableView.separatorColor = UIColor(red: 0.929411764705882, green: 0.929411764705882, blue: 0.933333333333333, alpha: 1.0)
        tabBarController?.tabBar.barStyle = .default
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func setHeaders() {
        headers = [UIView]()
        for section in sections {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 27))
            let label = UILabel(frame: CGRect(x: 10, y: 3, width: v.frame.width, height: 21))
            if !lightTheme {
                v.backgroundColor = UIColor(red: 0.105882352941176, green: 0.105882352941176, blue: 0.105882352941176, alpha: 0.8)
                label.text = section.name
                label.textColor = .white
            }else{
                v.backgroundColor = UIColor(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 0.8)
                label.text = section.name
                label.textColor = .black
            }
            v.addSubview(label)
            headers.append(v)
        }
    }
    
}
