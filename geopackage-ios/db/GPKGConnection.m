//
//  GPKGConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"
#import <sqlite3.h>

@interface GPKGConnection()

@property (nonatomic) sqlite3 *database;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    self = [super init];
    if(self){
        self.filename = filename;
        self.name = [[filename lastPathComponent] stringByDeletingPathExtension];
        
        // Open the database.
        NSString *databasePath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.filename];
        sqlite3 *sqlite3Database;
        BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
        if(openDatabaseResult != SQLITE_OK){
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"%s", sqlite3_errmsg(self.database));
        }else{
            self.database = sqlite3Database;
        }
    }

    return self;
}

-(void)close{
    sqlite3_close(self.database);
}

-(GPKGResultSet *)query:(NSString *) statement{
    
    GPKGResultSet *resultSet = nil;
    
    int count = [self count:statement];
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement andCount:count];
    }
    
    return resultSet;
}

-(int) count:(NSString *) statement{
    
    NSString *countStatement = [statement lowercaseString];
    
    if(![countStatement containsString:@" count(*) "]){
        
        NSRange range = [countStatement rangeOfString:@" from "];
        if(range.length == 0){
            return -1;
        }
        NSInteger index = [countStatement rangeOfString:@" from "].location;
        
        countStatement = [NSString stringWithFormat:@"select count(*)%@", [countStatement substringFromIndex:index]];
    }
    
    int count = 0;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, [countStatement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK && sqlite3_step(compiledStatement) == SQLITE_ROW) {
        count = sqlite3_column_int(compiledStatement, 0);
    }
    
    sqlite3_finalize(compiledStatement);
    
    return count;
}

-(long long) insert:(NSString *) statement{
    
    long long lastInsertRowId = -1;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        lastInsertRowId = sqlite3_last_insert_rowid(self.database);
    }
    
    sqlite3_finalize(compiledStatement);
    
    return lastInsertRowId;
}

-(int) update:(NSString *) statement{
    return [self updateOrDelete:statement];
}

-(int) delete:(NSString *) statement{
    return [self updateOrDelete:statement];
}

-(int) updateOrDelete:(NSString *) statement{
    
    int rowsModified = -1;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        rowsModified = sqlite3_changes(self.database);
    }
    
    sqlite3_finalize(compiledStatement);
    
    return rowsModified;
}

-(void) exec:(NSString *) statement{
    
    char * errInfo ;
    int result = sqlite3_exec(self.database, [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
        [NSException raise:@"SQL Failed" format:@"Failed to execute SQL: %s, Error: %s", statement, err];
    }
    
}

@end
