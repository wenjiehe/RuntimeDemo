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
//        getIvarList()
        
        //获取属性列表
//        getPropertyList()
        
        //获取方法列表
//        getMethodList()
        
        //动态控制成员变量
//        dynamicChangeIvar()
        
        //动态交换两个方法的实现
        dynamicReplaceMethod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }

    //MARK: -- 获取成员变量列表
    func getIvarList() -> Void{
        let surCla = SurprisedView()
        var count: UInt32 = 0
        let list = class_copyIvarList(object_getClass(surCla), &count)
        for index in 0...Int(count) {
            guard let str = ivar_getName((list?[index])!) else { return } //获取变量名称
//            guard let type = ivar_getTypeEncoding((list?[index])!) else {return } //获取变量类型
            print("name = \(String.init(cString: str))")
        }
        free(list)
    }

    //MARK: -- 获取属性列表
    func getPropertyList() -> Void{
        let surCla = SurprisedView()
        var count: UInt32 = 0
        let list = class_copyPropertyList(object_getClass(surCla), &count)
        let c = Int(count)
        if c > 0 {
            for index in 0...c {
                let p = list?[index]
                let str = property_getName(p!)
                print("name = \(String.init(utf8String: str) ?? "meiyou")")
            }
        }
        free(list)
    }
    
    //MARK: -- 获取方法列表
    func getMethodList() -> Void{
        let surCla = SurprisedView()
        var count: UInt32 = 0
        let list = class_copyMethodList(object_getClass(surCla), &count)
        let c = Int(count)
        if c > 0 {
            for index in 0..<c {
                let p = list?[index]
                let str = method_getName(p!)
                print("method = \(NSStringFromSelector(str))")
            }
        }
        free(list)
    }
        
    //MARK: -- 动态变量控制
    func dynamicChangeIvar() -> Void{
        let surCla = SurprisedView()
        print(surCla.age)
        var count: UInt32 = 0
        let list = class_copyIvarList(object_getClass(surCla), &count)
        let c = Int(count)
        if c > 0 {
            for index in 0..<c {
                guard let str = ivar_getName((list?[index])!) else { return } //获取变量名称
                let name = String.init(cString: str)
                if name == "age" {
                    print("age = \(name)")
                }
                print("name = \(name)")
            }
        }
        free(list)
    }
    
    //MARK: -- 动态添加方法
    func dynamicAddMethod() -> Void{
        
    }
    
    //MARK: -- 动态交换两个方法的实现
    func dynamicReplaceMethod() -> Void{
        let originMethod = class_getInstanceMethod(object_getClass(self), #selector(viewDidAppear(_:)))
        let swizeeMethod = class_getInstanceMethod(object_getClass(self), #selector(customDidAppear(_:)))
        method_exchangeImplementations(originMethod!, swizeeMethod!)
    }
    
    @objc dynamic func customDidAppear(_ animated: Bool) -> Void{
        print("customDidAppear")
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

