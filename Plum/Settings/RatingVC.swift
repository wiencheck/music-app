//
//  RatingVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class RatingVC: UIViewController {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dragBtn: UIButton!
    @IBOutlet weak var setBrn: UIButton!
    var current: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        current = GlobalSettings.ratingMode
        leftView.layer.cornerRadius = 4.0
        leftImage.layer.cornerRadius = 4.0
        rightView.layer.cornerRadius = 4.0
        rightImage.layer.cornerRadius = 4.0
        dragBtn.layer.cornerRadius = 4.0
        dragBtn.layer.borderWidth = 1.0
        dragBtn.layer.borderColor = GlobalSettings.tint.color.cgColor
        setButton()
        if current{
            rightView.backgroundColor = GlobalSettings.tint.color
            rightLabel.textColor = GlobalSettings.tint.bar
            leftView.backgroundColor = GlobalSettings.tint.color
            leftLabel.textColor = GlobalSettings.tint.bar
        }else{
            rightView.backgroundColor = .white
            rightLabel.textColor = .black
            leftView.backgroundColor = .white
            leftLabel.textColor = .black
        }
        setText()
    }
    
    func disable() {
        UIView.animate(withDuration: 0.2, animations: {
            self.leftView.backgroundColor = .white
            self.leftLabel.textColor = .black
            self.rightView.backgroundColor = .white
            self.rightLabel.textColor = .black
        })
    }
    
    func enable() {
        UIView.animate(withDuration: 0.2, animations: {
            self.leftView.backgroundColor = GlobalSettings.tint.color
            self.leftLabel.textColor = GlobalSettings.tint.bar
            self.rightView.backgroundColor = GlobalSettings.tint.color
            self.rightLabel.textColor = GlobalSettings.tint.bar
        })
        dragBtn.setTitle("Disable", for: .normal)
    }
    
    func setText() {
        let s = "When enabled you will be able to see song's ratings on lockscreen and in app when browsing library (like in iTunes). You will also be able to rate songs right from lockscreen"
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = s
    }
    
    func setButton() {
        if GlobalSettings.ratingMode {
            dragBtn.setTitle("Enable", for: .normal)
        }else{
            dragBtn.setTitle("Disable", for: .normal)
        }
        self.dragBtn.setTitleColor(.white, for: .normal)
        self.dragBtn.backgroundColor = GlobalSettings.tint.color
        self.setBrn.setTitleColor(.white, for: .normal)
        self.setBrn.backgroundColor = GlobalSettings.tint.color
    }
    
    @IBAction func dragBtnPressed(_ sender: UIButton) {
        GlobalSettings.changeRatingMode(!GlobalSettings.lyrics, full: GlobalSettings.full)
        if GlobalSettings.ratingMode {
            self.enable()
        }else{
            self.disable()
        }
        current = GlobalSettings.ratingMode
    }
    
    @IBAction func setBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "setratings", sender: nil)
    }
    
}

