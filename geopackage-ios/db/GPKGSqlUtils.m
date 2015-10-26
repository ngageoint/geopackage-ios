//
//  GPKGSqlUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSqlUtils.h"
#import "GPKGSqlLiteQueryBuilder.h"
#import "GPKGUtils.h"

@implementation GPKGSqlUtils

+(void) execWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    
    char * errInfo ;
    int result = sqlite3_exec([connection getConnection], [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
        [NSException raise:@"SQL Failed" format:@"Failed to execute SQL: %@, Error: %@", statement, err];
    }
}

+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    GPKGResultSet *resultSet = nil;
    
    int count = [self countWithDatabase:connection andStatement:statement andArgs:args];
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2([connection getConnection], [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        [self setArguments:args inStatement:compiledStatement];
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement andCount:count andConnection:connection];
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute query SQL: %@, Error: %s", statement, sqlite3_errmsg([connection getConnection])];
    }
    
    return resultSet;
}

+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection
                            andDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
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
    GPKGResultSet *resultSet = [self queryWithDatabase: connection andStatement: query andArgs:whereArgs];
    return resultSet;
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    NSString *countStatement = [statement lowercaseString];
    
    if(![countStatement containsString:@" count(*) "]){
        
        NSRange range = [countStatement rangeOfString:@" from "];
        if(range.length == 0){
            return -1;
        }
        NSInteger index = range.location;
        
        countStatement = [NSString stringWithFormat:@"select count(*)%@", [countStatement substringFromIndex:index]];
    }
    
    int count = [self countWithDatabase: connection andCountStatement:countStatement andArgs:args];
    
    return count;
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where{
    return [self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSMutableString *countStatement = [NSMutableString string];
    
    [countStatement appendString:@"select count(*) from "];
    [countStatement appendString:table];
    
    if(where != nil){
        [countStatement appendString:@" "];
        if(![where hasPrefix:@"where"]){
            [countStatement appendString:@"where "];
        }
        [countStatement appendString:where];
    }
    
    int count = [self countWithDatabase: connection andCountStatement:countStatement andArgs:whereArgs];
    
    return count;
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement{
    return [self countWithDatabase:connection andCountStatement:countStatement andArgs:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement andArgs: (NSArray *) args{
    
    int count = 0;
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2([connection getConnection], [countStatement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        [self setArguments:args inStatement:compiledStatement];
        if(sqlite3_step(compiledStatement) == SQLITE_ROW){
            count = sqlite3_column_int(compiledStatement, 0);
        } else{
            [NSException raise:@"SQL Failed" format:@"Failed to get count: %@, Error: %s", countStatement, sqlite3_errmsg([connection getConnection])];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute count SQL: %@, Error: %s", countStatement, sqlite3_errmsg([connection getConnection])];
    }
    
    [self closeStatement:compiledStatement];
    
    return count;
}

+(long long) insertWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    return [self insertWithDatabase:connection andStatement:statement andArgs:nil];
}

+(long long) insertWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values{
    
    NSMutableString *insertStatement = [NSMutableString string];
    [insertStatement appendString:@"insert into "];
    [insertStatement appendString:table];
    [insertStatement appendString:@"("];
    
    int size = (values != nil) ? [values size] : 0;
    NSMutableArray * args = [[NSMutableArray alloc] initWithCapacity:size];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:colName];
        [args addObject:[values getValueForKey:colName]];
        i++;
    }
    [insertStatement appendString:@") values ("];
    for(i = 0; i < size; i++){
        if(i > 0){
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:@"?"];
    }
    [insertStatement appendString:@")"];
    
    long long id = [self insertWithDatabase:connection andStatement:insertStatement andArgs:args];
    
    return id;
}

+(long long) insertWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    long long lastInsertRowId = -1;
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2([connection getConnection], [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        [self setArguments:args inStatement:compiledStatement];
        int executeQueryResults = sqlite3_step(compiledStatement);
        if (executeQueryResults == SQLITE_DONE) {
            lastInsertRowId = sqlite3_last_insert_rowid([connection getConnection]);
        }else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg([connection getConnection])];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg([connection getConnection])];
    }
    
    [self closeStatement:compiledStatement];
    
    return lastInsertRowId;
}

+(int) updateWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    return [self updateWithDatabase:connection andStatement:statement andArgs:nil];
}

+(int) updateWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    return [self updateOrDeleteWithDatabase: connection andStatement:statement andArgs:args];
}

+(int) updateWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where{
    return [self updateWithDatabase:connection andTable:table andValues:values andWhere:where andWhereArgs:nil];
}

+(int) updateWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSMutableString *updateStatement = [NSMutableString string];
    [updateStatement appendString:@"update "];
    [updateStatement appendString:table];
    [updateStatement appendString:@" set "];
    
    int setValuesSize = [values size];
    int argsSize = (whereArgs == nil) ? setValuesSize : (setValuesSize + (int)[whereArgs count]);
    NSMutableArray * args = [[NSMutableArray alloc] initWithCapacity:argsSize];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [updateStatement appendString:@","];
        }
        [updateStatement appendString:colName];
        NSObject * value = [values getValueForKey:colName];
        if(value == nil){
            value = [[NSNull alloc] init];
        }
        [args addObject:value];
        i++;
        [updateStatement appendString:@"=?"];
    }
    if(whereArgs != nil){
        [args addObjectsFromArray:whereArgs];
    }
    if(where != nil){
        [updateStatement appendString:@" where "];
        [updateStatement appendString:where];
    }
    
    int count = [self updateWithDatabase:connection andStatement:updateStatement andArgs:args];
    
    return count;
}

+(int) deleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    return [self deleteWithDatabase:connection andStatement:statement andArgs:nil];
}

+(int) deleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    return [self updateOrDeleteWithDatabase: connection andStatement:statement andArgs:args];
}

+(int) deleteWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where{
    return [self deleteWithDatabase:connection andTable:table andWhere:where andWhereArgs:nil];
}

+(int) deleteWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSMutableString *deleteStatement = [NSMutableString string];
    
    [deleteStatement appendString:@"delete from "];
    [deleteStatement appendString:table];
    
    if(where != nil){
        [deleteStatement appendString:@" where "];
        [deleteStatement appendString:where];
    }
    
    int count = [self deleteWithDatabase:connection andStatement:deleteStatement andArgs:whereArgs];
    
    return count;
}

+(int) updateOrDeleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    int rowsModified = -1;
    
    sqlite3_stmt *compiledStatement;
    int prepareStatementResult = sqlite3_prepare_v2([connection getConnection], [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        [self setArguments:args inStatement:compiledStatement];
        int executeQueryResults = sqlite3_step(compiledStatement);
        if (executeQueryResults == SQLITE_DONE) {
            rowsModified = sqlite3_changes([connection getConnection]);
        }else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg([connection getConnection])];
        }
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg([connection getConnection])];
    }
    
    [self closeStatement:compiledStatement];
    
    return rowsModified;
}

+(void) setArguments: (NSArray *) arguments inStatement: (sqlite3_stmt *) statement{
    if(arguments != nil){
        for(int i = 0; i < [arguments count]; i++){
            NSObject * argument = [arguments objectAtIndex:i];
            int index = i+1;
            if([argument isKindOfClass:[NSData class]]){
                NSData * data = (NSData *) argument;
                int bindResult = sqlite3_bind_blob(statement, index, [data bytes], (int)[data length], SQLITE_TRANSIENT);
                if(bindResult != SQLITE_OK){
                    [NSException raise:@"Bind Blob" format:@"Failed to bind blob in SQL statement: %@, Error Code: %d", statement, bindResult];
                }
            }else if([argument isKindOfClass:[NSDate class]]){
                NSDate * date = (NSDate *) argument;
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                NSString *dateString=[dateFormat stringFromDate:date];
                int bindResult = sqlite3_bind_text(statement, index, [dateString UTF8String], -1, SQLITE_TRANSIENT);
                if(bindResult != SQLITE_OK){
                    [NSException raise:@"Bind Date" format:@"Failed to bind date in SQL statement: %@, Error Code: %d", statement, bindResult];
                }
            }else if([argument isKindOfClass:[NSString class]]){
                NSString * string = (NSString *) argument;
                int bindResult = sqlite3_bind_text(statement, index, [string UTF8String], -1, SQLITE_TRANSIENT);
                if(bindResult != SQLITE_OK){
                    [NSException raise:@"Bind String" format:@"Failed to bind string in SQL statement: %@, Error Code: %d", statement, bindResult];
                }
            }else if([argument isKindOfClass:[NSDecimalNumber class]]){
                NSDecimalNumber * decimal = (NSDecimalNumber *) argument;
                NSString * decimalString = [decimal stringValue];
                int bindResult = sqlite3_bind_text(statement, index, [decimalString UTF8String], -1, SQLITE_TRANSIENT);
                if(bindResult != SQLITE_OK){
                    [NSException raise:@"Bind Decimal" format:@"Failed to bind decimal in SQL statement: %@, Error Code: %d", statement, bindResult];
                }
            }else if([argument isKindOfClass:[NSNumber class]]){
                NSNumber * number = (NSNumber *) argument;
                CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
                
                BOOL success = false;
                
                if (numberType == kCFNumberFloat32Type ||
                    numberType == kCFNumberFloat64Type ||
                    numberType == kCFNumberCGFloatType)
                {
                    double value;
                    success = CFNumberGetValue((CFNumberRef)number, kCFNumberFloat64Type, &value);
                    if (success) {
                        success = (sqlite3_bind_double(statement, index, value) == SQLITE_OK);
                    }
                } else {
                    SInt64 value;
                    success = CFNumberGetValue((CFNumberRef)number, kCFNumberSInt64Type, &value);
                    if (success) {
                        success = (sqlite3_bind_int64(statement, index, value) == SQLITE_OK);
                    }
                }
                
                if(!success){
                    NSString *numberString = [number stringValue];
                    int bindResult = sqlite3_bind_text(statement, index, [numberString UTF8String], -1, SQLITE_TRANSIENT);
                    if(bindResult != SQLITE_OK){
                        [NSException raise:@"Bind Number" format:@"Failed to bind number in SQL statement: %@, Error Code: %d", statement, bindResult];
                    }
                }
            }else if([argument isKindOfClass:[NSNull class]]){
                int bindResult = sqlite3_bind_null(statement, index);
                if(bindResult != SQLITE_OK){
                    [NSException raise:@"Bind Null" format:@"Failed to bind null in SQL statement: %@, Error Code: %d", statement, bindResult];
                }
            } else{
                [NSException raise:@"Unsupported Bind" format:@"Unsupported bind type: %@", NSStringFromClass([argument class])];
            }
        }
    }
}

+(void) closeStatement: (sqlite3_stmt *) statement{
    if(sqlite3_stmt_busy(statement)){
        sqlite3_finalize(statement);
    }
}

+(void) closeResultSet: (GPKGResultSet *) resultSet{
    [resultSet close];
}

+(void) closeDatabase: (GPKGSqliteConnection *) connection{
    sqlite3_close([connection getConnection]);
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
