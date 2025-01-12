//
//  CosmeticQuestionTblCell.swift
//  SmartExchange
//
//  Created by Sameer Khan on 19/08/22.
//  Copyright © 2022 ZeroWaste. All rights reserved.
//

import UIKit

class CosmeticQuestionTblCell: UITableViewCell {
    
    @IBOutlet weak var baseContentView: UIView!
    //@IBOutlet weak var img_icon_ContentainerView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var lblIconName: UILabel!
    @IBOutlet weak var imageInfoBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
