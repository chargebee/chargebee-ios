////
//// Created by Mac Book on 5/7/20.
//// Copyright (c) 2020 chargebee. All rights reserved.
////
//
import Foundation
//
//struct Wrapper {
//    let apmConfig: [String: PaymentList]
//}
//
//struct AllWrapper<T: Decodable>: Decodable {
//    let items: [T]
//}
//
//extension Wrapper : Decodable{
//    enum CodingKeys: String, CodingKey {
//        case apmConfig = "apm_config"
//    }
//}
////
////struct PaymentConfig {
////    let usd: PaymentList
////}
////
////extension PaymentConfig: Decodable {
////    enum CodingKeys: String, CodingKey {
////        case usd = "USD"
////    }
////}
//
//struct PaymentList {
//    let pmList: [PaymentMethod]
//}
//
//extension PaymentList: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case pmList = "pm_list"
//    }
//}
//
//struct PaymentMethod {
//    let id: String
//    let type: String
//}
//
//extension PaymentMethod: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case id
//        case type
//    }
//}
//
let paymentConfigUrl = "https://test-ashwin1-test.chargebee.com/api/internal/component/retrieve_config"

@available(macCatalyst 13.0, *)
class ApiClient {
    func getPaymentConfigs(completion handler: @escaping ((CBWrapper?) -> Void)) {

        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let url = URL(string: paymentConfigUrl)!
        var urlRequest = URLRequest(url:    url)
        
        urlRequest.addValue("Basic test_1PDU9iynvhEcPMgWAJ0QZw90d2Aw92ah", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Parse the data in the response and use it
            guard let data = data else {
                handler(nil)
                return
            }
            let wrapper = try? JSONDecoder().decode(CBWrapper.self, from: data)
            handler(wrapper)
        })
        task.resume()
    }
}
