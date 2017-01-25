//
//  GPKGElevationRequest.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGBoundingBox.h"

/**
 * Elevation request to retrieve elevation values for a point or bounding box
 */
@interface GPKGElevationRequest : NSObject

/**
 * Bounding box projected to the elevation tiles projection
 */
@property (nonatomic, strong) GPKGBoundingBox *projectedBoundingBox;

/**
 *  Initialize
 *
 *  @param boundingBox bounding box
 *
 *  @return new elevation request
 */
-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Initialize
 *
 *  @param latitude latitude coordinate
 *  @param longitude longitude coordinate
 *
 *  @return new elevation request
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
 *  elevation bounding box
 *
 *  @param projectedElevation projected elevation
 *
 *  @return overlap bounding box
 */
-(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) projectedElevation;

@end
