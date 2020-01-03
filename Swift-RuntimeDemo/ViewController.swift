//
//  ViewController.swift
//  Swift-RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/2.
//  Copyright © 2020 贺文杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //获取成员变量列表
        getIvarList()
    }

    //MARK: -- 获取成员变量列表
    func getIvarList() -> Void{
        let count : UnsafeMutablePointer<UInt32>
        var list : UnsafeMutablePointer<Ivar> = class_copyIvarList(SurprisedView.layerClass, count) ?? UnsafeMutablePointer.init(Ivar)
        for var v : Ivar in list {
            var str = String.init(cString: ivar_getName(v)) //获取变量名称
            var type = String.init(cString: ivar_getTypeEncoding(v)) //获取变量类型
            print("str = \(str),type = \(type)")
        }
        free(list)
    }

    //MARK: -- 获取属性列表
    func getPropertyList() -> Void{
        
    }
    
    //MARK: -- 获取方法列表
    func getMethodList() -> Void{
        
    }
    
    //MARK: -- 获取协议列表
    func getProtocolList() -> Void{
        
    }
    
    //MARK: -- 动态变量控制
    func dynamicChangeIvar() -> Void{
        
    }
    
    //MARK: -- 动态添加方法
    func dynamicAddMethod() -> Void{
        
    }
    
    //MARK: -- 动态交换两个方法的实现
    func dynamicReplaceMethod() -> Void{
        
    }
    
    func customDidAppear(_ animated: Bool) -> Void{
        customDidAppear(animated)
    }
    
    //MARK: -- 拦截并替换方法
    func changeMethod() -> Void{
        
    }
    
    //MARK: -- 实现NSCoding的自动归档和解档
    func automicKeyedArchiver() -> Void{
        
    }
    
    func automicKeyedUnarchiver() -> Void{
        
    }
    
    //MARK: -- 实现字典转模型和模型转字典的自动转换
    func automicChangeModel() -> Void {
        
    }
}

