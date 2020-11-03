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
#import "GPKGSQLiteMaster.h"
#import "GPKGAlterTable.h"

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
        numberExpression = [NSRegularExpression regularExpressionWithPattern:NUMBER_PATTERN options:0 error:&error];
        if(error){
            [NSException raise:@"Number Regular Expression" format:@"Failed to create number regular expression with error: %@", error];
        }
        error = nil;
        nonWordCharacterExpression = [NSRegularExpression regularExpressionWithPattern:NON_WORD_CHARACTER_PATTERN options:0 error:&error];
        if(error){
            [NSException raise:@"Non Word Character Expression" format:@"Failed to create non word character expression with error: %@", error];
        }
    }
}

+(void) execWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement{
    [self execWithSQLite3Connection:[connection connection] andStatement:statement];
}

+(void) execWithSQLiteConnection: (GPKGSqliteConnection *) connection andStatement: (NSString *) statement{
    [self execWithSQLite3Connection:[connection connection] andStatement:statement];
}

+(void) execWithSQLite3Connection: (sqlite3 *) connection andStatement: (NSString *) statement{
    char * errInfo ;
    int result = sqlite3_exec(connection, [statement UTF8String], nil, nil, &errInfo);
    
    if (SQLITE_OK != result) {
        NSString* err = [NSString stringWithUTF8String:errInfo];
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
    int prepareStatementResult = sqlite3_prepare_v2([connection connection], [statement UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        [self setArguments:args inStatement:compiledStatement];
        resultSet = [[GPKGResultSet alloc] initWithStatement: compiledStatement andCount:count andConnection:connection];
    } else{
        [NSException raise:@"SQL Failed" format:@"Failed to execute query SQL: %@, Error: %s", statement, sqlite3_errmsg([connection connection])];
    }
    
    return resultSet;
}

+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection
                        andDistinct: (BOOL) distinct
                        andTable: (NSString *) table
                        andColumns: (NSArray<NSString *> *) columns
                        andWhere: (NSString *) where
                        andWhereArgs: (NSArray *) whereArgs
                        andGroupBy: (NSString *) groupBy
                        andHaving: (NSString *) having
                        andOrderBy: (NSString *) orderBy
                        andLimit: (NSString *) limit{
    NSString * query = [self querySQLWithDistinct:distinct
                                     andTable:table
                                    andColumns:columns
                                      andWhere:where
                                      andGroupBy:groupBy
                                    andHaving:having
                                      andOrderBy:orderBy
                                    andLimit:limit];
    GPKGResultSet *resultSet = [self queryWithDatabase:connection andStatement:query andArgs:whereArgs];
    return resultSet;
}

+(NSString *) querySQLWithDistinct: (BOOL) distinct
                        andTable: (NSString *) table
                        andColumns: (NSArray<NSString *> *) columns
                        andWhere: (NSString *) where
                        andGroupBy: (NSString *) groupBy
                        andHaving: (NSString *) having
                        andOrderBy: (NSString *) orderBy
                        andLimit: (NSString *) limit{
    return [GPKGSqlLiteQueryBuilder buildQueryWithDistinct:distinct
                                     andTable:table
                                    andColumns:columns
                                      andWhere:where
                                    andGroupBy:groupBy
                                     andHaving:having
                                    andOrderBy:orderBy
                                      andLimit:limit];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    int count = 0;
    
    NSMutableArray<NSString *> *sqlCommands = [NSMutableArray array];
    
    NSString *upperCaseSQL = [statement uppercaseString];
    NSRange selectRange = [upperCaseSQL rangeOfString:@"SELECT"];
    
    if(selectRange.length > 0){
        
        int afterSelectIndex = (int) selectRange.location + (int) selectRange.length;
        NSString *upperCaseAfterSelect = [[upperCaseSQL substringFromIndex:afterSelectIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if([upperCaseAfterSelect hasPrefix:@"COUNT"]){
            [sqlCommands addObject:statement];
        }else{
            
            int fromIndex = -1;
            NSRange fromRange = [upperCaseSQL rangeOfString:@"FROM"];
            if(fromRange.length > 0){
                fromIndex = (int) fromRange.location;
            }
            
            if([upperCaseAfterSelect hasPrefix:@"DISTINCT"]){
                
                NSRange commaRange = [upperCaseSQL rangeOfString:@","];
                if(commaRange.length == 0 || commaRange.location >= fromIndex){
                    
                    [sqlCommands addObject:[NSString stringWithFormat:@"SELECT COUNT(%@) %@", [statement substringWithRange:NSMakeRange(afterSelectIndex, fromIndex - afterSelectIndex)], [statement substringFromIndex:fromIndex]]];
                    
                    NSMutableString *isNull = [NSMutableString stringWithString:@"SELECT COUNT(*) > 0 "];
                    NSRange distinctRange = [upperCaseSQL rangeOfString:@"DISTINCT"];
                    int afterDistinctIndex = (int) distinctRange.location + (int) distinctRange.length;
                    NSString *columnIsNull = [NSString stringWithFormat:@"%@IS NULL", [statement substringWithRange:NSMakeRange(afterDistinctIndex, fromIndex - afterDistinctIndex)]];
                    NSRange whereRange = [upperCaseSQL rangeOfString:@"WHERE"];
                    NSRange endRange = [statement rangeOfString:@";"];
                    int endIndex;
                    if(endRange.length == 0){
                        endIndex = (int) statement.length;
                    }else{
                        endIndex = (int) endRange.location;
                    }
                    if(whereRange.length > 0){
                        int afterWhereIndex = (int) whereRange.location + (int) whereRange.length;
                        [isNull appendString:[statement substringWithRange:NSMakeRange(fromIndex, afterWhereIndex - fromIndex)]];
                        [isNull appendString:columnIsNull];
                        [isNull appendString:@" AND ( "];
                        [isNull appendString:[statement substringWithRange:NSMakeRange(afterWhereIndex, endIndex - afterWhereIndex)]];
                        [isNull appendString:@" )"];
                    }else{
                        [isNull appendString:[statement substringWithRange:NSMakeRange(fromIndex, endIndex - fromIndex)]];
                        [isNull appendString:@" WHERE"];
                        [isNull appendString:columnIsNull];
                    }
                    
                    [sqlCommands addObject:isNull];
                    
                }
                
            }else if(fromIndex != -1){
                [sqlCommands addObject:[NSString stringWithFormat:@"SELECT COUNT(*) %@", [statement substringFromIndex:fromIndex]]];
            }
        }
        
        count = -1;
        if(sqlCommands.count == 0){
            // Unable to count
            NSLog(@"Unable to count query without result iteration. SQL: %@, args: %@", statement, args);
        }else{
            count = 0;
            for(NSString *sqlCommand in sqlCommands){
                @try {
                    NSObject *value = [self querySingleResultWithDatabase:connection andSql:sqlCommand andArgs:args andColumn:0 andDataType:GPKG_DT_MEDIUMINT];
                    if(value != nil){
                        count += [((NSNumber *) value) intValue];
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Unable to count query without result iteration. SQL: %@, args: %@. error: %@", statement, args, exception);
                    count = -1;
                }
            }
        }
        
    }
    
    return count;
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table{
    return [self countWithDatabase:connection andTable:table andWhere:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where{
    return [self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDatabase:connection andTable:table andColumn:nil andWhere:where andWhereArgs:whereArgs];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement{
    return [self countWithDatabase:connection andCountStatement:countStatement andArgs:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement andArgs: (NSArray *) args{
    return [self querySingleIntegerWithDatabase:connection andSql:countStatement andArgs:args andAllowEmpty:YES];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column{
    return [self countWithDatabase:connection andTable:table andDistinct:NO andColumn:column];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column{
    return [self countWithDatabase:connection andTable:table andDistinct:distinct andColumn:column andWhere:nil andWhereArgs:nil];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDatabase:connection andTable:table andDistinct:NO andColumn:column andWhere:where andWhereArgs:whereArgs];
}

+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"SELECT COUNT"];
    [sql appendString:@"("];
    if(column != nil){
        if(distinct){
            [sql appendString:@"DISTINCT "];
        }
        [sql appendString:[GPKGSqlUtils quoteWrapName:column]];
    }else{
        [sql appendString:@"*"];
    }
    [sql appendString:@") FROM "];
    [sql appendString:[self quoteWrapName:table]];
    if(where != nil){
        [sql appendString:@" "];
        if(![[where uppercaseString] hasPrefix:@"WHERE"]){
            [sql appendString:@"WHERE "];
        }
        [sql appendString:where];
    }
    
    int count = [self countWithDatabase: connection andCountStatement:sql andArgs:whereArgs];
    
    return count;
}

+(int) querySingleIntegerWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andAllowEmpty: (BOOL) allowEmptyResults{
    
    int result = 0;
    
    NSObject *value = [self querySingleResultWithDatabase:connection andSql:sql andArgs:args andColumn:0 andDataType:GPKG_DT_MEDIUMINT];
    if(value != nil){
        result = [((NSNumber *) value) intValue];
    }else if(!allowEmptyResults){
        [NSException raise:@"Single Integer Query" format:@"Failed to query for single result. SQL: %@", sql];
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
    
    NSMutableArray<NSObject *> *results = [NSMutableArray array];
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
    
    NSMutableArray<NSArray<NSObject *> *> *results = [NSMutableArray array];
    @try {
        int columns = (int)result.columnNames.count;
        while([result moveToNext]) {
            NSMutableArray<NSObject *> *row = [NSMutableArray array];
            for(int i = 0; i < columns; i++){
                enum GPKGDataType dataType = -1;
                if(dataTypes != nil){
                    dataType = [((NSNumber *)dataTypes[i]) intValue];
                }
                [GPKGUtils addObject:[self valueInResult:result atIndex:i withDataType:dataType] toArray:row];
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
    int type = [result type:index];
    return [self valueInResult:result atIndex:index withType:type andDataType:dataType];
}

+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withType: (int) type{
    return [self valueInResult:result atIndex:index withType:type andDataType:-1];
}

+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withType: (int) type andDataType: (enum GPKGDataType) dataType{
    
    NSObject *value = nil;
    
    switch (type) {
            
        case SQLITE_INTEGER:
            value = [self integerValueInResult:result atIndex:index withDataType:dataType];
            break;
            
        case SQLITE_FLOAT:
            value = [self floatValueInResult:result atIndex:index withDataType:dataType];
            break;
            
        case SQLITE_TEXT:
            {
                NSString *stringValue = [result stringWithIndex:index];
                
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
            value = [result blobWithIndex:index];
            break;
            
        case SQLITE_NULL:
            // leave value as null
            break;
    }
    
    return value;
}

+(NSObject *) integerValueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType{
    
    NSObject *value = nil;
    
    if((int)dataType == -1){
        dataType = GPKG_DT_INTEGER;
    }
    
    switch (dataType) {
        case GPKG_DT_BOOLEAN:
            {
                NSNumber *booleanNumberValue = [result intWithIndex:index];
                if(booleanNumberValue != nil){
                    BOOL booleanValue = [GPKGSqlUtils boolValueOfNumber:booleanNumberValue];
                    value = [NSNumber numberWithBool:booleanValue];
                }
            }
            break;
        case GPKG_DT_TINYINT:
        case GPKG_DT_SMALLINT:
        case GPKG_DT_MEDIUMINT:
            value = [result intWithIndex:index];
            break;
        case GPKG_DT_INT:
        case GPKG_DT_INTEGER:
            value = [result longWithIndex:index];
            break;
        default:
            [NSException raise:@"Integer Value" format:@"Data Type %@ is not an integer type", [GPKGDataTypes name:dataType]];
    }
    
    return value;
}

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
            value = [result doubleWithIndex:index];
            break;
        default:
            [NSException raise:@"Float Value" format:@"Data Type %@ is not a float type", [GPKGDataTypes name:dataType]];
    }
    
    return value;
}
 
+(NSObject *) value: (NSObject *) value asDataType: (enum GPKGDataType) dataType{

    if(value != nil && dataType >= 0){

        @try {

            switch (dataType) {
            case GPKG_DT_DATE:
            case GPKG_DT_DATETIME:
                {
                    if (![value isKindOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]]) {
                        value = [GPKGDateTimeUtils convertToDateWithString:(NSString *)value];
                    }
                }
                break;
            default:
                break;
            }

        } @catch (NSException *exception) {
            NSLog(@"Invalid %@ format: %@, %@ value used, error: %@", [GPKGDataTypes name:dataType], value, NSStringFromClass([value class]), exception);
        }

    }

    return value;
}

+(NSNumber *) minWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column{
    return [self minWithDatabase:connection andTable:table andColumn:column andWhere:nil andWhereArgs:nil];
}

+(NSNumber *) minWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSNumber * min = nil;
    if([self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs] > 0){
        NSMutableString *minStatement = [NSMutableString string];
        
        [minStatement appendFormat:@"SELECT MIN(%@) FROM %@", [self quoteWrapName:column], [self quoteWrapName:table]];
        
        if(where != nil){
            [minStatement appendString:@" "];
            if(![[where uppercaseString] hasPrefix:@"WHERE"]){
                [minStatement appendString:@"WHERE "];
            }
            [minStatement appendString:where];
        }
        
        min = [NSNumber numberWithInt:[self querySingleIntegerWithDatabase:connection andSql:minStatement andArgs:whereArgs andAllowEmpty:NO]];
    }
    
    return min;
}

+(NSNumber *) maxWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column{
    return [self maxWithDatabase:connection andTable:table andColumn:column andWhere:nil andWhereArgs:nil];
}

+(NSNumber *) maxWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSNumber * max = nil;
    if([self countWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs] > 0){
        NSMutableString *maxStatement = [NSMutableString string];
        
        [maxStatement appendFormat:@"SELECT MAX(%@) FROM %@", [self quoteWrapName:column], [self quoteWrapName:table]];
        
        if(where != nil){
            [maxStatement appendString:@" "];
            if(![[where uppercaseString] hasPrefix:@"WHERE"]){
                [maxStatement appendString:@"WHERE "];
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
    [insertStatement appendString:@"INSERT INTO "];
    [insertStatement appendString:[self quoteWrapName:table]];
    [insertStatement appendString:@"("];
    
    int size = (values != nil) ? [values size] : 0;
    NSMutableArray * args = [NSMutableArray arrayWithCapacity:size];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [insertStatement appendString:@","];
        }
        [insertStatement appendString:[self quoteWrapName:colName]];
        NSObject * value = [values valueForKey:colName];
        if(value == nil){
            value = [NSNull null];
        }
        [args addObject:value];
        i++;
    }
    [insertStatement appendString:@") VALUES ("];
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
    @try {
        
        int prepareStatementResult = sqlite3_prepare_v2([connection connection], [statement UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            [self setArguments:args inStatement:compiledStatement];
            int executeQueryResults = sqlite3_step(compiledStatement);
            if (executeQueryResults == SQLITE_DONE) {
                lastInsertRowId = sqlite3_last_insert_rowid([connection connection]);
            }else{
                [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg([connection connection])];
            }
        } else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute insert SQL: %@, Error: %s", statement, sqlite3_errmsg([connection connection])];
        }
        
    } @finally {
        [self closeStatement:compiledStatement];
    }
    
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
    [updateStatement appendString:@"UPDATE "];
    [updateStatement appendString:[self quoteWrapName:table]];
    [updateStatement appendString:@" SET "];
    
    int setValuesSize = [values size];
    int argsSize = (whereArgs == nil) ? setValuesSize : (setValuesSize + (int)[whereArgs count]);
    NSMutableArray * args = [NSMutableArray arrayWithCapacity:argsSize];
    
    int i = 0;
    for(NSString * colName in [values keySet]){
        if(i > 0){
            [updateStatement appendString:@","];
        }
        [updateStatement appendString:[self quoteWrapName:colName]];
        NSObject * value = [values valueForKey:colName];
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
    if(where != nil && where.length > 0){
        [updateStatement appendString:@" WHERE "];
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
    
    [deleteStatement appendString:@"DELETE FROM "];
    [deleteStatement appendString:[self quoteWrapName:table]];
    
    if(where != nil){
        [deleteStatement appendString:@" WHERE "];
        [deleteStatement appendString:where];
    }
    
    int count = [self deleteWithDatabase:connection andStatement:deleteStatement andArgs:whereArgs];
    
    return count;
}

+(int) updateOrDeleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args{
    
    int rowsModified = -1;
    
    sqlite3_stmt *compiledStatement;
    @try {
    
        int prepareStatementResult = sqlite3_prepare_v2([connection connection], [statement UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            [self setArguments:args inStatement:compiledStatement];
            int executeQueryResults = sqlite3_step(compiledStatement);
            if (executeQueryResults == SQLITE_DONE) {
                rowsModified = sqlite3_changes([connection connection]);
            }else{
                [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg([connection connection])];
            }
        } else{
            [NSException raise:@"SQL Failed" format:@"Failed to execute update or delete SQL: %@, Error: %s", statement, sqlite3_errmsg([connection connection])];
        }
    
    } @finally {
        [self closeStatement:compiledStatement];
    }
    
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
                
                BOOL success = NO;
                
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
    sqlite3_close([connection connection]);
}

+(NSString *) sqlValueString: (NSObject *) value{
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

+(NSArray<NSString *> *) quoteWrapNames: (NSArray<NSString *> *) names{
    NSMutableArray * quoteNames = nil;
    if(names != nil){
        quoteNames = [NSMutableArray array];
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
            unquotedName = [name substringWithRange:NSMakeRange(1, [name length] - 2)];
        }else{
            unquotedName = name;
        }
    }
    return unquotedName;
}

+(NSString *) createTableSQL: (GPKGUserTable *) table{
    
    // Build the create table sql
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"CREATE TABLE %@ (", [self quoteWrapName:table.tableName]];
    
    // Add each column to the sql
    GPKGUserColumns *columns = [table userColumns];
    for(int i = 0; i < [columns columnCount]; i++){
        GPKGUserColumn *column = [columns columnWithIndex:i];
        if(i > 0){
            [sql appendString:@","];
        }
        [sql appendFormat:@"\n  "];
        [sql appendString:[self columnSQL:column]];
    }
    
    // Add constraints
    NSArray<GPKGConstraint *> *constraints = [[table constraints] all];
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
    
    NSMutableString *sql = [NSMutableString string];
    
    [sql appendString:column.type];
    
    if([column hasMax]){
        [sql appendFormat:@"(%d)", [column.max intValue]];
    }
    
    for(GPKGConstraint *constraint in [column.constraints all]){
        NSString *constraintSql = [column buildConstraintSql:constraint];
        if (constraintSql != nil) {
            [sql appendFormat:@" %@", constraintSql];
        }
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
                    break;
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
    NSNumber *foreignKeys = (NSNumber *)[db querySingleResultWithSql:@"PRAGMA foreign_keys" andArgs:nil andDataType:GPKG_DT_BOOLEAN];
    return [self boolValueOfNumber:foreignKeys];
}

+(BOOL) foreignKeysAsOn: (BOOL) on withConnection: (GPKGConnection *) db{
    
    BOOL foreignKeys = [self foreignKeysWithConnection:db];
    
    if(foreignKeys != on){
        NSString *sql = [self foreignKeysSQLAsOn:on];
        [db execPersistentAllConnectionStatement:sql asName:@"foreign_keys"];
    }
    
    return foreignKeys;
}

+(NSString *) foreignKeysSQLAsOn: (BOOL) on{
    return [NSString stringWithFormat:@"PRAGMA foreign_keys = %@", (on ? @"true" : @"false")];
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
    [db execResettable:sql];
}

+(NSString *) dropTableSQL: (NSString *) tableName{
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [self quoteWrapName:tableName]];
}

+(void) dropView: (NSString *) viewName withConnection: (GPKGConnection *) db{
    NSString *sql = [self dropViewSQL:viewName];
    [db execResettable:sql];
}

+(NSString *) dropViewSQL: (NSString *) viewName{
    return [NSString stringWithFormat:@"DROP VIEW IF EXISTS %@", [self quoteWrapName:viewName]];
}

+(void) transferTableContent: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{
    NSString *sql = [self transferTableContentSQL:tableMapping];
    [db exec:sql];
}

+(NSString *) transferTableContentSQL: (GPKGTableMapping *) tableMapping{
    
    NSMutableString *insert = [NSMutableString stringWithString:@"INSERT INTO "];
    [insert appendString:[self quoteWrapName:tableMapping.toTable]];
    [insert appendString:@" ("];
    
    NSMutableString *selectColumns = [NSMutableString string];
    
    NSMutableString *where = [NSMutableString string];
    if([tableMapping hasWhere]){
        [where appendString:tableMapping.where];
    }
    
    for(NSString *toColumn in [tableMapping columnNames]){
        
        GPKGMappedColumn *column = [tableMapping columnForName:toColumn];
        
        if(selectColumns.length > 0){
            [insert appendString:@", "];
            [selectColumns appendString:@", "];
        }
        [insert appendString:[self quoteWrapName:toColumn]];
        
        if([column hasConstantValue]){
            
            [selectColumns appendString:[column constantValueAsString]];
            
        }else{
            
            if([column hasDefaultValue]){
                [selectColumns appendString:@"IFNULL("];
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
            [where appendString:[self quoteWrapName:[column fromColumn]]];
            [where appendString:@" "];
            [where appendString:[column whereOperator]];
            [where appendString:@" "];
            [where appendString:[column whereValueAsString]];
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
    
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTableName:tableName andConnection:db];
    if(idColumnName != nil){
        [tableMapping removeColumn:idColumnName];
    }
    GPKGMappedColumn *tileMatrixSetNameColumn = [tableMapping columnForName:columnName];
    [tileMatrixSetNameColumn setConstantValue:newColumnValue];
    [tileMatrixSetNameColumn setWhereValue:currentColumnValue];
    
    [self transferTableContent:tableMapping withConnection:db];
}

+(NSString *) tempTableNameWithPrefix: (NSString *) prefix andBaseName: (NSString *) baseName withConnection: (GPKGConnection *) db{
    NSString *name = [NSString stringWithFormat:@"%@_%@", prefix, baseName];
    int nameNumber = 0;
    while([db tableOrViewExists:name]){
        name = [NSString stringWithFormat:@"%@%d_%@", prefix, ++nameNumber, baseName];
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
        NSMutableString *updatedSqlBuilder = [NSMutableString string];
        
        // Split the SQL apart by the name
        NSArray<NSString *> *parts = [sql componentsSeparatedByString:name];
        
        int partsCount = (int) parts.count;
        if(partsCount > 0 && [parts objectAtIndex:partsCount - 1].length == 0){
            partsCount -= 1;
        }
        
        for (int i = 0; i <= partsCount; i++) {
            
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
                if (i < partsCount) {
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
            if(i < partsCount){
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
    NSString *newName = [name stringByReplacingOccurrencesOfString:replace withString:replacement options:NSCaseInsensitiveSearch range:NSMakeRange(0, name.length)];
    
    // If no name change was made
    if([newName isEqualToString:name]){
        
        NSString *baseName = newName;
        int count = 1;
        
        // Find any existing end number: name_#
        NSInteger index = [baseName rangeOfString:@"_" options:NSBackwardsSearch].location;
        if (index != NSNotFound && index + 1 < baseName.length) {
            NSString *numberPart = [baseName substringFromIndex:index + 1];
            if([numberExpression numberOfMatchesInString:numberPart options:0 range:NSMakeRange(0, numberPart.length)] == 1){
                baseName = [baseName substringWithRange:NSMakeRange(0, index)];
                count = [numberPart intValue];
            }
        }
        
        // Set the new name to name_2 or name_(#+1)
        newName = [NSString stringWithFormat:@"%@_%d", baseName, ++count];
        
        if (db != nil) {
            // Check for conflicting SQLite Master table names
            while([GPKGSQLiteMaster countWithConnection:db andQuery:[GPKGSQLiteMasterQuery createWithColumn:GPKG_SMC_NAME andValue:newName]] > 0){
                newName = [NSString stringWithFormat:@"%@_%d", baseName, ++count];
            }
        }
        
    }
    
    return newName;
}

+(void) vacuumWithConnection: (GPKGConnection *) db{
    [db execResettable:@"VACUUM"];
}

+(BOOL) boolValueOfNumber: (NSNumber *) number{
    return number != nil && [number intValue] == 1;
}

@end
