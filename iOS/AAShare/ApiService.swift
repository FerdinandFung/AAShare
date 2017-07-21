//
//  ApiService.swift
//  AAShare
//
//  Created by Chen Tom on 08/11/2016.
//  Copyright © 2016 Chen Zheng. All rights reserved.
//

import Foundation
import RxSwift

import Alamofire
import Moya
import RxMoya
import Result

import Argo
import Runes
import Curry

import SwiftyBeaver
import XCGLogger

import Secrecy

enum NetError: Swift.Error {
    case NetNoRepresentor
    case NetNotSuccessfulHTTP
    case NetNoData
    case NetCouldNotMakeObject
}

private let logger = SwiftyBeaver.self

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

// MARK: RxSwift help

extension Observable {
    func loggingPrint<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
            let value = object()
            let stringRepresentation: String
            
            if let value = value as? CustomDebugStringConvertible {
                stringRepresentation = value.debugDescription
            } else if let value = value as? CustomStringConvertible {
                stringRepresentation = value.description
            } else {
                fatalError("loggingPrint only works for values that conform to CustomDebugStringConvertible or CustomStringConvertible")
            }
            
            let fileURL = URL(string: file)?.lastPathComponent ?? "Unknown file"
            let queue = Thread.isMainThread ? "UI" : "BG"
            
            print("<\(queue)> \(fileURL) \(function)[\(line)]: " + stringRepresentation)
        #endif
    }
    
    private func resultFromJSON<T: Decodable>(_ object:[String: AnyObject], classType: T.Type) -> T? {
//        let tmpobject = ["errcode" : 0, "data" : "", "errdesc" : ""] as [String : Any]
        let decoded = classType.decode(JSON.init(object))
        switch decoded {
        case .success(let result):
            return result as? T
        case .failure(let error):
            logger.error("\(error)")
            return nil
            
        }
    }
    
    func mapSuccessfulHTTPToObject<T: Decodable>(type: T.Type) throws -> Observable<T> {
        return map { representor in
            guard let response = representor as? Moya.Response else {
                throw NetError.NetNoRepresentor
            }
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String: AnyObject] {
                    logger.error("Got error message: \(json)")
                }
                throw NetError.NetNotSuccessfulHTTP
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String: AnyObject] else {
                    throw NetError.NetCouldNotMakeObject
                }
                return self.resultFromJSON(json, classType:type)!
            } catch {
                throw NetError.NetCouldNotMakeObject
            }
        }
    }
    
    func mapSuccessfulHTTPToObjectArray<T: Decodable>(type: T.Type) throws -> Observable<[T]> {
        return map { response in
            guard let response = response as? Moya.Response else {
                throw NetError.NetNoRepresentor
            }
            
            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String: AnyObject] {
                    logger.error("Got error message: \(json)")
                }
                throw NetError.NetNotSuccessfulHTTP
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [[String : AnyObject]] else {
                    throw NetError.NetCouldNotMakeObject
                }
                
                // Objects are not guaranteed, thus cannot directly map.
                var objects = [T]()
                for dict in json {
                    if let obj = self.resultFromJSON(dict, classType:type) {
                        objects.append(obj)
                    }
                }
                return objects
                
            } catch {
                throw NetError.NetCouldNotMakeObject
            }
        }
    }
}

// MARK: - Provider setup
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

typealias MyAPICallCustomEncoding = (URLRequestConvertible, [String:AnyObject]?) -> (NSMutableURLRequest, NSError?)

let MyAPICallCustomEncodingClosure: MyAPICallCustomEncoding = { request, data in
    let sort = NSURLQueryItem(name: "sort", value: "distance")
    var req = request as! NSMutableURLRequest
    
    guard var components = NSURLComponents(string: req.url!.absoluteString)
        else {
            // even though this is an error, Alamofire ignores the returned error.
            return (req, nil)
    }
    //Create our query string params
    components.queryItems = [sort as URLQueryItem]
    req.url = components.url
    
    //Add our JSON body
    do {
        let json = try JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json
    } catch {
        return (req, nil)
    }
    return (req, nil)
}

// MARK: - Provider support
private extension String {
    var urlEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

struct CustomParameterEncoding: ParameterEncoding {
    
    public static var `default`: CustomParameterEncoding { return CustomParameterEncoding() }
    
    
    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - parameter urlRequest: The request to have parameters applied.
    /// - parameter parameters: The parameters to apply.
    ///
    /// - throws: An `AFError.parameterEncodingFailed` error if encoding fails.
    ///
    /// - returns: The encoded request.
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var req = try urlRequest.asURLRequest()
//        let json = try JSONSerialization.data(withJSONObject: parameters!["jsonArray"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
//        let json = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonStr = [
                "action" : "get_update_version",
                "data" : "eyAidXNlcmlkIiA6ICI4MDU1IiwgImRldmlkIiA6ICJFODI2RkE4Ri00NUEzLTQ0MjQtQjdBQi03MDBBOEU4MDFDQUUifQ==",
                "sign" : "d3f08040b02228559e281abd80f4ce09"
                ]
        let json2 = try JSONSerialization.data(withJSONObject: jsonStr, options: JSONSerialization.WritingOptions.prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json2
        return req
    }
    
}

private let endpointClosure = { (target: RruuApi) -> Endpoint<RruuApi> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<RruuApi> = Endpoint<RruuApi>(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: CustomParameterEncoding.default)

    // Sign all non-authenticating requests
    return endpoint
}

private let requestClosure = { (endpoint: Endpoint<RruuApi>, done: MoyaProvider.RequestResultClosure) in
    var request = endpoint.urlRequest
    
    // Modify the request however you like.
    
    done(Result.success(request!))
}

private let rruuProvider = RxMoyaProvider<RruuApi>(
//                                                   endpointClosure: endpointClosure,
                                                   requestClosure: requestClosure,
//                                                   manager: DefaultAlamofireManager.sharedManager,
                                                   plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

private var disposeBag = DisposeBag()

// MARK: - RruuApi
private let baseVersion             = "client/v5/app.api"
private let baseCommentVersion      = "client/v5/cmmt.api"
//测试地址
private let baseHostUrl             = "http://qa.api.rruu.com/"
//正式地址
//private let baseHostUrl             = "http://api.rruu.com/"

private let MD5_SECURE_KEY          = "492B90DAAE779C37D56F828856A0CC42"

public enum RruuApi {
    case getTargetSelect(city: String)
}

//MARK: - TargetType Protocol Implementation
extension RruuApi: TargetType {
    
//MARK: help method
    private func realParameters(_ strData: String) -> [String: Any] {
        let originStr = strData + MD5_SECURE_KEY
        let md5Sign = originStr.tcz_md5();
        let md5str = originStr.digestHex(DigestAlgorithm.md5)
        
        logger.debug("tcz_md5 : \(md5Sign)")
        logger.debug("other_md5 : \(md5str)")
        print("tcz_md5 : \(md5Sign)")
        print("other_md5 : \(md5str)")
        print("tcz....1 : " + strData)
        print("tcz....2 : " + strData.tcz_base64EncodedString())
        
        return ["action": "get_update_version",
                "data": strData.tcz_base64EncodedString(),
                "sign": md5Sign,
                ]
    }
    
//MARK: Moya TargetType
    public var baseURL: URL { return URL(string: baseHostUrl + baseVersion)! }
    
    public var path: String {
        switch self {
        case .getTargetSelect(_):
            return ""
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getTargetSelect(_):
            let str = "{ \"userid\" : \"8055\", \"devid\" : \"E826FA8F-45A3-4424-B7AB-700A8E801CAE\"}"
            return realParameters(str)
        }
    }
    
    public var task: Task {
        return .request
    }
    
    public var sampleData: Data {
        switch self {
        case .getTargetSelect(_):
            return "getTargetSelect.".data(using: String.Encoding.utf8)!
        }
    }
    
    var multipartBody: [Moya.MultipartFormData]? {
        // Optional
        return nil
    }
    
    
    //MARK: API Function
    static func apiGetTargetSelect(cityId: String, completion: @escaping (Item) -> Void) {
        disposeBag = DisposeBag()
        do {
            try rruuProvider
                .request(.getTargetSelect(city: cityId))
                .mapSuccessfulHTTPToObject(type: Item.self)
                .subscribe(
                    onNext: { item in
                        completion(item)
                    }
                )
                .addDisposableTo(disposeBag)
        } catch {
            logger.error("getTargetSelect error")
        }
    }
}
