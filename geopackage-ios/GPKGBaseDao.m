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

@end
