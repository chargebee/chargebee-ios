//
//  Operations.swift
//  Chargebee
//
//  Created by ramesh_g on 10/03/23.
//

import UIKit

class BackgroundOperationQueue: OperationQueue {

    private static var operationsKeyPath: String {
        return "operations"
    }

    deinit {
        self.removeObserver(self, forKeyPath: "operations")
    }

    var completionBlock: (() -> Void)? {
        didSet {
            self.addObserver(self, forKeyPath: BackgroundOperationQueue.operationsKeyPath, options: .new, context: nil)
        }
    }

    override init() {
        super.init()
    }

    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutableRawPointer) {
        if let operationPath = keyPath, operationPath == BackgroundOperationQueue.operationsKeyPath {
            if self.operations.isEmpty {
                OperationQueue.main.addOperation({
                    self.completionBlock?()
                })
            }
        }
    }

}
