//
//  RatingVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class LyricsVC: UIViewController {
   
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dragBtn: UIButton!
    var current: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        current = GlobalSettings.lyrics
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
                self.dragBtn.setTitleColor(.white, for: .normal)
                self.dragBtn.backgroundColor = GlobalSettings.tint.color
            })
    }
    
    func enable() {
            UIView.animate(withDuration: 0.2, animations: {
                self.leftView.backgroundColor = GlobalSettings.tint.color
                self.leftLabel.textColor = GlobalSettings.tint.bar
                self.rightView.backgroundColor = GlobalSettings.tint.color
                self.rightLabel.textColor = GlobalSettings.tint.bar
                self.dragBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
                self.dragBtn.backgroundColor = .white
            })
    }
    
    func setText() {
        let s = "When enabled you will receive lyrics on lockscreen every time the song changes. This works only with embedeed lyrics, Plum doesn't download any lyrics from the web."
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = s
    }
    
    func setButton() {
        if GlobalSettings.lyrics {
            dragBtn.setTitleColor(.white, for: .normal)
            dragBtn.backgroundColor = GlobalSettings.tint.color
        }else{
            dragBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
            dragBtn.backgroundColor = .white
        }
    }
    
    @IBAction func dragBtnPressed(_ sender: UIButton) {
        GlobalSettings.changeLyrics(!GlobalSettings.lyrics)
        if GlobalSettings.lyrics {
            self.enable()
        }else{
            self.disable()
        }
        current = GlobalSettings.lyrics
    }


}
