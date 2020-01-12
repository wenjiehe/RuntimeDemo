//
//  SurprisedView.swift
//  Swift-RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/3.
//  Copyright © 2020 贺文杰. All rights reserved.
//

import Foundation
import UIKit

class SurprisedView: UIView {
    
    var name:String
    var age:String
    var url:URL
    var ary: [String] = ["sdj", "sjdief"]
    var btn: UIButton?
    
    override init(frame: CGRect) {
        name = "李沐宸"
        age = "23"
        url = URL(string: "https://www.baidu.com")!
        btn = UIButton(type: .custom)
        btn?.setTitle("删除" , for: .normal)
        btn!.addTarget(SurprisedView.self, action: #selector(clickButton), for: .touchUpInside)
        
        super.init(frame: frame)

        self.addSubview(self.btn!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickButton(){
        print("恰似当年故里正飞花")
    }
    
}
