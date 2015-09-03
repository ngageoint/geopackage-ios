//
//  GPKGProjection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proj_api.h"

/**
 *  Single EPSG Projection
 */
@interface GPKGProjection : NSObject

/**
 *  EPSG code
 */
@property (nonatomic, strong) NSNumber *epsg;

/**
 *  Coordinate Reference System
 */
@property (nonatomic) projPJ crs;

/**
 *  To meters conversion value
 */
@property (nonatomic, strong) NSDecimalNumber *toMeters;

/**
 *  True if a lat lon crs
 */
@property (nonatomic) BOOL isLatLong;

/**
 *  Initialize
 *
 *  @param epsg     epsg code
 *  @param crs      coordinate reference system
 *  @param toMeters to meters conversion
 *
 *  @return new projection
 */
-(instancetype) initWithEpsg: (NSNumber *) epsg andCrs: (projPJ) crs andToMeters: (NSDecimalNumber *) toMeters;

/**
 *  Convert the value to meters
 *
 *  @param value value
 *
 *  @return meters
 */
-(double) toMeters: (double) value;

@end
