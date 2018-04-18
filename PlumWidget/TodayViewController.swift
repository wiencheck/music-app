//
//  TodayViewController.swift
//  PlumWidget
//
//  Created by Adam Wienconek on 06.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    var current = [String]()
    var items = [[String]]()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var year = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: UserDefaults.didChangeNotification, object: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        updateData()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let currentHeight = view.frame.size.height
        preferredContentSize = CGSize(width: view.frame.size.width, height: currentHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateData()
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            var height: CGFloat = 0
            height = 83 + CGFloat(44 * tableView.numberOfRows(inSection: 0))
            preferredContentSize = CGSize(width: maxSize.width, height: height)
        }
        else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
        
    @objc func updateData() {
        if let defaults = UserDefaults.init(suiteName: "group.adw.Plum") {
            if let yea = defaults.value(forKey: "currentYear") as? String {
                if yea != "" {
                    year = ", \(yea)"
                }
            }
            if let rat = defaults.value(forKey: "currentAlbum") as? String {
                albumLabel.text = "\(rat)" + year
            }else{
                albumLabel.text = ""
            }
            items = [[String]]()
            for i in 0 ..< 6 {
                if let arr = defaults.stringArray(forKey: "queue\(i)") {
                    items.append(arr)
                }
                else{
                    break
                }
            }
            titleLabel.text = items[0][0]
            artistLabel.text = items[0][1]
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QueueCellLite
        cell.setup(_title: items[indexPath.row + 1][0], _artist: items[indexPath.row + 1][1])
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
