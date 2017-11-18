//
//  MiniPlayerVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class MiniPlayerVC: UIViewController {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dragBtn: UIButton!
    var current: styles!

    override func viewDidLoad() {
        super.viewDidLoad()
        current = GlobalSettings.popupStyle
        leftView.layer.cornerRadius = 4.0
        leftImage.layer.cornerRadius = 4.0
        rightView.layer.cornerRadius = 4.0
        rightImage.layer.cornerRadius = 4.0
        dragBtn.layer.cornerRadius = 4.0
        dragBtn.layer.borderWidth = 0.5
        dragBtn.layer.borderColor = GlobalSettings.tint.color.cgColor
        setButton()
        if current == .modern {
            rightView.backgroundColor = GlobalSettings.tint.color
            rightLabel.textColor = GlobalSettings.tint.bar
        }else{
            leftView.backgroundColor = GlobalSettings.tint.color
            leftLabel.textColor = GlobalSettings.tint.bar
        }
        setText()
        setGestures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGestures() {
        let mg = UITapGestureRecognizer(target: self, action: #selector(tapOnright))
        mg.numberOfTapsRequired = 1
        rightView.addGestureRecognizer(mg)
        let cg = UITapGestureRecognizer(target: self, action: #selector(tapOnleft))
        cg.numberOfTapsRequired = 1
        leftView.addGestureRecognizer(cg)
    }

    @objc func tapOnright() {
        if current == .classic {
            UIView.animate(withDuration: 0.2, animations: {
                self.rightView.backgroundColor = GlobalSettings.tint.color
                self.rightLabel.textColor = GlobalSettings.tint.bar
                self.leftView.backgroundColor = .white
                self.leftLabel.textColor = .black
            })
        }
        current = .modern
        GlobalSettings.changePopupStyle(.modern)
    }
    
    @objc func tapOnleft() {
        if current == .modern {
            UIView.animate(withDuration: 0.2, animations: {
                self.leftView.backgroundColor = GlobalSettings.tint.color
                self.leftLabel.textColor = GlobalSettings.tint.bar
                self.rightView.backgroundColor = .white
                self.rightLabel.textColor = .black
            })
        }
        current = .classic
        GlobalSettings.changePopupStyle(.classic)
    }
    
    func setText() {
        let s = "\nClassic: iOS9 style\n\nModern: iOS10 style"
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = s
    }
    
    func setButton() {
        if GlobalSettings.popupDrag {
            dragBtn.setTitleColor(.white, for: .normal)
            dragBtn.backgroundColor = GlobalSettings.tint.color
        }else{
            dragBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
            dragBtn.backgroundColor = .white
        }
    }
    
    @IBAction func dragBtnPressed(_ sender: UIButton) {
        GlobalSettings.changePopupDrag(!GlobalSettings.popupDrag)
        if GlobalSettings.popupDrag {
            UIView.animate(withDuration: 0.2, animations: {
                self.dragBtn.setTitleColor(.white, for: .normal)
                self.dragBtn.backgroundColor = GlobalSettings.tint.color
            })
        }else{
            UIView.animate(withDuration: 0.2, animations: {
                self.dragBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
                self.dragBtn.backgroundColor = .white
            })
        }
    }

}
