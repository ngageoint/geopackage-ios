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
@property (nonatomic) BOOL idOnly;

@end

@implementation GPKGFeatureIndexMetadataResults

-(instancetype) initWithFeatureTableIndex: (GPKGFeatureIndexer *) featureIndexer andResults: (GPKGResultSet *) results{
    self = [super initWithResults:results];
    if(self != nil){
        self.featureIndexer = featureIndexer;
        self.idOnly = [results columnCount] == 1;
    }
    return self;
}

-(GPKGFeatureRow *) featureRow{
    return [self.featureIndexer featureRowWithResultSet:[self results]];
}

-(NSNumber *) featureId{
    NSNumber *id = nil;
    if(self.idOnly){
        id = [[self results] intWithIndex:0];
    }else{
        id = [self.featureIndexer geometryIdWithResultSet:[self results]];
    }
    return id;
}

@end
