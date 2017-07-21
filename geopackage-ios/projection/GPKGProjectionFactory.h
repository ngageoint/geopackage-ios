//
//  GPKGProjectionFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProjection.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGAuthorityProjections.h"

/**
 *  Projection factory for coordinate projections and transformations
 */
@interface GPKGProjectionFactory : NSObject

/**
 *  Get the projection with the epsg number
 *
 *  @param epsg epsg code
 *
 *  @return projection
 */
+(GPKGProjection *) projectionWithEpsg: (NSNumber *) epsg;

/**
 *  Get the projection with the epsg int
 *
 *  @param epsg epsg code
 *
 *  @return projection
 */
+(GPKGProjection *) projectionWithEpsgInt: (int) epsg;

/**
 * Get the projection for authority and code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code;

/**
 * Get the projection for authority and code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code;

/**
 * Get the projection for authority, code, and parameter string
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @param params
 *            proj4 string
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code andParams: (NSString *) params;

/**
 * Get the projection for authority, code, and parameter string
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @param params
 *            proj4 string
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code andParams: (NSString *) params;

/**
 * Get the projection for the authority, code, definition, and custom
 * parameter array
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @param params
 *            proj4 string
 * @param definition
 *            definition
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code andParams: (NSString *) params andDefinition: (NSString *) definition;

/**
 * Get the projection for the authority, code, definition, and custom
 * parameter array
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            authority coordinate code
 * @param params
 *            proj4 string
 * @param definition
 *            definition
 * @return projection
 */
+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code andParams: (NSString *) params andDefinition: (NSString *) definition;

/**
 * Get or create projections for the authority
 *
 * @param authority
 *            coordinate authority
 * @return authority projections
 */
+(GPKGAuthorityProjections *) projectionsWithAuthority: (NSString *) authority;

/**
 * Clear all authority projections
 */
+(void) clear;

/**
 * Clear the authority projections
 *
 * @param authority
 *            coordinate authority
 */
+(void) clearAuthority: (NSString *) authority;

/**
 * Clear the authority projection code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) clearAuthority: (NSString *) authority andNumberCode: (NSNumber *) code;

/**
 * Clear the authority projection code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) clearAuthority: (NSString *) authority andCode: (NSString *) code;

/**
 * Get the projection for the Spatial Reference System
 *
 * @param srs
 *            spatial reference system
 * @return projection
 */
+(GPKGProjection *) projectionWithSrs: (GPKGSpatialReferenceSystem *) srs;

@end
