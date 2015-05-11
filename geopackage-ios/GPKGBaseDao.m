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

-(NSArray *) query: (NSString *) query{
    NSArray *results = [self.database query:query];
    return results;
}

-(NSArray *) singleColumnResults: (NSArray *) results{
    NSMutableArray *singleColumnResults = [[NSMutableArray alloc] init];
    for(NSArray *result in results){
        [singleColumnResults addObject: [result objectAtIndex:(0)]];
    }
    return singleColumnResults;
}

-(NSString *) tableName{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSObject *) create: (NSArray *) values{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(BOOL) isTableExists{
    NSString * tableName = [self tableName];
    NSString *queryString = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'", tableName];
    
    NSArray *results = [self query:queryString];
    NSInteger count = [results count];
    
    return count > 0;
}

-(NSArray *) queryForAll{
    /*
    [self doesNotRecognizeSelector:_cmd];
    return nil;
     */
    NSString * tableName = [self tableName];
    NSString *queryString = [NSString stringWithFormat:@"select * from %@", tableName];
    
    NSArray *results = [self query:queryString];
    
    NSMutableArray *objectResults = [[NSMutableArray alloc] init];
    for(NSArray *result in results){
        NSObject *objectResult = [self create:result];
        [objectResults addObject: objectResult];
    }
    
    return objectResults;
}

@end
