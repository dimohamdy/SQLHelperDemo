//
//  ViewController.swift
//  SQLHelperDemo
//
//  Created by binaryboy on 3/28/15.
//  Copyright (c) 2015 AhmedHamdy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var sqlHelper:SQLHelperAuto=SQLHelperAuto()
       
        var result:CBool = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[10, 29, "image", "name"]);
        
         result = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[10, 29, "image", "name"]);
         result = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[20, 29, "image", "name"]);
         result = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[30, 29, "image", "name"]);
        result = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[40, 29, "image", "name"]);
         result = SQLHelperAuto.insertOrReplaceintoTable("product",attruibtes:["productID","productLineID","image","productName"] as [String], tovalues:[50, 29, "image", "name"]);
        
        var resultArray:NSMutableArray = SQLHelperAuto.executeReaderselectColums(["*"],  FromTable:"product", whereAttruibtes:nil ,equalValues:nil ,orderBy:nil)
        
        result = SQLHelperAuto.updateTable("product",setAttruibtes: ["productID", "productLineID", "image", "productName"] as NSArray, toValuses: [String(4) , String(10), "image", "name"] as NSArray, whereStatment:"productLineID = 10");
        
        
        result = SQLHelperAuto.deleteFromTable("product",whereAttruibtes:["productID"],equalValues:[10])
        
        
        var resultString:String? = SQLHelperAuto.executeStringselectColums(["image"], FromTable: "product", whereAttruibtes: ["productID"] as [String], equalValues: ["50"])
        
        var resultInt:Int? = SQLHelperAuto.executeNumberselectColums(["productID"], FromTable: "product", whereAttruibtes: ["productID"] as [String], equalValues: ["50"])


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

