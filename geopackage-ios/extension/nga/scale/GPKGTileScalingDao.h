//
//  GPKGTileScalingDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileScaling.h"
#import "GPKGGeoPackage.h"

/**
 * Tile Scaling Data Access Object
 */
@interface GPKGTileScalingDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return dao
 */
+(GPKGTileScalingDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGTileScalingDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new tile scaling dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

@end
