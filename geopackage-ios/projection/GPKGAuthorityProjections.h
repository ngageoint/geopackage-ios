//
//  GPKGAuthorityProjections.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/19/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProjection.h"

/**
 *  Collection of projections for a single coordinate authority
 */
@interface GPKGAuthorityProjections : NSObject

/**
 * Initialize
 *
 * @param authority
 *            coordinate authority
 *
 *  @return new authority projections
 */
-(instancetype) initWithAuthority: (NSString *) authority;

/**
 * Get the authority
 *
 * @return authority
 */
-(NSString *) authority;

/**
 * Get the projection for the code
 *
 * @param code
 *            coordinate code
 * @return projection
 */
-(GPKGProjection *) projectionForCode: (NSString *) code;

/**
 * Add the projection to the authority
 *
 * @param projection
 *            projection
 */
-(void) addProjection: (GPKGProjection *) projection;

/**
 * Clear all projections for the authority
 */
-(void) clear;

/**
 * Clear the projection with the code
 *
 * @param code
 *            coordinate code
 */
-(void) clearNumberCode: (NSNumber *) code;

/**
 * Clear the projection with the code
 *
 * @param code
 *            coordinate code
 */
-(void) clearCode: (NSString *) code;

@end
