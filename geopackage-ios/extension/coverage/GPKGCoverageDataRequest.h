//
//  GPKGCoverageDataRequest.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"

/**
 * Coverage Data request to retrieve coverage data values for a point or bounding box
 */
@interface GPKGCoverageDataRequest : NSObject

/**
 * Bounding box projected to the coverage data projection
 */
@property (nonatomic, strong) GPKGBoundingBox *projectedBoundingBox;

/**
 *  Initialize
 *
 *  @param boundingBox bounding box
 *
 *  @return new coverage data request
 */
-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Initialize
 *
 *  @param latitude latitude coordinate
 *  @param longitude longitude coordinate
 *
 *  @return new coverage data request
 */
-(instancetype) initWithLatitude: (double) latitude andLongitude: (double) longitude;

/**
 *  Get the bounding box
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 *  Get if a point request
 *
 *  @return true if a point request
 */
-(BOOL) isPoint;

/**
 *  Get the bounding box overlap between the projected bounding box and the
 *  coverage data bounding box
 *
 *  @param projectedCoverage projected coverage
 *
 *  @return overlap bounding box
 */
-(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) projectedCoverage;

@end
