//
//  GPKGFeatureIndexMetadataResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexMetadataResults.h"

@interface GPKGFeatureIndexMetadataResults ()

@property (nonatomic, strong) GPKGFeatureIndexer *featureIndexer;

@end

@implementation GPKGFeatureIndexMetadataResults

-(instancetype) initWithFeatureTableIndex: (GPKGFeatureIndexer *) featureIndexer andResults: (GPKGResultSet *) results{
    self = [super initWithResults:results];
    if(self != nil){
        self.featureIndexer = featureIndexer;
    }
    return self;
}

-(GPKGFeatureRow *) getFeatureRow{
    return [self.featureIndexer getFeatureRowWithResultSet:[self getResults]];
}

@end
