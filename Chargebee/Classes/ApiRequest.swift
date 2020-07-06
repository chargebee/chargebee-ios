//
// Created by Mac Book on 6/7/20.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Decodable
    var methodPath: String { get }
    var baseUrl: String { get set }
    var authHeader: String { get set }
}

@available(macCatalyst 13.0, *)
extension APIResource {
    var url: URLRequest {
        let url = URL(string: baseUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        return urlRequest
    }
}

class APIRequest<Resource: APIResource> {
    let resource: Resource

    init(resource: Resource) {
        self.resource = resource
    }
}

extension APIRequest: NetworkRequest {
    func decode(_ data: Data) -> Resource.ModelType? {
        return try? JSONDecoder().decode(Resource.ModelType.self, from: data)
    }

    func load(withCompletion completion: @escaping (Resource.ModelType?) -> Void) {
        load(resource.url, withCompletion: completion)
    }
}