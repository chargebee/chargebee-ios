//
//  ProductTableViewCell.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 24/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

protocol ProductTableViewCellDelegate: class {
    func buyClicked(withProduct: CBProduct)
    func buyProduct(withProduct: CBProduct)
}

final class CBSDKProductTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    // MARK: - Public Properties
    var product: CBProduct?
    weak var delegate: ProductTableViewCellDelegate?

    // MARK: IBActions
    @IBAction private func actionBtnClicked(_ sender: Any) {
        guard let product = product else { return }
        delegate?.buyClicked(withProduct: product)
    }
}
