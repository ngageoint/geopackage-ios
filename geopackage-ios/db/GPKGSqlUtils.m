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
#import "GPKGDateTimeUtils.h"

/**
 * Pattern for matching numbers
 */
NSString *const NUMBER_PATTERN = @"\\d+";

/**
 * Pattern for matching a non word character
 */
NSString *const NON_WORD_CHARACTER_PATTERN = @"\\W";

@implementation GPKGSqlUtils

static NSRegularExpression *numberExpression = nil;
static NSRegularExpression *nonWordCharacterExpression = nil;

+(void) initialize{
    if(numberExpression == nil){
        NSError  *error = nil;
        numberExpression = [NSRegularExpression regularExpressionWithPattern:NUMBER_PATTERN options:0 error:nil];
        if(error){
            [NSException raise:@"Number Regular Expression" format:@"Failed to create number regular expression with error: %@", error];
        }
        error = nil;
        nonWordCharacterExpression = [NSRegularExpression regularExpressionWithPattern:NON_WORD_CHARACTER_PATTERN options:0 error:nil];
        if(error){
            [NSException raise:@"Non Word Character Expression" format:@"Failed to create non word character expression with error: %@", error];
        }
    }
}

+(void) execWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    
    char * errInfo ;
    int result = sqlite3_exec([connection getConnection], [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [[NSString alloc]initWithUTF8String:errInfo];
        [NSException raise:@"SQL Failed" format:@"Failed to execute SQL: %@, Error: %@", statement, err];
    }
}

+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    return [self queryWithDatabase:connection andStatement:statement andArgs:args andKnownCount:nil];
}
    
+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args andKnownCountInt: (int) knownCount{
    return [self queryWithDatabase:connection andStatement:statement andArgs:args andKnownCount:[NSNumber numberWithInt:knownCount]];
}

+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args andKnownCount: (NSNumber *) knownCount{
    
    GPKGResultSet *resultSet = nil;
    
    int count;
    if(knownCount == nil){
        count = [self countWithDatabase:connection andStatement:statement andArgs:args];
    }else{
        count = [knownCount intValue];
    }
    
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
                                                             andTable:table
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
    [countStatement appendString:[self quoteWrapName:table]];
    
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
    return [self querySingleIntegerWithDatabase:connection andSql:countStatement andArgs:args andAllowEmpty:YES];
}

+(int) querySingleIntegerWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andAllowEmpty: (BOOL) allowEmptyResults{
    
    int result = 0;
    
    NSObject *value = [self querySingleResultWithDatabase:connection andSql:sql andArgs:args andColumn:0 andDataType:GPKG_DT_MEDIUMINT];
    if(value != nil){
        result = [((NSNumber *) value) intValue];
    }else if(!allowEmptyResults){
        [NSException raise:@"Singe Integer Query" format:@"Failed to query for single result. SQL: %@", sql];
    }
    
    return result;
}

+(NSObject *) querySingleResultWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType{
    
    GPKGResultSet *result = [self queryWithDatabase:connection andStatement:sql andArgs:args andKnownCountInt:1];
    
    NSObject *value = nil;
    @try {
        if ([result moveToNext]) {
            value = [self valueInResult:result atIndex:column withDataType:dataType];
        }
    } @finally {
        [result closeStatement];
    }
    
    return value;
}

+(NSArray<NSObject *> *) querySingleColumnResultsWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType andLimit: (NSNumber *) limit{
    
    GPKGResultSet *result = [self queryWithDatabase:connection andStatement:sql andArgs:args];
    
    NSMutableArray<NSObject *> *results = [[NSMutableArray alloc] init];
    @try {
        while([result moveToNext]) {
            NSObject *value = [self valueInResult:result atIndex:column withDataType:dataType];
            [results addObject:value];
            if(limit != nil && results.count >= [limit intValue]){
                break;
            }
        }
    } @finally {
        [result closeStatement];
    }
    
    return results;
}

+(NSArray<NSArray<NSObject *> *> *) queryResultsWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit{
    
    GPKGResultSet *result = [self queryWithDatabase:connection andStatement:sql andArgs:args];
    
    NSMutableArray<NSArray<NSObject *> *> *results = [[NSMutableArray alloc] init];
    @try {
        int columns = (int)result.columns.count;
        while([result moveToNext]) {
            NSMutableArray<NSObject *> *row = [[NSMutableArray alloc] init];
            for(int i = 0; i < columns; i++){
                enum GPKGDataType dataType = -1;
                if(dataTypes != nil){
                    dataType = [((NSNumber *)dataTypes[i]) intValue];
                }
                [row addObject:[self valueInResult:result atIndex:i withDataType:dataType]];
            }
            [results addObject:row];
            if(limit != nil && results.count >= [limit intValue]){
                break;
            }
        }
    } @finally {
        [result closeStatement];
    }
    
    return results;
}

+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index{
    return [self valueInResult:result atIndex:index withDataType:-1];
}

+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType{
    
    NSObject *value = nil;
    
    int type = [result getType:index];
    
    switch (type) {
            
        case SQLITE_INTEGER:
            value = [self integerValueInResult:result atIndex:index withDataType:dataType];
            break;
            
        case SQLITE_FLOAT:
            value = [self floatValueInResult:result atIndex:index withDataType:dataType];
            break;
            
        case SQLITE_TEXT:
            {
                NSString *stringValue = [result getString:index];
                
                if (((int)dataType >= 0)
                    && (dataType == GPKG_DT_DATE || dataType == GPKG_DT_DATETIME)) {
                    
                    @try{
                        value = [GPKGDateTimeUtils convertToDateWithString:stringValue];
                    } @catch (NSException *exception) {
                        NSLog(@"Invalid %@ format: %@, String value used, error: %@", [GPKGDataTypes name:dataType], stringValue, exception);
                        value = stringValue;
                    }

                } else {
                    value = stringValue;
                }
            }
            break;
            
        case SQLITE_BLOB:
            value = [result getBlob:index];
            break;
            
        case SQLITE_NULL:
            // leave value as null
            break;
    }
    
    return value;
}

/**
 * Get the integer value from the result set of the column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param dataType
 *            data type
 * @return integer value
 */
+(NSObject *) integerValueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType{
    
    NSObject *value = nil;
    
    if((int)dataType == -1){
        dataType = GPKG_DT_INTEGER;
    }
    
    switch (dataType) {
        case GPKG_DT_BOOLEAN:
            {
                NSNumber *booleanNumberValue = [result getInt:index];
                if(booleanNumberValue != nil){
                    BOOL booleanValue = [GPKGSqlUtils boolValueOfNumber:booleanNumberValue];
                    value = [NSNumber numberWithBool:booleanValue];
                }
            }
            break;
        case GPKG_DT_TINYINT:
        case GPKG_DT_SMALLINT:
        case GPKG_DT_MEDIUMINT:
            value = [result getInt:index];
            break;
        case GPKG_DT_INT:
        case GPKG_DT_INTEGER:
            value = [result getLong:index];
            break;
        default:
            [NSException raise:@"Integer Value" format:@"Data Type %@ is not an integer type", [GPKGDataTypes name:dataType]];
    }
    
    return value;
}

/**
 * Get the float value from the result set of the column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param dataType
 *            data type
 * @return float value
 */
+(NSObject *) floatValueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType{
    
    NSObject *value = nil;
    
    if((int)dataType == -1){
        dataType = GPKG_DT_DOUBLE;
    }
    
    switch (dataType) {
        case GPKG_DT_FLOAT:
        case GPKG_DT_DOUBLE:
        case GPKG_DT_REAL:
        case GPKG_DT_INTEGER:
        case GPKG_DT_INT:
            value = [result getDouble:index];
            break;
        default:
            [NSException raise:@"Float Value" format:@"Data Type %@ is not a float type", [GPKGDataTypes name:dataType]];
    }
    
    return value;
}
 
+(NSNumber *) minWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSNumber * min = nil;
    if([self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs] > 0){
        NSMutableString *minStatement = [NSMutableString string];
        
        [minStatement appendFormat:@"select min(%@) from %@", [self quoteWrapName:column], [self quoteWrapName:table]];
        
        if(where != nil){
            [minStatement appendString:@" "];
            if(![where hasPrefix:@"where"]){
                [minStatement appendString:@"where "];
            }
            [minStatement appendString:where];
        }
        
        min = [NSNumber numberWithInt:[self querySingleIntegerWithDatabase:connection andSql:minStatement andArgs:whereArgs andAllowEmpty:NO]];
    }
    
    return min;
}

+(NSNumber *) maxWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSNumber * max = nil;
    if([self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs] > 0){
        NSMutableString *maxStatement = [NSMutableString string];
        
        [maxStatement appendFormat:@"select max(%@) from %@", [self quoteWrapName:column], [self quoteWrapName:table]];
        
        if(where != nil){
            [maxStatement appendString:@" "];
            if(![where hasPrefix:@"where"]){
                [maxStatement appendString:@"where "];
            }
            [maxStatement appendString:where];
        }
        
        max = [NSNumber numberWithInt:[self querySingleIntegerWithDatabase:connection andSql:maxStatement andArgs:whereArgs andAllowEmpty:NO]];
    }
    
    return max;
}

+(long long) insertWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    return [self insertWithDatabase:connection andStatement:statement andArgs:nil];
}

+(long long) insertWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values{
    
    NSMutableString *insertStatement = [NSMutableString string];
    [insertStatement appendString:@"insert into "];
    [insertStatement appendString:[self quoteWrapName:table]];
    [insertStatement appendString:@"("];
    
    int size = (values != nil) ? [values size] : 0;
    NSMutableArray * args = [[NSMutableArray alloc] initWithCapacity:size];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:[self quoteWrapName:colName]];
        NSObject * value = [values getValueForKey:colName];
        if(value == nil){
            value = [NSNull null];
        }
        [args addObject:value];
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
    [updateStatement appendString:[self quoteWrapName:table]];
    [updateStatement appendString:@" set "];
    
    int setValuesSize = [values size];
    int argsSize = (whereArgs == nil) ? setValuesSize : (setValuesSize + (int)[whereArgs count]);
    NSMutableArray * args = [[NSMutableArray alloc] initWithCapacity:argsSize];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [updateStatement appendString:@","];
        }
        [updateStatement appendString:[self quoteWrapName:colName]];
        NSObject * value = [values getValueForKey:colName];
        if(value == nil){
            value = [NSNull null];
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
    [deleteStatement appendString:[self quoteWrapName:table]];
    
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
                NSString *dateString = [GPKGDateTimeUtils convertToDateTimeStringWithDate:date];
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
    if (statement != NULL){
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

+(NSString *) quoteWrapName: (NSString *) name{
    NSString * quoteName = nil;
    if(name != nil){
        if([name hasPrefix:@"\""] && [name hasSuffix:@"\""]){
            quoteName = name;
        }else{
            quoteName = [NSString stringWithFormat:@"\"%@\"", name];
        }
    }
    return quoteName;
}

+(NSArray *) quoteWrapNames: (NSArray *) names{
    NSMutableArray * quoteNames = nil;
    if(names != nil){
        quoteNames = [[NSMutableArray alloc] init];
        for(NSString * name in names){
            [quoteNames addObject:[self quoteWrapName:name]];
        }
    }
    return quoteNames;
}

+(NSString *) quoteUnwrapName: (NSString *) name{
    NSString *unquotedName = nil;
    if(name != nil){
        if([name hasPrefix:@"\""] && [name hasSuffix:@"\""]){
            unquotedName = [name substringWithRange:NSMakeRange(1, [name length] - 1)];
        }else{
            unquotedName = name;
        }
    }
    return unquotedName;
}

+(NSString *) createTableSQL: (GPKGUserTable *) table{
    
    // Build the create table sql
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"CREATE TABLE %@ (", [self quoteWrapName:table.tableName]];
    
    // Add each column to the sql
    NSArray *columns = [table columns];
    for(int i = 0; i < [columns count]; i++){
        GPKGUserColumn *column = [columns objectAtIndex:i];
        if(i > 0){
            [sql appendString:@","];
        }
        [sql appendFormat:@"\n  "];
        [sql appendString:[self columnSQL:column]];
    }
    
    // Add constraints
    NSArray *constraints = [table constraints];
    for(int i = 0; i < [constraints count]; i++){
        [sql appendFormat:@",\n  "];
        GPKGConstraint *constraint = [constraints objectAtIndex:i];
        [sql appendString:[constraint buildSql]];
    }
    
    [sql appendString:@"\n);"];
    
    return sql;
}

+(NSString *) columnSQL: (GPKGUserColumn *) column{
    return [NSString stringWithFormat:@"%@ %@", [self quoteWrapName:column.name], [self columnDefinition:column]];
}

+(NSString *) columnDefinition: (GPKGUserColumn *) column{
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    [sql appendString:column.type];
    
    if([column hasMax]){
        [sql appendFormat:@"(%d)", [column.max intValue]];
    }
    
    for(GPKGConstraint *constraint in column.constraints){
        [sql appendFormat:@" %@", [constraint buildSql]];
    }
    
    return sql;
}

+(NSString *) columnDefaultValue: (GPKGUserColumn *) column{
    return [self columnDefaultValue:column.defaultValue withType:column.dataType];
}

+(NSString *) columnDefaultValue: (NSObject *) defaultValue withType: (enum GPKGDataType) dataType{

    NSString *value = nil;
    
    if (defaultValue != nil) {
        
        if ((int)dataType != -1) {
            
            switch (dataType) {
                case GPKG_DT_BOOLEAN:
                    if ([defaultValue isKindOfClass:[NSNumber class]]) {
                        NSNumber *booleanNumber = (NSNumber *) defaultValue;
                        if([self boolValueOfNumber:booleanNumber]){
                            value = @"1";
                        }else{
                            value = @"0";
                        }
                    } else if ([defaultValue isKindOfClass:[NSString class]]) {
                        NSString *stringBooleanValue = (NSString *) defaultValue;
                        if([stringBooleanValue isEqualToString:@"1"] || [stringBooleanValue caseInsensitiveCompare:@"true"] == NSOrderedSame){
                            value = @"1";
                        }else{
                            value = @"0";
                        }
                    }
                    break;
                case GPKG_DT_TEXT:
                    value = [NSString stringWithFormat:@"%@", defaultValue];
                    if(![value hasPrefix:@"'"] || ![value hasSuffix:@"'"]){
                        value = [NSString stringWithFormat:@"'%@'", value];
                    }
                    break;
                default:
            }
            
        }
        
        if (value == nil) {
            value = [NSString stringWithFormat:@"%@", defaultValue];
        }
    }
    
    return value;
}

+(void) addColumn: (GPKGUserColumn *) column toTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    [GPKGAlterTable addColumn:column.name withDefinition:[self columnDefinition:column] toTable:tableName withConnection:db];
}

+(BOOL) foreignKeysWithConnection: (GPKGConnection *) db{
    NSNumber *foreignKeys = [db querySingleResultWithSql:@"PRAGMA foreign_keys" andArgs:nil andDataType:GPKG_DT_BOOLEAN];
    return [self boolValueOfNumber:foreignKeys];
}

+(BOOL) foreignKeysAsOn: (BOOL) on withConnection: (GPKGConnection *) db{
    
    BOOL foreignKeys = [self foreignKeysWithConnection:db];
    
    if(foreignKeys != on){
        NSString *sql = [self foreignKeysSQLAsOn:on];
        [db exec:sql];
    }
    
    return foreignKeys;
}

+(NSString *) foreignKeysSQLAsOn: (BOOL) on{
    return [NSString stringWithFormat:"PRAGMA foreign_keys = %@", (on ? @"true" : @"false")];
}

+(NSArray<NSArray<NSObject *> *> *) foreignKeyCheckWithConnection: (GPKGConnection *) db{
    NSString *sql = [self foreignKeyCheckSQL];
    return [db queryResultsWithSql:sql andArgs:nil];
}

+(NSArray<NSArray<NSObject *> *> *) foreignKeyCheckOnTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self foreignKeyCheckSQLOnTable:tableName];
    return [db queryResultsWithSql:sql andArgs:nil];
}

+(NSString *) foreignKeyCheckSQL{
    return [self foreignKeyCheckSQLOnTable:nil];
}

+(NSString *) foreignKeyCheckSQLOnTable: (NSString *) tableName{
    return [NSString stringWithFormat:@"PRAGMA foreign_key_check%@", (tableName != nil ? [NSString stringWithFormat:@"(%@)", [self quoteWrapName:tableName]] : @"")];
}

+(NSString *) integrityCheckSQL{
    return @"PRAGMA integrity_check";
}

+(NSString *) quickCheckSQL{
    return @"PRAGMA quick_check";
}

+(void) dropTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self dropTableSQL:tableName];
    [db exec:sql];
}

+(NSString *) dropTableSQL: (NSString *) tableName{
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [self quoteWrapName:tableName]];
}

+(void) dropView: (NSString *) viewName withConnection: (GPKGConnection *) db{
    NSString *sql = [self dropViewSQL:viewName];
    [db exec:sql];
}

+(NSString *) dropViewSQL: (NSString *) viewName{
    return [NSString stringWithFormat:@"DROP VIEW IF EXISTS %@", [self quoteWrapName:viewName]];
}

+(void) transferTableContent: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{
    NSString *sql = [self transferTableContentSQL:tableMapping];
    [db exec:sql];
}

+(NSString *) transferTableContentSQL: (GPKGTableMapping *) tableMapping{
    
    NSMutableString *insert = [[NSMutableString alloc] initWithString:@"INSERT INTO "];
    [insert appendString:[self quoteWrapName:tableMapping.toTable]];
    [insert appendString:@" ("];
    
    NSMutableString *selectColumns = [[NSMutableString alloc] init];
    
    NSMutableString *where = [[NSMutableString alloc] init];
    if([tableMapping hasWhere]){
        [where appendString:tableMapping.where];
    }
    
    for(NSString *toColumn in [tableMapping columns]){
        
        GPKGMappedColumn *column = [tableMapping column:toColumn];
        
        if(selectColumns.length > 0){
            [insert appendString:@", "];
            [selectColumns appendString:@", "];
        }
        [insert appendString:[self quoteWrapName:toColumn]];
        
        if([column hasConstantValue]){
            
            [selectColumns appendString:[column constantValueAsString]];
            
        }else{
            
            if([column hasDefaultValue]){
                [selectColumns appendString:@"ifnull("];
            }
            [selectColumns appendString:[self quoteWrapName:[column fromColumn]]];
            if([column hasDefaultValue]){
                [selectColumns appendString:@","];
                [selectColumns appendString:[column defaultValueAsString]];
                [selectColumns appendString:@")"];
            }
            
        }
        
        if([column hasWhereValue]){
            if(where.length > 0){
                [where appendString:@" AND "];
            }
            [where [self quoteWrapName:[column fromColumn]]];
            [where appendString:@" "];
            [where appendString:[column whereOperator]];
            [where appendString:@" "];
            [where appendString:[column whereValueAsString]]
        }
        
    }
    [insert appendString:@") SELECT "];
    [insert appendString:selectColumns];
    [insert appendString:@" FROM "];
    [insert appendString:[self quoteWrapName:tableMapping.fromTable]];

    if(where.length > 0){
        [insert appendString:@" WHERE "];
        [insert appendString:where];
    }
    
    return insert;
}

+(void) transferContentInTable: (NSString *) tableName inColumn: (NSString *) columnName withNewValue: (NSObject *) newColumnValue andCurrentValue: (NSObject *) currentColumnValue withConnection: (GPKGConnection *) db{
    [self transferContentInTable:tableName inColumn:columnName withNewValue:newColumnValue andCurrentValue:currentColumnValue andIdColumn:nil withConnection:db];
}

+(void) transferContentInTable: (NSString *) tableName inColumn: (NSString *) columnName withNewValue: (NSObject *) newColumnValue andCurrentValue: (NSObject *) currentColumnValue andIdColumn: (NSString *) idColumnName withConnection: (GPKGConnection *) db{
    
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithConnection:db andTable:tableName];
    if(idColumnName != nil){
        [tableMapping removeColumn:idColumnName];
    }
    GPKGMappedColumn *tileMatrixSetNameColumn = [tableMapping column:columnName];
    [tileMatrixSetNameColumn setConstantValue:newColumnValue];
    [tileMatrixSetNameColumn setWhereValue:currentColumnValue];
    
    [self transferTableContent:tableMapping withConnection:db];
}

+(NSString *) tempTableNameWithPrefix: (NSString *) prefix andBaseName: (NSString *) baseName withConnection: (GPKGConnection *) db{
    NSString *name = [NSString stringWithFormat:@"%@_%@", prefix, baseName];
    int nameNumber = 0;
    while([db tableExists:name]){
        name = [NSString stringWithFormat:@"%@%@_%@", prefix, ++nameNumber, baseName];
    }
    return name;
}

+(NSString *) modifySQL: (NSString *) sql withName: (NSString *) name andTableMapping: (GPKGTableMapping *) tableMapping{
    return [self modifySQL:sql withName:name andTableMapping:tableMapping withConnection:nil];
}

+(NSString *) modifySQL: (NSString *) sql withName: (NSString *) name andTableMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{

    NSString *updatedSql = sql;
    
    if(name != nil && [tableMapping isNewTable]){
        
        NSString *newName = [self createName:name andReplace:tableMapping.fromTable withReplacement:tableMapping.toTable withConnection:db];
        
        NSString *updatedName = [self replaceName:name inSQL:updatedSql withReplacement:newName];
        if(updatedName != nil){
            updatedSql = updatedName;
        }
        
        NSString *updatedTable = [self replaceName:tableMapping.fromTable inSQL:updatedSql withReplacement:tableMapping.toTable];
        if(updatedTable != nil){
            updatedSql = updatedTable;
        }
        
    }
    
    updatedSql = [self modifySQL:updatedSql withTableMapping:tableMapping];
    
    return updatedSql;
}

+(NSString *) modifySQL: (NSString *) sql withTableMapping: (GPKGTableMapping *) tableMapping{

    NSString *updatedSql = sql;
    
    for(NSString *column in [tableMapping droppedColumns]){
        
        NSString *updated = [self replaceName:column inSQL:updatedSql withReplacement:@" "];
        if(updated != nil){
            updatedSql = nil;
            break;
        }
        
    }
    
    if(updatedSql != nil){
        
        for(GPKGMappedColumn *column in [tableMapping mappedColumns]){
            if([column hasNewName]){
                
                NSString *updated = [self replaceName:[column fromColumn] inSQL:updatedSql withReplacement:[column toColumn]];
                if(updated != nil){
                    updatedSql = updated;
                }
                
            }
        }
        
    }
    
    return updatedSql;
}

+(NSString *) replaceName: (NSString *) name inSQL: (NSString *) sql withReplacement: (NSString *) replacement{

    NSString *updatedSql = nil;
    
    // Quick check if contained in the SQL
    if([sql containsString:name]){
        
        BOOL updated = NO;
        NSMutableString *updatedSqlBuilder = [[NSMutableString alloc] init];
        
        // Split the SQL apart by the name
        NSArray<NSString *> *parts = [sql componentsSeparatedByString:name];
        
        for (int i = 0; i <= parts.count; i++) {
            
            if (i > 0) {
                
                // Find the character before the name
                NSString *before = @"_";
                NSString *beforePart = [parts objectAtIndex:i - 1];
                if(beforePart.length == 0){
                    if (i == 1) {
                        // SQL starts with the name, allow
                        before = @" ";
                    }
                } else {
                    before = [beforePart substringFromIndex:beforePart.length - 1];
                }
                
                // Find the character after the name
                NSString *after = @"_";
                if (i < parts.count) {
                    NSString *afterPart = [parts objectAtIndex:i];
                    if(afterPart.length > 0){
                        after = [afterPart substringWithRange:NSMakeRange(0, 1)];
                    }
                } else if ([sql hasSuffix:name]) {
                    // SQL ends with the name, allow
                    after = @" ";
                } else {
                    break;
                }
                
                // Check the before and after characters for non word
                // characters
                if([nonWordCharacterExpression numberOfMatchesInString:before options:0 range:NSMakeRange(0, before.length)] == 1 && [nonWordCharacterExpression numberOfMatchesInString:after options:0 range:NSMakeRange(0, after.length)] == 1){
                    // Replace the name
                    [updatedSqlBuilder appendString:replacement];
                    updated = YES;
                }else {
                    // Preserve the name
                    [updatedSqlBuilder appendString:name];
                }
            }
            
            // Add the part to the SQL
            if(i < parts.count){
                [updatedSqlBuilder appendString:[parts objectAtIndex:i]];
            }
            
        }
        
        // Set if the SQL was modified
        if (updated) {
            updatedSql = updatedSqlBuilder;
        }
        
    }
    
    return updatedSql;
}

+(NSString *) createName: (NSString *) name andReplace: (NSString *) replace withReplacement: (NSString *) replacement{
    return [self createName:name andReplace:replace withReplacement:replacement withConnection:nil];
}

+(NSString *) createName: (NSString *) name andReplace: (NSString *) replace withReplacement: (NSString *) replacement withConnection: (GPKGConnection *) db{

    // Attempt the replacement
    NSString *newName = [name stringByReplacingOccurrencesOfString:replace withString:replacement options:NSCaseInsensitiveSearch range:NSMakeRange(0, name.length);
    
    // If no name change was made
    if([newName isEqualToString:name]){
        
        NSString *baseName = newName;
        int count = 1;
        
        // Find any existing end number: name_#
        int index = [baseName rangeOfString:@"_" options:NSBackwardsSearch].location;
        if (index != NSNotFound && index + 1 < baseName.length) {
            NSString *numberPart = [baseName substringFromIndex:index + 1];
            if([numberExpression numberOfMatchesInString:numberPart options:0 range:NSMakeRange(0, numberPart.length)] == 1){
                baseName = [baseName substringWithRange:NSMakeRange(0, index)];
                count = [baseName intValue];
            }
        }
        
        // Set the new name to name_2 or name_(#+1)
        newName = [NSString stringWithFormat:@"%@_%d", baseName, ++count];
        
        if (db != nil) {
            // Check for conflicting SQLite Master table names
            while([GPKGSQLiteMaster countWithConnection:db andQuery:[GPKGSQLiteMasterQuery createWithColumn:GPKG_SQLITE_MASTER_NAME andValue:newName]] > 0){
                newName = [NSString stringWithFormat:@"%@_%d", baseName, ++count];
            }
        }
        
    }
    
    return newName;
}

+(void) vacuumWithConnection: (GPKGConnection *) db{
    [db exec:@"VACUUM"];
}

+(BOOL) boolValueOfNumber: (NSNumber *) number{
    return number != nil && [number intValue] == 1;
}

@end
