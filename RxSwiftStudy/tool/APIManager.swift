//
//  APIManager.swift
//  RxSwiftStudy
//
//  Created by Mr.xiao on 2017/10/22.
//  Copyright © 2017年 keepJion. All rights reserved.
//

import UIKit
import Moya
import Result


enum APIManager {
    case getVersion
    case getUser(firstName:String,secondName:String)
    case updateUser(id:Int,firstName:String,secondName:String)
    case downloadImg(imageName:String)
}

extension APIManager: TargetType {
    
    var baseURL: URL {
        return URL.init(string: "https://news-at.zhihu.com/api/")!
    }
    
    var path: String {
        switch self {
        case .getVersion:
            return "4/version/ios/2.3.0"
        case .getUser(let firstName, let secondName):
            return "4/version/ios/\(firstName)/\(secondName)"
        case .updateUser(let id, _, _):
            return "4/version/ios/\(id)"
        case .downloadImg(let imgName):
            return "4/version/ios/\(imgName)"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .getVersion,.getUser(_,_):
            return .get
        case .updateUser(_, _, _):
            return .post
        case .downloadImg(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .getVersion:
            return .requestPlain
        case let .getUser(firstName,secondName):
            return .requestParameters(parameters: ["firstName":firstName,"secondName":secondName], encoding: JSONEncoding.default)
        case let .updateUser(_,firstName,_):
            return .requestParameters(parameters: ["firstName":firstName], encoding: JSONEncoding.default)
        case let .downloadImg(imgName):
            let p = ["img":imgName]
            let lp:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let localPath : DownloadDestination = {
                (_,_) in
                return (lp,.removePreviousFile)
            }
            return .downloadParameters(parameters: p, encoding: JSONEncoding.default, destination: localPath)
        }
    }
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}


private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (DefaultDownloadDir.appendingPathComponent(response.suggestedFilename!), [.removePreviousFile])
}

//默认下载保存地址（用户文档目录）
let DefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

class CustomLoadView: PluginType {
    private let token : String = ""
    private let viewCtrl : UIViewController
    private let spinner : UIActivityIndicatorView
    
    init(viewCtrl:UIViewController, token:String) {
        self.viewCtrl = viewCtrl
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.spinner.center = self.viewCtrl.view.center
    }
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        let length = token.characters.count
        if length > 1 {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        self.viewCtrl.view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        spinner.removeFromSuperview()
        spinner.stopAnimating()
        
        guard case let Result.failure(error) = result else {
            return
        }
        let message = error.errorDescription ?? "未知错误"
        let alertC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            
        }))
        self.viewCtrl.present(alertC, animated: true, completion: nil)
        
    }
    //处理请求结果
//    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//
//    }
    
}



