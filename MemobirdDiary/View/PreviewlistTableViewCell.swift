//
//  PreviewlistTableViewCell.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 20/11/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit

class PreviewlistTableViewCell: UITableViewCell {
    @IBOutlet weak var myCellLabel: UILabel!

    @IBOutlet weak var previewimageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
