//
//  IconsVC.swift
//  Plum
//
//  Created by Adam Wienconek on 13.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class IconsVC: UIViewController {
    
    var icons: [UIImage] = [#imageLiteral(resourceName: "six.png")]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segment: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 10
        flow.minimumLineSpacing = 4
        //collectionView.setCollectionViewLayout(flow, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.x)
//        let point = scrollView.contentOffset
//        guard let path = collectionView.indexPathForItem(at: point) else {return}
//        collectionView.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
//    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(scrollView.contentOffset.x)
        let point = scrollView.contentOffset
        guard let path = collectionView.indexPathForItem(at: point) else {return}
        collectionView.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
    }

}

extension IconsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IconCell
        cell.icon.image = icons[indexPath.row]
        return cell
    }
    
    
    
}
