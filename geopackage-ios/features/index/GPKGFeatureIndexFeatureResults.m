//
//  GPKGFeatureIndexFeatureResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGFeatureIndexFeatureResults.h"

@interface GPKGFeatureIndexFeatureResults ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGFeatureIndexFeatureResults

-(instancetype) initWithDao: (GPKGFeatureDao *) featureDao andResults: (GPKGResultSet *) results{
    self = [super initWithResults:results];
    if(self != nil){
        self.featureDao = featureDao;
    }
    return self;
}

-(GPKGFeatureRow *) getFeatureRow{
    return [self.featureDao getFeatureRow:[self getResults]];
}

-(NSNumber *) getFeatureId{
    return [[self getFeatureRow] getId];
}

@end
