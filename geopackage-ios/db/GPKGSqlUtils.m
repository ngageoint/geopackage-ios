//
//  GPKGSqlUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSqlUtils.h"
#import "GPKGSqlLiteQueryBuilder.h"

@implementation GPKGSqlUtils

+(void) execWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    char * errInfo ;
    int result = sqlite3_exec(database, [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
        [NSException raise:@"SQL Failed" format:@"Failed to execute SQL: %@, Error: %@", statement, err];
    }
}

+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    GPKGResultSet *resultSet = nil;
    
    int count = [self countWithDatabase:database andStatement:statement];
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement andCount:count];
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute query SQL: %@, Error: %s", statement, sqlite3_errmsg(database)];
    }
    
    return resultSet;
}

+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database
                            andDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    NSString * query = [GPKGSqlLiteQueryBuilder buildQueryWithDistinct:distinct
                                                             andTables:table
                                                            andColumns:columns
                                                              andWhere:where
                                                            andGroupBy:groupBy
                                                             andHaving:having
                                                            andOrderBy:orderBy
                                                              andLimit:limit];
    GPKGResultSet *resultSet = [self queryWithDatabase: database andStatement: query];
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
    int prepareStatementResult = sqlite3_prepare_v2(database, [countStatement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        if(sqlite3_step(compiledStatement) == SQLITE_ROW){
            count = sqlite3_column_int(compiledStatement, 0);
        } else{
            [NSException raise:@"SQL Failed" format:@"Failed to get count: %@, Error: %s", countStatement, sqlite3_errmsg(database)];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute count SQL: %@, Error: %s", countStatement, sqlite3_errmsg(database)];
    }
    
    [self closeStatement:compiledStatement];
    
    return count;
}

+(long long) insertWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    long long lastInsertRowId = -1;
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        int executeQueryResults = sqlite3_step(compiledStatement);
        if (executeQueryResults == SQLITE_DONE) {
            lastInsertRowId = sqlite3_last_insert_rowid(database);
        }else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg(database)];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg(database)];
    }
    
    [self closeStatement:compiledStatement];
    
    return lastInsertRowId;
}

+(long long) insertWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (NSDictionary *) values{
    
    NSMutableString *insertStatement = [NSMutableString string];
    [insertStatement appendString:@"insert into "];
    [insertStatement appendString:table];
    [insertStatement appendString:@"("];
    
    BOOL first = true;
    
    for(id key in values){
        if(first){
            first = false;
        }else{
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:key];
    }
    [insertStatement appendString:@") values ("];
    first = true;
    for(id key in values){
        if(first){
            first = false;
        }else{
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:[self getSqlValueString: [values objectForKey:key]]];
    }
    [insertStatement appendString:@")"];
    
    long long id = [self insertWithDatabase:database andStatement:insertStatement];
    
    return id;
}

+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    return [self updateOrDeleteWithDatabase: database andStatement:statement];
}

+(int) updateWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (NSDictionary *) values andWhere: (NSString *) where{
    
    NSMutableString *updateStatement = [NSMutableString string];
    [updateStatement appendString:@"update "];
    [updateStatement appendString:table];
    [updateStatement appendString:@" set "];
    
    BOOL first = true;
    
    for(id key in values){
        if(first){
            first = false;
        }else{
            [updateStatement appendString:@","];
        }
        [updateStatement appendString:key];
        [updateStatement appendString:@"="];
        [updateStatement appendString:[self getSqlValueString: [values objectForKey:key]]];

    }
    
    if(where != nil){
        [updateStatement appendString:@" where "];
        [updateStatement appendString:where];
    }
    
    int count = [self updateWithDatabase:database andStatement:updateStatement];
    
    return count;
}

+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    return [self updateOrDeleteWithDatabase: database andStatement:statement];
}

+(int) deleteWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where{
    
    NSMutableString *deleteStatement = [NSMutableString string];
    
    [deleteStatement appendString:@"delete from "];
    [deleteStatement appendString:table];
    
    if(where != nil){
        [deleteStatement appendString:@" where "];
        [deleteStatement appendString:where];
    }
    
    int count = [self deleteWithDatabase:database andStatement:deleteStatement];
    
    return count;
}

+(int) updateOrDeleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement{
    
    int rowsModified = -1;
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2(database, [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        int executeQueryResults = sqlite3_step(compiledStatement);
        if (executeQueryResults == SQLITE_DONE) {
            rowsModified = sqlite3_changes(database);
        }else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg(database)];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg(database)];
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

+(NSString *) getSqlValueString: (NSObject *) value{
    NSMutableString *sqlString = [NSMutableString string];
    BOOL isString = [value isKindOfClass:[NSString class]];
    if(isString){
        [sqlString appendString:@"'"];
    }
    [sqlString appendFormat: @"%@", value];
    if(isString){
        [sqlString appendString:@"'"];
    }
    return sqlString;
}

@end
