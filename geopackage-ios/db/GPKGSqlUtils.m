//
//  GPKGSqlUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSqlUtils.h"

@implementation GPKGSqlUtils

+(void) execWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    char * errInfo ;
    int result = sqlite3_exec(database, [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
        [NSException raise:@"SQL Failed" format:@"Failed to execute SQL: %s, Error: %s", statement, err];
    }
}

+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    GPKGResultSet *resultSet = nil;
    
    int count = [self countWithDatabase:database andStatement:statement];
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement andCount:count];
    }
    
    return resultSet;
}

+(int) countWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    NSString *countStatement = [statement lowercaseString];
    
    if(![countStatement containsString:@" count(*) "]){
        
        NSRange range = [countStatement rangeOfString:@" from "];
        if(range.length == 0){
            return -1;
        }
        NSInteger index = [countStatement rangeOfString:@" from "].location;
        
        countStatement = [NSString stringWithFormat:@"select count(*)%@", [countStatement substringFromIndex:index]];
    }
    
    int count = [self countWithDatabase: database andCountStatement:countStatement];
    
    return count;
}

+(int) countWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where{
    
    NSMutableString *countStatement = [NSMutableString string];
    
    [countStatement appendString:@"select count(*) from "];
    [countStatement appendString:table];
    
    if(where != nil){
        [countStatement appendString:@" where "];
        [countStatement appendString:where];
    }
    
    int count = [self countWithDatabase: database andCountStatement:countStatement];
    
    return count;
}

+(int) countWithDatabase: (sqlite3 *) database andCountStatement: (NSString *) countStatement{
    
    int count = 0;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(database, [countStatement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK && sqlite3_step(compiledStatement) == SQLITE_ROW) {
        count = sqlite3_column_int(compiledStatement, 0);
    }
    
    [self closeStatement:compiledStatement];
    
    return count;
}

+(long long) insertWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    long long lastInsertRowId = -1;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        lastInsertRowId = sqlite3_last_insert_rowid(database);
    }
    
    [self closeStatement:compiledStatement];
    
    return lastInsertRowId;
}

+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    return [self updateOrDeleteWithDatabase: database andStatement:statement];
}

+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    return [self updateOrDeleteWithDatabase: database andStatement:statement];
}

+(int) updateOrDeleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    int rowsModified = -1;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        rowsModified = sqlite3_changes(database);
    }
    
    [self closeStatement:compiledStatement];
    
    return rowsModified;
}

+(void) closeStatement: (sqlite3_stmt *) statment{
    sqlite3_finalize(statment);
}

+(void) closeResultSet: (GPKGResultSet *) resultSet{
    [resultSet close];
}

+(void) closeDatabase: (sqlite3 *) database{
    sqlite3_close(database);
}

@end
