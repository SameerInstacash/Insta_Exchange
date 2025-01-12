//
//  StoreLocationTblCell.swift
//  SmartExchange
//
//  Created by Sameer Khan on 26/07/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit

class StoreLocationTblCell: UITableViewCell {
    
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var lblStoreLocation: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
