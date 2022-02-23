//
//  Api.swift
//  BTNetwork
//
//  Created by Rodrigo Baroni on 16/08/21.
//

import Foundation

public protocol ApiProtocol {
    func request<T>(url: String,
                 method: RequestType,
                 with parameters: [String: Any]?,
                 queryParams: [String: Any]?,
                 headers: [String: String]?,
                 token: String,
                 completion: @escaping (Result<T, ResultError>) -> Void) where T: Codable
}

public extension ApiProtocol {
    func request<T>(url: String,
                 method: RequestType,
                 with parameters: [String: Any]?,
                 queryParams: [String: Any]? = nil,
                 headers: [String: String]? = nil,
                 token: String = String(),
                 completion: @escaping (Result<T, ResultError>) -> Void) where T: Codable {
        request(url: url, method: method, with: parameters, queryParams: queryParams, headers: headers, token: token, completion: completion)
    }
}

public class Api: NSObject, ApiProtocol {
    
    public func request<T>(url: String, method: RequestType, with parameters: [String : Any]?, queryParams: [String: Any]? = nil, headers: [String: String]? = nil, token: String, completion: @escaping (Result<T, ResultError>) -> Void) where T: Codable {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)

        var urlRequest: URLRequest?

        switch method {
        case .GET:
            urlRequest = RequestGet.build(url, with: parameters, or: nil, headers: headers ?? internalHeaders())
        case .POST:
            urlRequest = RequestPost.create(url, with: parameters, headers: headers ?? internalHeaders())
        case .PUT: urlRequest = RequestPut.create(url, with: parameters, queryParams: queryParams, headers: headers ?? internalHeaders())
        case .DELETE: break
        case .PATCH:
            urlRequest = RequestPatch.build(url, with: queryParams, or: nil, headers: headers ?? internalHeaders())
        }

        guard let myRequest = urlRequest else {
            completion(.failure(.badRequest))
            return
        }

        let task = session.dataTask(with: myRequest, completionHandler: { (result, urlResponse, error) in
            var statusCode: Int = 0
            
            if let response = urlResponse as? HTTPURLResponse {
               statusCode = response.statusCode
            }

            guard let data = result else {
                completion(.failure(.custom(NSLocalizedString("Something went wrong, check your connection, and try again", comment: ""))))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [DateFormatter.standard, DateFormatter.standardT]
                let decodableData = try decoder.decode(T.self, from: data)
                
                switch statusCode {
                case 200, 202:
                    completion(.success(decodableData))
                case 400:
                    completion(.failure(.badRequest))
                case 404:
                    completion(.failure(.custom(NSLocalizedString("Something went wrong, check your connection, and try again", comment: ""))))
                case 409:
                    completion(.failure(.custom(NSLocalizedString("Something went wrong, check your connection, and try again", comment: ""))))
                case 500:
                    completion(.failure(.internalServerError))
                default:
                    completion(.failure(.custom(NSLocalizedString("Something went wrong, check your connection, and try again", comment: ""))))
                }
                
            } catch {
                completion(.failure(.undecodable))
            }
        })
        task.resume()
    }
    
    private func internalHeaders() -> [String: String] {
        
        return [
            "Content-Type": "application/json",
        ]
    }
}

