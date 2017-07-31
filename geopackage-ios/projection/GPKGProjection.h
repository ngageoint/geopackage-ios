//
//  GPKGProjection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proj_api.h"
#import "GPKGUnits.h"

/**
 *  Single Projection for an authority and code
 */
@interface GPKGProjection : NSObject

/**
 *  Initialize
 *
 *  @param authority coordinate authority
 *  @param code      coordinate code
 *  @param crs       coordinate reference system
 *  @param toMeters  to meters conversion
 *
 *  @return new projection
 */
-(instancetype) initWithAuthority: (NSString *) authority andNumberCode: (NSNumber *) code andCrs: (projPJ) crs andToMeters: (NSDecimalNumber *) toMeters;

/**
 *  Initialize
 *
 *  @param authority coordinate authority
 *  @param code      coordinate code
 *  @param crs       coordinate reference system
 *  @param toMeters  to meters conversion
 *
 *  @return new projection
 */
-(instancetype) initWithAuthority: (NSString *) authority andCode: (NSString *) code andCrs: (projPJ) crs andToMeters: (NSDecimalNumber *) toMeters;

/**
 * Get the coordinate authority
 *
 * @return authority
 */
-(NSString *) authority;

/**
 * Get the coordinate code
 *
 * @return code
 */
-(NSString *) code;

/**
 * Get the Coordinate Reference System
 *
 * @return Coordinate Reference System
 */
-(projPJ) crs;

/**
 * Get the to meters conversion value
 *
 * @return to meters
 */
-(NSDecimalNumber *) toMeters;

/**
 * Check if a lat lon crs
 *
 * @return true if a lat lon crs
 */
-(BOOL) isLatLong;

/**
 *  Convert the value to meters
 *
 *  @param value value
 *
 *  @return meters
 */
-(double) toMeters: (double) value;

/**
 *  Get the projection unit
 *
 *  @return unit
 */
-(enum GPKGUnit) getUnit;

/**
 * Check if this projection is equal to the authority and code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 * @return true if equal
 */
-(BOOL) isEqualToAuthority: (NSString *) authority andNumberCode: (NSNumber *) code;

/**
 * Check if this projection is equal to the authority and code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 * @return true if equal
 */
-(BOOL) isEqualToAuthority: (NSString *) authority andCode: (NSString *) code;

/**
 * Check if this projection is equal to the projection
 *
 * @param projection
 *            projection
 * @return true if equal
 */
-(BOOL) isEqualToProjection: (GPKGProjection *) projection;

@end
