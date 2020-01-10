//
//  GPKGFeatureIndexRTreeResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGFeatureIndexRTreeResults.h"

@interface GPKGFeatureIndexRTreeResults ()

@property (nonatomic, strong) GPKGRTreeIndexTableDao *dao;
@property (nonatomic, strong) GPKGResultSet *results;

@end

@implementation GPKGFeatureIndexRTreeResults

-(instancetype) initWithDao: (GPKGRTreeIndexTableDao *) dao andResults: (GPKGResultSet *) results{
    self = [super init];
    if(self != nil){
        self.dao = dao;
        self.results = results;
    }
    return self;
}

-(int) count{
    return self.results.count;
}

-(BOOL) moveToNext{
    return [self.results moveToNext];
}

-(GPKGFeatureRow *) getFeatureRow{
    return [self.dao featureRow:self.results];
}

-(NSNumber *) getFeatureId{
    return [[self.dao row:self.results] id];
}

-(void) close{
    [self.results close];
}

@end
