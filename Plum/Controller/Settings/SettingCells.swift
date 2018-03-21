//
//  SettingCells.swift
//  Plum
//
//  Created by Adam Wienconek on 29.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    var callBack: ((String) -> ())?
    func setup(title: String, detail: String){
        textLabel?.text = title
        detailTextLabel?.text = detail
    }
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailSwitch: UISwitch!
    func setup(title: String, on: Bool){
        mainLabel.text = title
        detailSwitch.isOn = on
    }
}

class ColorTintCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    func setup(title: String, color: UIColor){
        mainLabel.text = title
        colorView.backgroundColor = color
    }
}
