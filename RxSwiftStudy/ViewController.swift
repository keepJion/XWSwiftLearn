//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by Mr.xiao on 2017/10/22.
//  Copyright © 2017年 keepJion. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Moya

import Then

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _ = DisposeBag()
        
        let provider = MoyaProvider<APIManager>()
        
        
        provider.request(.getVersion) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data // Data, your JSON response is probably in here!
                let dataString = String.init(data: data, encoding: String.Encoding.utf8)
                let zv = ZVersion.deserialize(from: dataString);
                let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
                let msg = zv?.latest
                print("data = \(msg!),status = \(statusCode)")
            // do something in your app
            case let .failure(error):
                
                print(error)
            }
        }
        let imgName = "xiaowei"
        provider.request(.downloadImg(imageName: imgName), callbackQueue: DispatchQueue.global(), progress: { (progress) in
            print("progress is \(progress.progress)")
        }) { (result) in
            switch result {
            case .success:
                let filep:URL = DefaultDownloadDir.appendingPathComponent(imgName)
                let img = UIImage(contentsOfFile: filep.path)
                print("下载完成")
            case let .failure(error):
                print(error)
            }
        }
        
        let cusProvide = MoyaProvider<APIManager>(plugins:[CustomLoadView.init(viewCtrl: self, token: "xiaowei")])
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

