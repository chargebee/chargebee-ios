//
//  CBSDKItemTableViewCell.swift
//  Chargebee_Example
//
//  Created by Harish Bharadwaj on 22/07/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

class CBSDKItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var idLabel: UILabel!

    // MARK: - Public Properties
    var item: CBItemWrapper?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
