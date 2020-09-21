//
//  GPKGFeatureTileLinkTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"
#import "GPKGNGATableCreator.h"

/**
 * Feature Tile Link Extension Table Creator
 */
@interface GPKGFeatureTileLinkTableCreator : GPKGNGATableCreator

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new feature tile link table creator
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 * Initialize
 *
 * @param geoPackage
 *            GeoPackage
 *
 *  @return new feature tile link table creator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Create Feature Tile Link table
 *
 *  @return tables created
 */
-(int) createFeatureTileLink;

@end
