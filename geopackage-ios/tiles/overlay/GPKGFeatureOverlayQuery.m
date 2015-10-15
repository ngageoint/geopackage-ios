//
//  GPKGFeatureOverlayQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQuery.h"

@interface GPKGFeatureOverlayQuery ()

@property (nonatomic, strong) GPKGFeatureOverlay *featureOverlay;
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;
@property (nonatomic) enum WKBGeometryType geometryType;

@end

@implementation GPKGFeatureOverlayQuery

-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay{
    self = [super init];
    if(self != nil){
        self.featureOverlay = featureOverlay;
        self.featureTiles = featureOverlay.featureTiles;
        
        GPKGFeatureDao * featureDao = [self.featureTiles getFeatureDao];
        self.geometryType = [featureDao getGeometryType];
        self.name = [NSString stringWithFormat:@"%@ - %@", featureDao.databaseName, featureDao.tableName];
        
        // Get the screen percentage to determine when a feature is clicked
        self.screenClickPercentage = .03; // TODO configure
        
        self.maxFeaturesInfo = true; // TODO configure
        self.featuresInfo = true; // TODO configure
        
        self.maxPointDetailedInfo = 10; // TODO configure
        self.maxFeatureDetailedInfo = 10; // TODO configure
        
        self.detailedInfoPrintPoints = true; // TODO configure
        self.detailedInfoPrintFeatures = false; // TODO configure
    }
    return self;
}

-(GPKGFeatureOverlay *) getFeatureOverlay{
    return self.featureOverlay;
}

-(GPKGFeatureTiles *) getFeatureTiles{
    return self.featureTiles;
}

-(enum WKBGeometryType) getGeometryType{
    return self.geometryType;
}

// TODO

@end
