//
//  ImageTableViewCell.swift
//  CIS
//
//  Created by Kevin Pan on 2020-05-04.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ImageTableViewCell {

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {

        imgCollectionView.delegate = dataSourceDelegate
        imgCollectionView.dataSource = dataSourceDelegate
        imgCollectionView.tag = row
        imgCollectionView.setContentOffset(imgCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        imgCollectionView.reloadData()
    }

    var collectionViewOffset: CGFloat {
        set { imgCollectionView.contentOffset.x = newValue }
        get { return imgCollectionView.contentOffset.x }
    }
}
