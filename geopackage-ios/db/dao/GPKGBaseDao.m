//
//  GPKGBaseDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"

@implementation GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super init];
    if(self != nil){
        self.database = database;
    }
    return self;
}

-(NSObject *) createObjectWithColumns: (NSArray *)columns andValues: (NSArray *) values{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSArray *) getIdColumns{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString *) getTableName{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(BOOL) isTableExists{
    NSString * tableName = [self getTableName];
    NSString *queryString = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'", tableName];
    
    GPKGResultSet *results = [self query:queryString];
    BOOL found = [results moveToNext];
    [results close];
    
    return found;
}

-(NSObject *) queryForId: (NSObject *) idValue{
    NSArray *idValues = @[idValue];
    NSObject *objectResult = [self queryForMultiId: idValues];
    return objectResult;
}

-(NSObject *) queryForMultiId: (NSArray *) idValues{
    NSString * tableName = [self getTableName];
    NSMutableString *queryString = [NSMutableString string];
    [queryString appendFormat:@"select * from %@ where ", tableName];

    NSArray * idColumns = [self getIdColumns];
    for(int i = 0; i < [idValues count]; i++){
        if(i > 0){
            [queryString appendString:@" and "];
        }
        [queryString appendFormat:@"%@ = ", [idColumns objectAtIndex:i]];
        NSObject *idValue = [idValues objectAtIndex:i];
        [queryString appendString:[self getSqlValueString:idValue]];
    }
    
    GPKGResultSet *results = [self query:queryString];

    NSObject *objectResult = [self getObject: results];
    
    [results close];
    
    return objectResult;
}

-(GPKGResultSet *) queryForAll{

    NSString *queryString = [self buildSelectAll];
    GPKGResultSet *results = [self query:queryString];
    
    return results;
}

-(NSObject *) getObject: (GPKGResultSet *) results{
    
    NSObject *objectResult = nil;
    
    if([results moveToNext]){
        NSArray *result = [results getRow];
        objectResult = [self createObjectWithColumns:results.columns andValues:result];
    }
    
    return objectResult;
}

-(GPKGResultSet *) query: (NSString *) query{
    GPKGResultSet *results = [self.database query:query];
    return results;
}

-(NSArray *) singleColumnResults: (GPKGResultSet *) results{
    NSMutableArray *singleColumnResults = [[NSMutableArray alloc] init];
    while([results moveToNext]){
        NSArray *result = [results getRow];
        [singleColumnResults addObject: [result objectAtIndex:(0)]];
    }
    return singleColumnResults;
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value{
    NSString *whereString = [self buildWhereWithField:field andValue:value];
    NSString *queryString = [self buildSelectAllWithWhere:whereString];
    GPKGResultSet *results = [self query:queryString];
    return results;
}

-(NSString *) buildSelectAll{
    NSString * tableName = [self getTableName];
    NSString *queryString = [NSString stringWithFormat:@"select * from %@", tableName];
    return queryString;
}

-(NSString *) buildSelectAllWithWhere: (NSString *) where{
    NSString *queryString = [NSString stringWithFormat:@"%@ where %@", [self buildSelectAll], where];
    return queryString;
}

/*
-(NSString *) buildWhere: (NSDictionary *) fields{
    NSMutableString *queryString = [NSMutableString string];
    //TODO
    return nil;
}
 */

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value{
    return [self buildWhereWithField:field andValue:value andOperation:@"="];
}

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation{
    NSMutableString *whereString = [NSMutableString string];
    [whereString appendFormat:@"%@ ", field];
    if(value == nil){
        [whereString appendString:@"is null"];
    }else{
        [whereString appendFormat:@"%@ %@", operation, [self getSqlValueString:value]];
    }
    return whereString;
}

-(NSString *) getSqlValueString: (NSObject *) value{
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
