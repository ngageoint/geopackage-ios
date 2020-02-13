//
//  GPKGFeatureIndexerIdResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/13/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureIndexerIdResultSet.h"

@interface GPKGFeatureIndexerIdResultSet ()

/**
 * Feature Indexer Id Query
 */
@property (nonatomic, strong) GPKGFeatureIndexerIdQuery *idQuery;

@end

@implementation GPKGFeatureIndexerIdResultSet

-(instancetype) initWithResults: (GPKGResultSet *) resultSet andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    self = [super initWithResultSet:resultSet];
    if(self != nil){
        self.idQuery = idQuery;
    }
    return self;
}

-(BOOL) moveToNext{
    BOOL hasNext = [super moveToNext];
    while(hasNext){
        if([self.idQuery hasId:[self id]]){
            break;
        }
        hasNext = [super moveToNext];
    }
    return hasNext;
}

-(int) count{
    // Not exact, but best option without iterating through the features
    return MIN(super.count, [self.idQuery count]);
}

@end
