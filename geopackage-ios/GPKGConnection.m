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

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if(self){
        self.databaseFilename = dbFilename;
    }
    
    // Open the database.
    NSString *databasePath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
    sqlite3 *sqlite3Database;
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        // In the database cannot be opened then show the error message on the debugger.
        NSLog(@"%s", sqlite3_errmsg(self.database));
    }else{
        self.database = sqlite3Database;
    }

    return self;
}

-(void)close{
    sqlite3_close(self.database);
}

-(GPKGResultSet *)query:(NSString *) statement{
    
    GPKGResultSet *resultSet = nil;
    
    sqlite3_stmt *compiledStatement;
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement];
    }
    
    return resultSet;
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

@end
