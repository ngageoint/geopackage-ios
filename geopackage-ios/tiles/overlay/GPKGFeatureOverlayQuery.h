//
//  GPKGFeatureOverlayQuery.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureOverlay.h"

/**
 * Used to query the features represented by the tiles drawn in a FeatureOverlay
 */
@interface GPKGFeatureOverlayQuery : NSObject

/**
 *  Table name used when building text
 */
@property (nonatomic, strong) NSString * name;

/**
 * Screen click percentage between 0.0 and 1.0 for how close a feature on the screen must be
 * to be included in a click query
 */
@property (nonatomic) float screenClickPercentage;

/**
 * Flag indicating if building info messages for tiles with features over the max is enabled
 */
@property (nonatomic) BOOL maxFeaturesInfo;

/**
 * Flag indicating if building info messages for clicked features is enabled
 */
@property (nonatomic) BOOL featuresInfo;

/**
 * Max number of points clicked to return detailed information about
 */
@property (nonatomic) int maxPointDetailedInfo;

/**
 * Max number of features clicked to return detailed information about
 */
@property (nonatomic) int maxFeatureDetailedInfo;

/**
 * Print Point geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintPoints;

/**
 * Print Feature geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintFeatures;

/**
 *  Initialize
 *
 *  @param featureOverlay feature overlay
 *
 *  @return new feature overlay query
 */
-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay;

/**
 *  Get the feature overlay
 *
 *  @return feature overlay
 */
-(GPKGFeatureOverlay *) getFeatureOverlay;

/**
 *  Get the feature tiles
 *
 *  @return feature tiles
 */
-(GPKGFeatureTiles *) getFeatureTiles;

/**
 *  Get the geometry type
 *
 *  @return geometry type
 */
-(enum WKBGeometryType) getGeometryType;

// TODO

@end
