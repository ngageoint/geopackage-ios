//
//  GPKGContentsIdTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"
#import "GPKGNGATableCreator.h"

@class GPKGGeoPackage;

/**
 * Contents Id Extension Table Creator
 */
@interface GPKGContentsIdTableCreator : GPKGNGATableCreator

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new contents id table creator
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 * Initialize
 *
 * @param geoPackage
 *            GeoPackage
 *
 * @return new contents id table creator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Create Contents Id table
 *
 * @return executed statements
 */
-(int) createContentsId;

@end
