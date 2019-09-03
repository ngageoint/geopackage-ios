//
//  GPKGSQLiteMasterQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGSQLiteMasterQuery.h"
#import "GPKGSqlUtils.h"

@interface GPKGSQLiteMasterQuery()

/**
 * Combine operation for multiple queries
 */
@property (nonatomic, strong) NSString *combineOperation;

/**
 * List of queries
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *queries;

/**
 * List of arguments
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *arguments;

@end

@implementation GPKGSQLiteMasterQuery

-(instancetype) initWithOperation: (NSString *) combineOperation{
    self = [super init];
    if(self != nil){
        self.combineOperation = combineOperation;
        self.queries = [[NSMutableArray alloc] init];
        self.arguments = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addColumn: (enum GPKGSQLiteMasterColumn) column withValue: (NSString *) value{
    [self addColumn:column withOperation:@"=" andValue:value];
}

-(void) addColumn: (enum GPKGSQLiteMasterColumn) column withOperation: (NSString *) operation andValue: (NSString *) value{
    [self validateAdd];
    [_queries addObject:[NSString stringWithFormat:@"LOWER(%@) %@ LOWER(?)", [GPKGSqlUtils quoteWrapName:[[GPKGSQLiteMasterColumns name:column] lowercaseString]], operation]];
    [_arguments addObject:value];
}

-(void) addIsNullColumn: (enum GPKGSQLiteMasterColumn) column{
    [self validateAdd];
    [_queries addObject:[NSString stringWithFormat:@"%@ IS NULL", [GPKGSqlUtils quoteWrapName:[[GPKGSQLiteMasterColumns name:column] lowercaseString]]]];
}

-(void) addIsNotNullColumn: (enum GPKGSQLiteMasterColumn) column{
    [self validateAdd];
    [_queries addObject:[NSString stringWithFormat:@"%@ IS NOT NULL", [GPKGSqlUtils quoteWrapName:[[GPKGSQLiteMasterColumns name:column] lowercaseString]]]];
}

/**
 * Validate the state of the query when adding to the query
 */
-(void) validateAdd{
    if (self.combineOperation == nil && self.queries.count > 0) {
        [NSException raise:@"Single Query" format:@"Query without a combination operation supports only a single query"];
    }
}

-(BOOL) has{
    return self.queries > 0;
}

-(NSString *) buildSQL{
    NSMutableString *sql = [[NSMutableString alloc] init];
    if(self.queries.count > 1){
        [sql appendString:@"( "];
    }
    for(int i = 0; i < self.queries.count; i++){
        if(i > 0){
            [sql appendString:@" "];
            [sql appendString:self.combineOperation];
            [sql appendString:@" "];
        }
        [sql appendFormat:@"%@", [self.queries objectAtIndex:i]];
    }
    if(self.queries.count > 1){
        [sql appendString:@" )"];
    }
    return sql;
}

-(NSArray<NSString *> *) arguments{
    return _arguments;
}

+(GPKGSQLiteMasterQuery *) create{
    return [[GPKGSQLiteMasterQuery alloc] initWithOperation:nil];
}

+(GPKGSQLiteMasterQuery *) createOr{
    return [[GPKGSQLiteMasterQuery alloc] initWithOperation:@"OR"];
}

+(GPKGSQLiteMasterQuery *) createAnd{
    return [[GPKGSQLiteMasterQuery alloc] initWithOperation:@"AND"];
}

+(GPKGSQLiteMasterQuery *) createWithColumn: (enum GPKGSQLiteMasterColumn) column andValue: (NSString *) value{
    GPKGSQLiteMasterQuery *query = [self create];
    [query addColumn:column withValue:value];
    return query;
}

+(GPKGSQLiteMasterQuery *) createWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValue: (NSString *) value{
    GPKGSQLiteMasterQuery *query = [self create];
    [query addColumn:column withOperation:operation andValue:value];
    return query;
}

+(GPKGSQLiteMasterQuery *) createOrWithColumn: (enum GPKGSQLiteMasterColumn) column andValues: (NSArray<NSString *> *) values{
    GPKGSQLiteMasterQuery *query = [self createOr];
    for(NSString *value in values){
        [query addColumn:column withValue:value];
    }
    return query;
}

+(GPKGSQLiteMasterQuery *) createOrWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValues: (NSArray<NSString *> *) values{
    GPKGSQLiteMasterQuery *query = [self createOr];
    for(NSString *value in values){
        [query addColumn:column withOperation:operation andValue:value];
    }
    return query;
}

+(GPKGSQLiteMasterQuery *) createAndWithColumn: (enum GPKGSQLiteMasterColumn) column andValues: (NSArray<NSString *> *) values{
    GPKGSQLiteMasterQuery *query = [self createAnd];
    for(NSString *value in values){
        [query addColumn:column withValue:value];
    }
    return query;
}

+(GPKGSQLiteMasterQuery *) createAndWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValues: (NSArray<NSString *> *) values{
    GPKGSQLiteMasterQuery *query = [self createAnd];
    for(NSString *value in values){
        [query addColumn:column withOperation:operation andValue:value];
    }
    return query;
}

+(GPKGSQLiteMasterQuery *) createViewQueryWithTable: (NSString *) tableName{
    
    NSMutableArray<NSString *> *queries = [[NSMutableArray alloc] init];
    [queries addObject:[NSString stringWithFormat:@"%%\"%@\"%%", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%% %@ %%", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%%,%@ %%", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%% %@,%%", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%%,%@,%%", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%% %@", tableName]];
    [queries addObject:[NSString stringWithFormat:@"%%,%@", tableName]];
    
    return [GPKGSQLiteMasterQuery createOrWithColumn:GPKG_SMC_SQL andOperation:@"LIKE" andValues:queries];
}

@end
