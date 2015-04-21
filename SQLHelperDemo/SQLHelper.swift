//
//  SQLHelper.swift
//  SQLHelperDemo
//
//  Created by binaryboy on 3/29/15.
//  Copyright (c) 2015 AhmedHamdy. All rights reserved.
//

import UIKit
var database1:FMDatabase = FMDatabase();
var results1:FMResultSet = FMResultSet();
class SQLHelper: NSObject {

    
    
    
//    //path from document dirctory
    class func openDatabaseWithPath(path: NSString)->Bool{
        
        //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        var result:Bool = false;
//        NSString *path1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory ,path];
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
    

    
    class func insertOrReplaceintoTable(tableName: NSString,attruibtes: NSMutableArray,values: NSMutableArray)->Bool{
        
        var partsArray:NSMutableArray = NSMutableArray()
        
        for (var count=0; count<attruibtes.count; count++) {
            partsArray.addObject("?")
        }
        //partsArray.componentsJoinedByString(",")
        
        var sqlStmt:NSString = String(format:"%@ %@ %@ %@ (%@)", INSERT_OR_UPDATE,tableName,attruibtes,VALUES,partsArray.componentsJoinedByString(""));
        var result:Bool = database1.executeUpdate(sqlStmt, withArgumentsInArray: values)
        if (result == false){
            println("NOOOOOOO");
        }
        
        return result

    }

    
    

    
    class func updateTable(tableName: NSString,attruibtes: NSMutableArray,values: NSMutableArray,whereStatment: NSString)->Bool{
       
        var partsArray:NSMutableArray = NSMutableArray()
        var part:String;
        for (var count=0; count<attruibtes.count; count++) {

            part = (values.objectAtIndex(count) as String ) + "=" + (attruibtes.objectAtIndex(count) as String);
            partsArray.addObject(part)
        }
        
        
     var sqlStmt:NSString = String(format:"%@ %@ %@ %@ %@ %@", UPDATE_TABLE,tableName,SET,partsArray.componentsJoinedByString(""),WHERE,whereStatment);
        var result:Bool = database1.executeStatements(sqlStmt)
        if (result == false){
            println("NOOOOOOO");
        }
        
        return result
    }
    
  

    
    class func deleteFromTable(tableName: String,attruibtes: NSMutableArray,equalValues:NSMutableArray)->Bool{
        var partsArray:NSMutableArray = NSMutableArray()
        var part:String;
        for (var count=0; count<attruibtes.count; count++) {
            
            part = (attruibtes.objectAtIndex(count) as String) + "=?";
            partsArray.addObject(part)
        }
        
        var whereParameters:String = partsArray.componentsJoinedByString(" AND ");

        var sqlStmt:NSString = String(format:"%@ %@ %@ %@", DELETE,tableName,WHERE,whereParameters)
        
        var result:Bool = database1.executeUpdate(sqlStmt, withArgumentsInArray: equalValues)
        if (result == false){
            println("NOOOOOOO");
        }
        
        return result

    }


    class func executeReaderselectColums(selectedColums: NSMutableArray,fromTable tableName:String ,whereAttruibtes attruibtes:NSMutableArray!,equalValues values:NSMutableArray,orderBy orderedAttruibtes:NSMutableArray!)->NSMutableArray{
        
        var arrayResult:NSMutableArray = NSMutableArray()
        var partsArray:NSMutableArray = NSMutableArray()
        var part:String
        var sqlStmt:String

     
        if let tmpAttruibtes = attruibtes{
            for (var count=0; count < attruibtes.count; count++) {
                
                part = (attruibtes.objectAtIndex(count) as String) + "=" + (values.objectAtIndex(count) as String);
                partsArray.addObject(part)
            }
        var whereParameters:String = partsArray.componentsJoinedByString(" AND ")

         sqlStmt = String(format:"%@ %@ %@ %@ %@ %@", SELECT,selectedColums.componentsJoinedByString(","),FROM,tableName , WHERE , whereParameters)
        }else{
             sqlStmt = String(format:"%@ %@ %@ %@ %@ %@", SELECT,selectedColums.componentsJoinedByString(","),FROM,tableName)

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


     func executeReaderselectColums(selectedColums: NSMutableArray,fromTable tableName:String ,whereStatement :String!,orderBy orderedAttruibtes:NSMutableArray!)->NSMutableArray{
        
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

    class func executeStringselectColums(selectedColums: NSMutableArray,FromTable tableName: String,whereAttruibtes attruibtes :NSMutableArray,equalValues values: NSMutableArray)->String?{
        
        var arrayResult:NSMutableArray = SQLHelper.executeReaderselectColums(selectedColums, fromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){
            var dic: NSDictionary =  arrayResult[0] as NSDictionary
         var resultKey:String  = (dic.allKeys as [String])[0] as String
            return  dic.valueForKey(resultKey) as? String;
        }else{
        return nil
        }
    }

    
    class func executeStringselectColums(selectedColums: NSMutableArray,FromTable tableName: String,whereAttruibtes attruibtes :NSMutableArray,equalValues values: NSMutableArray)->NSNumber? {
        
        var arrayResult:NSMutableArray = SQLHelper.executeReaderselectColums(selectedColums, fromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){
            var dic: NSDictionary =  arrayResult[0] as NSDictionary
            var resultKey:String  = (dic.allKeys as [String])[0] as String
            return  dic.valueForKey(resultKey) as? NSNumber;
        }else{
            return nil
        }
    }

    
    class func executeStringselectColums(selectedColums: NSMutableArray,FromTable tableName: String,whereAttruibtes attruibtes :NSMutableArray,equalValues values: NSMutableArray)->AnyObject? {
        
        var arrayResult:NSMutableArray = SQLHelper.executeReaderselectColums(selectedColums, fromTable: tableName, whereAttruibtes: attruibtes, equalValues: values, orderBy: nil);
        if(arrayResult.count > 0){

            return  arrayResult[0];
        }else{
            return nil
        }
    }
    

    
    class func selectFunction(functionName: String,fromAttrubite attrubite:String,fromTableName tableName:String)->AnyObject{
        var result:AnyObject?
        var sqlStmt:String
        
        
        sqlStmt = String(format:"%@ %@(%@) as result %@ %@ " ,SELECT ,functionName ,attrubite ,FROM ,tableName)
        results1 = database1.executeQuery(sqlStmt, withArgumentsInArray: nil);
        while (results1.next()) {
            result = results1.stringForColumn("result");
            
        }

        return result!
    }

    
    class func selectFunction(functionName: String,fromAttrubite attrubite:String,fromTableName tableName:String,whereStatment:String!)->AnyObject{
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

    
    class func selectColums(selectedColums: NSMutableArray,FromTable1 table1Name: String,WithJoinType joinType: String,WithTable2 table2Name: String,onAttruibtesOfTable1 attruibtesTable1: NSMutableArray,equalToAttruibtesOfTable2 attruibtesTable2 :NSMutableArray, whereAttruibtesOfTable1 attruibtes1: NSMutableArray,andAttruibtesOfTable2 attruibtes2 :NSMutableArray ,equalValues values: NSMutableArray,orderBy orderedAttruibtes: NSMutableArray)->NSMutableArray{
        
        var whereParts:NSMutableArray = NSMutableArray()
        var wherePart:String

        // where statment
        for (var i = 0 ; i < attruibtes1.count; i++) {
            wherePart = table1Name + "." + (attruibtes1.objectAtIndex(i) as String) + "=?"
            whereParts.addObject(wherePart);
        }
        
        for (var j = 0 ; j<attruibtes2.count; j++) {
            wherePart = table2Name + "." + (attruibtes2.objectAtIndex(j) as String) + "=?"
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
                part = table1Name + "." + (attruibtesTable1.objectAtIndex(i) as String ) + "=" + table2Name + "." + (attruibtesTable2.objectAtIndex(i) as String )
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
    
    
    class func selectColums(selectedColums: NSMutableArray,FromTable tableName:String,WithJoinType joinType:String,WithTables tables: NSMutableArray,onStatment: String!,whereStatment: String!,orderBy orderedAttruibtes: NSMutableArray!)->NSMutableArray{
        
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
