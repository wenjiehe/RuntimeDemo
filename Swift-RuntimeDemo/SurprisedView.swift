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
    
    var name = "李沐宸"
    var age = "23"
    var url = NSURL.init(string: "https://www.baidu.com")
    var ary : [String] = ["sdj", "sjdief"]
    var btn : UIButton
    
    override init(frame: CGRect) {
        self.btn.setTitle("删除", for: .normal)
        self.btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        self.addSubview(self.btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickButton(){
        print("恰似当年故里正飞花")
    }
    
}
