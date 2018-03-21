//
//  GPKGTileScalingDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileScaling.h"

@interface GPKGTileScalingDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new tile scaling dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

@end
