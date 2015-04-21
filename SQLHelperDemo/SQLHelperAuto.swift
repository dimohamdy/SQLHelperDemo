//
//  SQLHelperAuto.swift
//  SQLHelperDemo
//
//  Created by binaryboy on 4/20/15.
//  Copyright (c) 2015 AhmedHamdy. All rights reserved.
//

import UIKit
var database1:FMDatabase = FMDatabase();
var results1:FMResultSet = FMResultSet();
var documentsDirectory:String = ""
var databaseFilename:String = ""
class SQLHelperAuto: NSObject {
    
    
    override init() {
        super.init()
        // Set the documents directory path to the documentsDirectory property.
        documentsDirectory  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]  as! String

        
            // Keep the database filename.
            databaseFilename = DATABASE_NAME
            
            // Copy the database file into the documents directory if necessary.
            self.copyDatabaseIntoDocumentsDirectory();
            
    }
    
    func copyDatabaseIntoDocumentsDirectory(){
        
        // Check if the database file exists in the documents directory.
        var destinationPath:String = documentsDirectory + "/" + databaseFilename
        var isDir = ObjCBool(false)
        if !NSFileManager.defaultManager().fileExistsAtPath(destinationPath,isDirectory: &isDir) {
            // The database file does not exist in the documents directory, so copy it from the main bundle now.
//            var sourcePath:String = NSBundle.mainBundle().URLForResource(databaseFilename, withExtension: "sqlite")

            var sourcePath:String =  NSBundle.mainBundle().pathForResource(databaseFilename, ofType: "sqlite")!
            print(sourcePath)
            var error: NSError?
            NSFileManager.defaultManager().copyItemAtPath(sourcePath,toPath:destinationPath,error:&error)
            
            // Check if any error occurred during copying and display it.
            if let temoError = error {
                println("gives error: \(temoError.localizedDescription)")

            }
            else
            {
                print("copydone")
                database1 = FMDatabase(path:destinationPath)
                database1.open()
                
            }
            
        }
        else
        {
            print("database exists");
            print(destinationPath)
            database1 = FMDatabase(path:destinationPath)
            database1.open()
            
        }
    }
    
    
     func openDatabaseWithPath(path: String) -> CBool{
        //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        var result:Bool = false;
        //NSString *path1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory ,path];
        if(!database1.open()){
            database1 = FMDatabase(path: path);
            result = database1.open();
        }
        
        database1.executeStatements("PRAGMA journal_mode = WAL")
        database1.executeStatements("PRAGMA synchronous = NORMAL")
        
        
        return result;
    }
    
    class func closeDatabase(){
        database1.close();
        
    }
    
    class func beginTransaction(){
        database1.beginTransaction();
        
    }
    
    class func endTransaction(){
        database1.commit();
        database1.close();
    }
    
    class func insertOrReplaceintoTable(tableName: String, attruibtes: NSArray!, tovalues values: NSArray!) -> CBool{
        var partsArray:NSMutableArray = NSMutableArray()
        
        for (var count=0; count<attruibtes.count; count++) {
            partsArray.addObject("?")
        }
        
        var sqlStmt:String = String(format:"%@ %@ (%@) %@ (%@)", INSERT_OR_UPDATE,tableName,attruibtes.componentsJoinedByString(","),VALUES,partsArray.componentsJoinedByString(","));
        var result:Bool = database1.executeUpdate(sqlStmt, withArgumentsInArray: (values as NSArray ) as [AnyObject])

        if (result == false){
            println("NOOOOOOO");
        }
        
        return result
        
    }
    
    class func updateTable(tableName: String, setAttruibtes attruibtes: NSArray!, toValuses values: NSArray!, whereStatment: String) -> CBool{
        var partsArray:[String] = [String]()
        var part:String = ""
        for (var count = 0; count < attruibtes.count; count++) {
            
            part = (attruibtes[count] as! String)  + " = " + (values[count] as! String )
            partsArray.append(part)
        }
        
        
        var sqlStmt: String = String(format:"%@ %@ %@ %@ %@ %@", UPDATE_TABLE,tableName,SET," , ".join(partsArray),WHERE,whereStatment);
        var result:Bool = database1.executeStatements(sqlStmt)
        if (result == false){
            println("NOOOOOOO");
        }
        
        return result
        
    }
    
    class func deleteFromTable(tableName: String, whereAttruibtes attruibtes: NSArray!, equalValues values: NSArray!) -> CBool{
        var partsArray:[String] = [String]()
        var part:String;
        for (var count=0; count<attruibtes.count; count++) {
            
            part = (attruibtes[count] as! String) + "=?";
            partsArray.append(part)
        }
        
        var whereParameters:String = " AND ".join(partsArray);
        
        var sqlStmt: String = String(format:"%@ %@ %@ %@", DELETE,tableName,WHERE,whereParameters)
        
        var result:Bool = database1.executeUpdate(sqlStmt, withArgumentsInArray: (values as NSArray) as [AnyObject])
        if (result == false){
            println("NOOOOOOO");
        }
        
        return result
        
    }
    
    class func executeReaderselectColums(selectedColums: NSArray!, FromTable tableName: String, whereAttruibtes attruibtes: NSArray!, equalValues values: NSArray!, orderBy orderedAttruibtes: NSArray!) -> NSMutableArray!{
        
        var arrayResult:NSMutableArray = NSMutableArray()
        var partsArray:[String] = [String]()
        var part:String
        var sqlStmt:String
        
        
        if let tmpAttruibtes = attruibtes{
            for (var count=0; count < attruibtes.count; count++) {
                
                part = (attruibtes[count] as! String) + "=" + (values[count] as! String);
                partsArray.append(part)
            }
            var whereParameters:String = " AND ".join(partsArray)
            
            sqlStmt = String(format:"%@ %@ %@ %@ %@ %@", SELECT,selectedColums.componentsJoinedByString(","),FROM,tableName , WHERE , whereParameters)
        }else{
            sqlStmt = String(format:"%@ %@ %@ %@", SELECT,selectedColums.componentsJoinedByString(","),FROM,tableName)
            
        }
        if let tmpOrderedAttruibtes = orderedAttruibtes{
            
            var orderStatment:String = String(format:"%@ %@",ORDER_BY , orderedAttruibtes.componentsJoinedByString(","))
            
            sqlStmt = sqlStmt + orderStatment;
        }
        
        
        var  results1:FMResultSet = database1.executeQuery(sqlStmt,withArgumentsInArray: nil);
        
        while (results1.next()){
            arrayResult.addObject(results1.resultDictionary())
        }
        
        return arrayResult;
        
    }
    
    class func executeStringselectColums(selectedColums: NSArray!, FromTable tableName: String, whereAttruibtes attruibtes: NSArray!, equalValues values: NSArray!) -> String!{
        var arrayResult:NSMutableArray = SQLHelperAuto.executeReaderselectColums(selectedColums, FromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){
            var dic: NSDictionary =  arrayResult[0] as! NSDictionary
            var resultKey:String  = (dic.allKeys as! [String])[0] as String
            return  dic.valueForKey(resultKey) as? String;
        }else{
            return nil
        }
        
        
    }
    
    class func executeNumberselectColums(selectedColums: NSArray!, FromTable tableName: String, whereAttruibtes attruibtes: NSArray!, equalValues values: NSArray!) -> Int!{
        var arrayResult:NSMutableArray = SQLHelperAuto.executeReaderselectColums(selectedColums, FromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){
            var dic: NSDictionary =  arrayResult[0] as! NSDictionary
            var resultKey:String  = (dic.allKeys as! [String])[0] as String
            return  dic.valueForKey(resultKey) as? Int;
        }else{
            return nil
        }
    }
    
    class func executeObjectselectColums(selectedColums: NSArray!, FromTable tableName: String, whereAttruibtes attruibtes: NSArray!, equalValues values: NSArray!) -> AnyObject!{
        var arrayResult:NSMutableArray = SQLHelperAuto.executeReaderselectColums(selectedColums, FromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){
            
            return  arrayResult[0];
        }else{
            return nil
        }
    }
    
    class func executeReaderselectColums(selectedColums: NSArray!, FromTable tableName: String, whereStatement: String!, orderBy orderedAttruibtes: NSArray!) -> NSMutableArray!{
        
        var arrayResult:NSMutableArray = NSMutableArray()
        
        var sqlStmt:String;
        
        if let tmpwhereStatement = whereStatement{
            
            sqlStmt = String(format:"%@ %@ %@ %@ %@ %@" ,SELECT , selectedColums.componentsJoinedByString(",") , FROM , tableName , WHERE , whereStatement);
            
        }else{
            sqlStmt = String(format:"%@ %@ %@ %@" ,SELECT , selectedColums.componentsJoinedByString(",") , FROM , tableName);
        }
        
        
        if let tmpOrderedAttruibtes = orderedAttruibtes{
            
            var orderStatment:String = String(format:"%@ %@",ORDER_BY , orderedAttruibtes.componentsJoinedByString(","))
            
            sqlStmt = sqlStmt + orderStatment;
        }
        
        var  results1:FMResultSet = database1.executeQuery(sqlStmt,withArgumentsInArray: nil);
        
        while (results1.next()) {
            arrayResult.addObject(results1.resultDictionary())
        }
        
        return arrayResult;
        
        
    }
    
    class func selectFunction(functionName: String, fromAttrubite attrubite: String, fromTableName tableName: String) -> AnyObject{
        var result:AnyObject?
        var sqlStmt:String
        
        
        sqlStmt = String(format:"%@ %@(%@) as result %@ %@ " ,SELECT ,functionName ,attrubite ,FROM ,tableName)
        results1 = database1.executeQuery(sqlStmt, withArgumentsInArray: nil);
        while (results1.next()) {
            result = results1.stringForColumn("result");
            
        }
        
        return result!
    }
    
    class func selectFunction(functionName: String, fromAttrubite attrubite: String, fromTableName tableName: String, whereStatment : String!) -> AnyObject{
        var result:AnyObject?
        var sqlStmt:String
        
        
        
        if let tempWhereStatment = whereStatment {
            sqlStmt = String(format:"%@ %@(%@) as result %@ %@ " ,SELECT ,functionName ,attrubite ,FROM ,tableName)
            
        }
        else{
            sqlStmt = String(format:"%@ %@(%@) as result %@ %@ %@ %@  " ,SELECT ,functionName ,attrubite ,FROM ,tableName ,WHERE , whereStatment)
            
        }
        
        results1 = database1.executeQuery(sqlStmt, withArgumentsInArray: nil);
        while (results1.next()) {
            result = results1.stringForColumn("result");
            
        }
        
        return result!
    }
    
    class func selectColums(selectedColums: NSArray, FromTable1 table1Name: String, WithJoinType joinType: String, WithTable2 table2Name: String, onAttruibtesOfTable1 attruibtesTable1: NSArray!, equalToAttruibtesOfTable2 attruibtesTable2: NSArray!, whereAttruibtesOfTable1 attruibtes1: NSArray!, andAttruibtesOfTable2 attruibtes2: NSArray!, equalValues values: NSArray!, orderBy orderedAttruibtes: NSArray!) -> NSMutableArray!{
        
        var whereParts:NSMutableArray = NSMutableArray()
        var wherePart:String
        
        // where statment
        for (var i = 0 ; i < attruibtes1.count; i++) {
            wherePart = table1Name + "." + (attruibtes1.objectAtIndex(i) as! String) + "=?"
            whereParts.addObject(wherePart);
        }
        
        for (var j = 0 ; j<attruibtes2.count; j++) {
            wherePart = table2Name + "." + (attruibtes2.objectAtIndex(j) as! String) + "=?"
            whereParts.addObject(wherePart);
        }
        
        
        var whereParameters:String = whereParts.componentsJoinedByString(" AND ")
        
        
        ////////////
        var arrayResult:NSMutableArray = NSMutableArray()
        var parts:NSMutableArray = NSMutableArray()
        var part:String
        var sqlStmt:String
        
        // On statment
        if  attruibtesTable1.count > 0 && attruibtesTable2.count > 0{
            for (var i = 0 ; i < attruibtesTable1.count; i++){
                part = table1Name + "." + (attruibtesTable1.objectAtIndex(i) as! String ) + "=" + table2Name + "." + (attruibtesTable2.objectAtIndex(i) as! String )
                parts.addObject(part);
            }
            var onParameters:String = parts.componentsJoinedByString(" AND ")
            sqlStmt = String(format:"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@" , SELECT , selectedColums.componentsJoinedByString(",") ,FROM, table1Name , joinType , table2Name ,ON, onParameters , WHERE , whereParameters)
        }
        else{
            sqlStmt = String(format:"%@ %@ %@ %@ %@ %@ %@ %@" ,SELECT , selectedColums.componentsJoinedByString(",") ,FROM , table1Name , joinType , table2Name , WHERE , whereParameters);
        }
        
        if(orderedAttruibtes.count > 0){
            
            var orderStatment:String = ORDER_BY + " " + orderedAttruibtes.componentsJoinedByString(",");
            
            sqlStmt = sqlStmt + orderStatment;
        }
        
        var  results1:FMResultSet = database1.executeQuery(sqlStmt, withArgumentsInArray: nil)
        while (results1.next()) {
            arrayResult.addObject(results1.resultDictionary());
            
        }
        
        return arrayResult;
    }
    
    class func selectColums(selectedColums: NSArray!, FromTable tableName: String, WithJoinType joinType: String, WithTables tables: NSArray!, onStatment: String!, whereStatment: String!, orderBy orderedAttruibtes: NSArray!) -> NSMutableArray!{
        var arrayResult:NSMutableArray = NSMutableArray()
        var sqlStmt:String
        
        sqlStmt = String(format:"%@ %@ %@ %@ %@ %@" ,SELECT , selectedColums.componentsJoinedByString(",") , FROM , tableName , joinType , tables.componentsJoinedByString(","));
        
        
        
        if let tempOnStatment = onStatment{
            sqlStmt =  sqlStmt + ON + onStatment
            
        }
        
        if let tempWhereStatment = whereStatment{
            sqlStmt =  sqlStmt + WHERE + whereStatment
            
        }
        if let tempOrderedAttruibtes = orderedAttruibtes {
            
            sqlStmt = sqlStmt + ORDER_BY + orderedAttruibtes.componentsJoinedByString(",")
        }
        
        var  results1:FMResultSet = database1.executeQuery(sqlStmt, withArgumentsInArray: nil)
        while (results1.next()) {
            arrayResult.addObject(results1.resultDictionary());
            
        }
        
        return arrayResult;
    }
}
