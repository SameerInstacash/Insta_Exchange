//
//  StoreDetailsTblCell.swift
//  SmartExchange
//
//  Created by Sameer Khan on 26/07/23.
//  Copyright © 2023 ZeroWaste. All rights reserved.
//

import UIKit

class StoreDetailsTblCell: UITableViewCell {
    
    @IBOutlet weak var storeImageVW: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblStoreLocation: UILabel!
    //@IBOutlet weak var lblStoreCode: UILabel!
    @IBOutlet weak var lblStoreToken: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
