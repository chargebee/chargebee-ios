//
//  CBSDKPlansViewController.swift
//  Chargebee_Example
//
//  Created by CB/IT/01/1039 on 09/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee
class CBSDKPlansViewController: UIViewController {
    var plans = [CBPlan]()
    let plansTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(plansTableView)
        plansTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor)
        plansTableView.register(CBSDKPlanTableViewCell.self, forCellReuseIdentifier: "CBSDKPlanTableViewCell")
        CBSDKPlanTableViewCell.registerCellXib(with: self.plansTableView)
        plansTableView.delegate = self
        plansTableView.dataSource = self
    }
}

extension CBSDKPlansViewController {
    func render(_ model :[CBPlan]) {
        self.plans = model
        plansTableView.reloadData()
    }
}

extension CBSDKPlansViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.plans.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CBSDKPlanTableViewCell", for: indexPath) as! CBSDKPlanTableViewCell
        let plan = self.plans[indexPath.row]
        cell.nameLabel.text = plan.name
        cell.idLabel.text = "id : \(plan.id)"
        cell.statusLabel.text = plan.status
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
