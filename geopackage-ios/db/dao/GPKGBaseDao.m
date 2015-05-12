//
//  GPKGBaseDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"

@interface GPKGBaseDao()

-(NSObject *) createObjectWithColumns: (NSArray *)columns andValues: (NSArray *) values;

@end

@implementation GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super init];
    if(self != nil){
        self.database = database;
    }
    return self;
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

-(NSString *) getTableName{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSObject *) createObjectWithColumns: (NSArray *)columns andValues: (NSArray *) values{
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

-(NSArray *) queryForAll{

    NSString * tableName = [self getTableName];
    NSString *queryString = [NSString stringWithFormat:@"select * from %@", tableName];
    
    GPKGResultSet *results = [self query:queryString];
    
    NSMutableArray *objectResults = [[NSMutableArray alloc] init];
    while([results moveToNext]){
        NSArray *result = [results getRow];
        NSObject *objectResult = [self createObjectWithColumns:results.columns andValues:result];
        [objectResults addObject: objectResult];
    }
    
    [results close];
    
    return objectResults;
}

@end
