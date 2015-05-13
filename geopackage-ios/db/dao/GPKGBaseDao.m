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
        self.databaseName = database.name;
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
    NSString *countString = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'", tableName];
    int count = [self.database count:countString];
    BOOL found = count > 0;
    return found;
}

-(void) dropTable{
    [self.database exec:[NSString stringWithFormat:@"drop table if exists %@", [self getTableName]]];
}

-(GPKGResultSet *) queryForId: (NSObject *) idValue{
    
    NSString * whereString = [self buildPkWhereWithValue:idValue];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    
    GPKGResultSet *results = [self queryForId:idValue];
    NSObject * objectResult = [self getFirstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues{
    
    NSString * whereString = [self buildPkWhereWithValues:idValues];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues{
    
    GPKGResultSet *results = [self queryForMultiId:idValues];
    NSObject * objectResult = [self getFirstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForAll{
    return [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:nil andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(NSObject *) getObject: (GPKGResultSet *) results{
    
    NSArray *result = [results getRow];
    NSObject *objectResult = [self createObjectWithColumns:results.columns andValues:result];
    
    return objectResult;
}

-(NSObject *) getFirstObject: (GPKGResultSet *)results{
    NSObject *objectResult = nil;
    if([results moveToNext]){
        objectResult = [self getObject: results];
    }
    
    [results close];
    
    return objectResult;
}

-(GPKGResultSet *) rawQuery: (NSString *) query{
    GPKGResultSet *results = [self.database rawQuery:query];
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
    return [self queryForEqWithField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereWithField:field andValue:value];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
    return results;
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereWithField:field andColumnValue:value];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForFieldValues:( NSDictionary *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForColumnValueFieldValues:( NSDictionary *) fieldValues{
    NSString *whereString = [self buildWhereWithColumnValueFields:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:whereString andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForWhere: (NSString *) where{
    return [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:where andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForWhere: (NSString *) where
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy{
    return [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:where andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryForWhere: (NSString *) where
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit{
    return [self.database queryWithTable:[self getTableName] andColumns:nil andWhere:where andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(NSString *) buildPkWhereWithValue: (NSObject *) idValue{
    NSArray * idColumns = [self getIdColumns];
    NSString * whereString = [self buildWhereWithField:[idColumns objectAtIndex:0] andValue:idValue];
    return whereString;
}

-(NSString *) buildPkWhereWithValues: (NSArray *) idValues{
    NSArray * idColumns = [self getIdColumns];
    NSMutableDictionary *idDictionary = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < [idValues count]; i++){
        [idDictionary setObject:[idValues objectAtIndex:i] forKey:[idColumns objectAtIndex:i]];
    }
    NSString * whereString = [self buildWhereWithFields:idDictionary];
    return whereString;
}

-(NSString *) buildWhereWithFields: (NSDictionary *) fields{
    NSMutableString *whereString = [NSMutableString string];
    for(id key in fields){
        if([whereString length] > 0){
            [whereString appendString:@" and "];
        }
        [whereString appendString:[self buildWhereWithField:key andValue:[fields objectForKey:key]]];
    }
    return whereString;
}

-(NSString *) buildWhereWithColumnValueFields: (NSDictionary *) fields{
    NSMutableString *whereString = [NSMutableString string];
    for(id key in fields){
        if([whereString length] > 0){
            [whereString appendString:@" and "];
        }
        [whereString appendString:[self buildWhereWithField:key andColumnValue:[fields objectForKey:key]]];
    }
    return whereString;
}

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

-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    
    NSMutableString *whereString = [NSMutableString string];
    
    if(value != nil){
        if(value.value != nil && value.tolerance != nil){
            double doubleValue = [(NSNumber *)value.value doubleValue];
            double tolerance = [value.tolerance doubleValue];
            [whereString appendFormat:@"%@ >= %f and %@ <= %f", field, doubleValue - tolerance, field, doubleValue + tolerance];
        }else{
            [whereString appendString:[self buildWhereWithField:field andValue:value.value]];
        }
    }else{
        [whereString appendString:[self buildWhereWithField:field andValue:nil]];
    }
    
    return whereString;
}

-(int) count{
    return [self countWhere:nil];
}

-(int) countWhere: (NSString *) where{
    NSMutableString *countString = [NSMutableString string];
    NSString * tableName = [self getTableName];
    [countString appendFormat:@"select count(*) from %@", tableName];
    if(where != nil){
        [countString appendString:@" "];
        if(![where hasPrefix:@"where"]){
            [countString appendString:@"where "];
        }
        [countString appendString:where];
    }
    return [self.database count:countString];
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
