////
////  UpNextVC.swift
////  wiencheck
////
////  Created by Adam Wienconek on 08.10.2017.
////  Copyright © 2017 Adam Wienconek. All rights reserved.
////
//
//import UIKit
//import MediaPlayer
//
protocol UpNextDelegate {
    func backFromUpNext()
}
//
//struct Songs{
//    let sectionName: String
//    var songsIn: [MPMediaItem]
//}
//
//class UpNextVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate{
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var upperBar: UIView!
//    @IBOutlet weak var addBtn: UIButton!
//    @IBOutlet weak var doneBtn: UIButton!
//    @IBOutlet weak var mainLabel: UILabel!
//
//    var delegate: UpNextDelegate?
//    var mediaPicker: MPMediaPickerController!
//    var lightTheme: Bool!
//    var fxView: UIVisualEffectView!
//    var previousStart: Int!
//    var previousMeta: Int!
//    var nextStart: Int!
//    var nextMeta: Int!
//    var toScroll: Int!
//    var arr = [String]()
//    var songs = [MPMediaItem]()
//    var sungs = [Songs]()
//    var player = Plum.shared
//    var statusBarStyle: UIStatusBarStyle!
//    var separatorColor: UIColor!
//    var settings = UpNextSettings()
//    var set: IndexSet!
//    var headers = [UIView]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        setupQueueArray()
//        separatorColor = tableView.separatorColor
//        self.view.backgroundColor = .clear
//        self.tableView.backgroundColor = .clear
//        loadHeaders()
//        setColors()
//        self.tableView.allowsSelectionDuringEditing = true
//        self.tableView.setEditing(true, animated: false)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        statusBarStyle = UIApplication.shared.statusBarStyle
//        setupQueueArray()
//        tableView.reloadData()
//        let path = IndexPath(row: 0, section: 1)
//        self.tableView.scrollToRow(at: path, at: .top, animated: false)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = statusBarStyle
//    }
//
//    @IBAction func addBtnPressed(_ sender: UIButton){
//        presentPicker()
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sungs.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sungs[section].songsIn.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 58
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if sungs.count == 4{
//            return headers[section]
//        }else{
//            (headers[2], headers[3]) = (headers[3], headers[2])
//            return headers[section]
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 27
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QueueCell
//        let item = sungs[indexPath.section].songsIn[indexPath.row]
//        cell.setup(item: item)
//        if !lightTheme{
//            if indexPath.section == 1{
//                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.8)
//                cell.artist.textColor = .white
//                cell.title.textColor = .white
//            }
//            if indexPath.section != 1{
//                cell.backgroundColor = .clear
//                cell.artist.textColor = .white
//                cell.title.textColor = .white
//            }
//        }else{
//            if indexPath.section == 1{
//                cell.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(0.8)
//                cell.artist.textColor = .white
//                cell.title.textColor = .white
//            }
//            if indexPath.section != 1{
//                cell.backgroundColor = .clear
//                cell.artist.textColor = .black
//                cell.title.textColor = .black
//            }
//        }
//        if indexPath.section == 2 || indexPath.section == 3{
//            cell.addTap()
//            cell.tapCallback = {
//                theCell in
//                if let iPath = tableView.indexPath(for: theCell){
//                    if iPath.section == 2{
//                        self.deleteByTap2(tableView, indexPath: iPath)
//                    }else if iPath.section == 3{
//                        self.deleteByTap3(tableView, indexPath: iPath)
//                    }
//                }
//            }
//        }
//        return cell
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        upperBar.alpha = 1 + scrollView.contentOffset.y/100
//        if scrollView.contentOffset.y < -120 {
//            doneBtnPressed()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //if !player.usrIsAnyAfter { player.isUsrQueue = false }
//        //if !player.usrIsAnyAfter { player.clearQueue() }
//        ////////////////// PREVIOUS
//        if indexPath.section == 0{
//            if player.isShuffle{
//                player.playFromShufQueue(index: player.shufIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
//            }else{
//                player.playFromDefQueue(index: player.defIndex - (tableView.numberOfRows(inSection: 0) - indexPath.row), new: true)
//            }
//        }
//        ////////////////// USER/NEXT
//        if player.isUsrQueue && player.usrIsAnyAfter{
//            if indexPath.section == 2{
//                player.playFromUsrQueue(index: player.usrIndex + indexPath.row + 1)
//            }else if indexPath.section == 3{
//                if player.isShuffle{
//                    player.playFromShufQueue(index: player.shufIndex + indexPath.row + player.usrIndex + 1, new: true)
//                }else{
//                    player.playFromDefQueue(index: player.defIndex + indexPath.row + player.usrIndex + 1, new: true)
//                }
//            }
//        }else if player.isUsrQueue && !player.usrIsAnyAfter {
//            if indexPath.section == 2{
//                if player.isShuffle{
//                    player.playFromShufQueue(index: player.shufIndex + indexPath.row + player.usrIndex + 1, new: true)
//                }else{
//                    player.playFromDefQueue(index: player.defIndex + indexPath.row + player.usrIndex + 1, new: true)
//                }
//            }
//        }else{
//            if indexPath.section == 2{
//                if player.isShuffle{
//                    player.playFromShufQueue(index: player.shufIndex + indexPath.row + 1, new: true)
//                }else{
//                    player.playFromDefQueue(index: player.defIndex + indexPath.row + 1, new: true)
//                }
//            }
//        }
//        player.play()
//        //if !player.usrIsAnyAfter { player.clearQueue() }
//        setupQueueArray()
//        //if !player.usrIsAnyAfter { player.clearQueue() }
//        tableView.reloadData()
//        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
//        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
//        return v
//    }
//
//    @IBAction func doneBtnPressed(){
//        self.delegate?.backFromUpNext()
//        dismissDetail()
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 1{
//            return false
//        }else{
//            return true
//        }
//    }
//
////    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
////        if editingStyle == .delete{
////            if player.isUsrQueue{
////                if indexPath.section == 2{
////                    player.usrQueue.remove(at: indexPath.row)
////                }else if indexPath.section == 3{
////                    if player.isShuffle{
////                        player.shufQueue.remove(at: indexPath.row)
////                    }else{
////                        player.defQueue.remove(at: indexPath.row)
////                    }
////                }
////            }else{
////                if indexPath.section == 2{
////                    if player.isShuffle{
////                        player.shufQueue.remove(at: indexPath.row)
////                    }else{
////                        player.defQueue.remove(at: indexPath.row)
////                    }
////                }
////            }
////        }
////    }
//
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section < 2{
//            return false
//        }else{
//            return true
//        }
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        var toMove: MPMediaItem
//        if player.isUsrQueue{
//            if sourceIndexPath.section == 0{
//                if player.isShuffle{
//                    toMove = player.shufQueue[player.shufIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row)]
//                    player.shufQueue.remove(at: player.shufIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row))
//                    if destinationIndexPath.section == 2{
//                        player.usrQueue.insert(toMove, at: destinationIndexPath.row + 1)
//                    }else if destinationIndexPath.section == 3{
//                        player.shufQueue.insert(toMove, at: player.shufIndex + destinationIndexPath.row + 1)
//                    }
//                }else{
//                    toMove = player.defQueue[player.defIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row)]
//                    player.defQueue.remove(at: player.defIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row))
//                    if destinationIndexPath.section == 2{
//                        player.usrQueue.insert(toMove, at: destinationIndexPath.row + 1)
//                    }else if destinationIndexPath.section == 3{
//                        player.defQueue.insert(toMove, at: player.defIndex + destinationIndexPath.row + 1)
//                    }
//                }
//                ///////////USER
//            }else if sourceIndexPath.section == 2{
//                    toMove = player.usrQueue[sourceIndexPath.row + 1]
//                    player.usrQueue.remove(at: sourceIndexPath.row + 1)
//                if destinationIndexPath.section == 2{
//                    player.usrQueue.insert(toMove, at: destinationIndexPath.row + 1)
//                }else if destinationIndexPath.section == 3{
//                    player.defQueue.insert(toMove, at: player.defIndex + destinationIndexPath.row + 1)
//                    player.defQueueCount! += 1
//                }
//                ///////////?NEXT
//            }else if sourceIndexPath.section == 3{
//                if player.isShuffle{
//                    toMove = player.shufQueue[player.shufIndex + sourceIndexPath.row + 1]
//                    player.shufQueue.remove(at: player.shufIndex + sourceIndexPath.row + 1)
//                    if destinationIndexPath.section == 3{
//                        player.shufQueue.insert(toMove, at: player.shufIndex + destinationIndexPath.row + 1)
//                    }else if destinationIndexPath.section == 2{
//                        player.usrQueue.insert(toMove, at: destinationIndexPath.row + 1)
//                        player.defQueueCount! -= 1
//                    }
//                }else{
//                    toMove = player.defQueue[player.defIndex + sourceIndexPath.row + 1]
//                    player.defQueue.remove(at: player.defIndex + sourceIndexPath.row + 1)
//                    if destinationIndexPath.section == 3{
//                        player.defQueue.insert(toMove, at: player.defIndex + destinationIndexPath.row + 1)
//                    }else if destinationIndexPath.section == 2{
//                        player.usrQueue.insert(toMove, at: destinationIndexPath.row + 1)
//                        player.defQueueCount! -= 1
//                    }
//                }
//            }
//        }else{
//            if sourceIndexPath.section == 0{
//                if player.isShuffle{
//                    toMove = player.shufQueue[player.shufIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row)]
//                    player.shufQueue.remove(at: player.shufIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row))
//                    if destinationIndexPath.section == 2{
//                        player.shufQueue.insert(toMove, at: player.shufIndex + destinationIndexPath.row + 1)
//                    }
//                }else{
//                    toMove = player.defQueue[player.defIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row + 1)]
//                    player.defQueue.remove(at: player.defIndex - (tableView.numberOfRows(inSection: 0) - sourceIndexPath.row + 1))
//                    if destinationIndexPath.section == 2{
//                        player.defQueue.insert(toMove, at: player.defIndex + destinationIndexPath.row + 1)
//                    }
//                }
//            }else if sourceIndexPath.section == 2{
//                if player.isShuffle{
//                    toMove = player.shufQueue[player.shufIndex + sourceIndexPath.row + 1]
//                    player.shufQueue.remove(at: player.shufIndex + sourceIndexPath.row + 1)
//                    if destinationIndexPath.section == 2{
//                        player.shufQueue.insert(toMove, at: player.shufIndex + destinationIndexPath.row + 1)
//                    }
//                }else{
//                    toMove = player.defQueue[player.defIndex + sourceIndexPath.row + 1]
//                    player.defQueue.remove(at: player.defIndex + sourceIndexPath.row + 1)
//                    if destinationIndexPath.section == 2{
//                        player.defQueue.insert(toMove, at: player.defIndex + destinationIndexPath.row + 1)
//                    }
//                }
//            }
//        }
//        //setupQueueArray()
//    }
//
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        var newIndexPath: IndexPath
//        if proposedDestinationIndexPath.section == 0 || proposedDestinationIndexPath.section == 1 {
//            newIndexPath = IndexPath(row: 0, section: 2)
//            return newIndexPath
//        }else{
//            return proposedDestinationIndexPath
//        }
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//
//    func setupQueueArray(){
//        var tmp = [MPMediaItem]()
//        sungs = [Songs(sectionName: "", songsIn: tmp), Songs(sectionName: "Now Playing", songsIn: [player.currentItem!]), Songs(sectionName: "", songsIn: tmp)]
//        ///////////////////////////// PREVIOUS
//        if(player.isShuffle){
//            if player.shufIndex < 10{
//                previousStart = 0
//                previousMeta = player.shufIndex
//                //toScroll = player.shufIndex
//            }else{
//                previousStart = player.shufIndex - 10
//                previousMeta = previousStart + 10
//                //toScroll = 10
//            }
//            if player.usrIndex > 0 {previousMeta! += 1}
//            for i in previousStart ..< previousMeta{
//                tmp.append(player.shufQueue[i])
//            }
//        }else{
//            if player.defIndex < 10{
//                previousStart = 0
//                previousMeta = player.defIndex
//                //toScroll = player.defIndex
//            }else{
//                previousStart = player.defIndex - 10
//                previousMeta = previousStart + 10
//                //toScroll = 10
//            }
//            if player.usrIndex > 0 {previousMeta! += 1}
//            for i in previousStart ..< previousMeta{
//                tmp.append(player.defQueue[i])
//            }
//        }
//        sungs[0] = Songs(sectionName: "Previous", songsIn: tmp)
//
//        //////////////////////////////// NEXT
//
//        nextStart = previousMeta + 1
//
//        if(!player.isShuffle){
//            if player.defIndex > player.defQueue.count - 60 {
//                nextMeta = player.defQueue.count
//            }else{
//                nextMeta = player.defIndex + 60
//            }
//            for i in nextStart ..< nextMeta{
//                //songs.append(player.defQueue[i])
//                tmp.append(player.defQueue[i])
//            }
//            sungs[2] = Songs(sectionName: "Next", songsIn: tmp)
//            tmp.removeAll()
//        }else{
//            if player.shufIndex > player.defQueue.count - 60 {
//                nextMeta = player.shufQueue.count
//            }else{
//                nextMeta = player.shufIndex + 60
//            }
//            for i in nextStart ..< nextMeta{
//                tmp.append(player.shufQueue[i])
//            }
//            sungs[2] = Songs(sectionName: "Next", songsIn: tmp)
//            tmp.removeAll()
//        }
//        ////////////////////////// USER
//
//        if(player.isUsrQueue && player.usrIsAnyAfter){
//            var j = player.usrIndex + 1
//            while(j < player.usrQueue.count){
//                tmp.append(player.usrQueue[j])
//                j += 1
//            }
//            sungs.append(Songs(sectionName: "User Queue", songsIn: tmp))
//            tmp.removeAll()
//            (sungs[2], sungs[3]) = (sungs[3], sungs[2])
//            if(!player.usrIsAnyAfter){
//                (sungs[2], sungs[3]) = (sungs[3], sungs[2])
//                sungs.remove(at: 3)
//            }
//        }
//    }
//
//    func deleteByTap2(_ tableView: UITableView, indexPath: IndexPath){
//        if player.isUsrQueue{
//            player.usrQueue.remove(at: player.usrIndex + indexPath.row + 1)
//            sungs[2].songsIn.remove(at: indexPath.row)
//            if !player.usrIsAnyAfter { player.isUsrQueue = false }
//        }else{
//            if player.isShuffle{
//                player.shufQueue.remove(at: player.shufIndex + indexPath.row + 1)
//                sungs[2].songsIn.remove(at: indexPath.row)
//                player.defQueueCount! -= 1
//            }else{
//                player.defQueue.remove(at: player.defIndex + indexPath.row + 1)
//                sungs[2].songsIn.remove(at: indexPath.row)
//                player.defQueueCount! -= 1
//            }
//        }
//        let iPath = IndexPath(row: indexPath.row, section: 2)
//        tableView.deleteRows(at: [iPath], with: .fade)
//        //tableView.reloadData()
//    }
//
//    func deleteByTap3(_ tableView: UITableView, indexPath: IndexPath){
//        if player.isShuffle{
//            player.shufQueue.remove(at: player.shufIndex + indexPath.row + 1)
//            sungs[2].songsIn.remove(at: indexPath.row)
//            player.defQueueCount! -= 1
//        }else{
//            player.defQueue.remove(at: player.defIndex + indexPath.row + 1)
//            sungs[2].songsIn.remove(at: indexPath.row)
//            player.defQueueCount! -= 1
//        }
//    }
//
//    func setColors(){
//        if !lightTheme {
//            dark()
//        }else{
//            light()
//        }
//        fxView.frame = self.view.frame
//        self.tableView.backgroundView = fxView
//    }
//
//    func dark() {
//        upperBar.backgroundColor = UIColor(red: 0.0156862745098039, green: 0.0156862745098039, blue: 0.0156862745098039, alpha: 1.0)
//        mainLabel.textColor = .white
//        doneBtn.setTitleColor(.white, for: .normal)
//        addBtn.setTitleColor(.white, for: .normal)
//        UIApplication.shared.statusBarStyle = .lightContent
//        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//        self.tableView.separatorColor = .black
//    }
//
//    func light() {
//        upperBar.backgroundColor = .white
//        mainLabel.textColor = .black
//        doneBtn.setTitleColor(.black, for: .normal)
//        addBtn.setTitleColor(.black, for: .normal)
//        UIApplication.shared.statusBarStyle = .default
//        fxView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
//        self.tableView.separatorColor = separatorColor
//    }
//
//    func presentPicker() {
//        mediaPicker = MPMediaPickerController(mediaTypes: .music)
//        mediaPicker.delegate = self
//        mediaPicker.allowsPickingMultipleItems = true
//        mediaPicker.showsCloudItems = false
//        mediaPicker.prompt = "Please Pick a Song"
//        mediaPicker.modalTransitionStyle = .crossDissolve
//        present(mediaPicker, animated: true, completion: nil)
//    }
//
//    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//        for picked in mediaItemCollection.items{
//            player.addLast(item: picked)
//        }
//        mediaPicker.dismiss(animated: true, completion: nil)
//        setupQueueArray()
//        tableView.reloadData()
//    }
//
//    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
//        mediaPicker.dismiss(animated: true, completion: nil)
//    }
//
//    func loadHeaders() {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
//        var v = UIView(frame: (cell.frame))
//        cell.setup(title: "Previous", count: 0)
//        if lightTheme {
//            cell.backgroundColor = UIColor.white
//            cell.label.textColor = .black
//        }else{
//            cell.backgroundColor = UIColor.black
//            cell.label.textColor = .white
//        }
//        v = cell.contentView
//        headers.append(v)
//        cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
//        cell.setup(title: "Now Playing", count: 0)
//        if lightTheme {
//            cell.backgroundColor = UIColor.white
//            cell.label.textColor = .black
//        }else{
//            cell.backgroundColor = UIColor.black
//            cell.label.textColor = .white
//        }
//        v = cell.contentView
//        headers.append(v)
//        cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
//        cell.setup(title: "User Queue", count: 0)
//        if lightTheme {
//            cell.backgroundColor = UIColor.white
//            cell.label.textColor = .black
//        }else{
//            cell.backgroundColor = UIColor.black
//            cell.label.textColor = .white
//        }
//        v = cell.contentView
//        headers.append(v)
//        cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
//        cell.setup(title: "Next", count: 0)
//        if lightTheme {
//            cell.backgroundColor = UIColor.white
//            cell.label.textColor = .black
//        }else{
//            cell.backgroundColor = UIColor.black
//            cell.label.textColor = .white
//        }
//        v = cell.contentView
//        headers.append(v)
//    }
//
//}

