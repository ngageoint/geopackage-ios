//
//  GPKGProjectionRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Retrieves the proj4 projection parameter string for an authority and coordinate code
 */
@interface GPKGProjectionRetriever : NSObject

/**
 *  Get the proj4 projection string for the EPSG code
 *
 *  @param epsg EPSG code
 *
 *  @return projection string
 */
+(NSString *) projectionWithEpsg: (NSNumber *) epsg;

/**
 * Get the proj4 projection string for the authority coordinate code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 * @return proj4 projection
 */
+(NSString *) projectionWithAuthority: (NSString *) authority andNumberCode: (NSNumber *) code;

/**
 * Get the proj4 projection string for the authority coordinate code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 * @return proj4 projection
 */
+(NSString *) projectionWithAuthority: (NSString *) authority andCode: (NSString *) code;

/**
 * Get or create the projection properties
 *
 * @param authority
 *            coordinate authority
 * @return projection properties
 */
+(NSMutableDictionary *) getOrCreateProjectionsForAuthority: (NSString *) authority;

/**
 * Get the projection properties for the authority
 *
 * @param authority
 *            coordinate authority
 * @return projection properties
 */
+(NSMutableDictionary *) projectionsForAuthority: (NSString *) authority;

/**
 * Clear the properties for all authorities
 */
+(void) clear;

/**
 * Clear the properties for the authority
 *
 * @param authority
 *            coordinate authority
 */
+(void) clearAuthority: (NSString *) authority;

/**
 * Clear the property for the authority code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) clearAuthority: (NSString *) authority andNumberCode: (NSNumber *) code;

/**
 * Clear the property for the authority code
 *
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) clearAuthority: (NSString *) authority andCode: (NSString *) code;

/**
 * Get the properties file path for the authority
 *
 * Resulting Path to file: projections.{authority}.plist
 *
 * @param authority
 *            coordinate authority
 * @return property file name
 */
+(NSString *) propertiesPathForAuthority: (NSString *) authority;

/**
 * Set the projections for the authority with the properties
 *
 * @param projections
 *            properties dictionary
 * @param authority
 *            coordinate authority
 */
+(void) setProjections: (NSMutableDictionary *) projections forAuthority: (NSString *) authority;

/**
 * Set the projection for the authority and code, creating the authority if
 * needed
 *
 * @param projection
 *            proj4 projection
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) setProjection: (NSString *) projection forAuthority: (NSString *) authority andNumberCode: (NSNumber *) code;

/**
 * Set the projection for the authority and code, creating the authority if
 * needed
 *
 * @param projection
 *            proj4 projection
 * @param authority
 *            coordinate authority
 * @param code
 *            coordinate code
 */
+(void) setProjection: (NSString *) projection forAuthority: (NSString *) authority andCode: (NSString *) code;

@end
