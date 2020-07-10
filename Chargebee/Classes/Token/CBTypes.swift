//
// Created by Mac Book on 5/7/20.
// Copyright (c) 2020 chargebee. All rights reserved.
//

import Foundation


protocol URLEncodedRequestBody {
    func toFormBody() -> [String: String]
}
