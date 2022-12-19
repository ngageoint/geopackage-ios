//
//  GPKGTileScalingTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGNGATableCreator.h"

/**
 * Tile Scaling Extension Table Creator
 */
@interface GPKGTileScalingTableCreator : GPKGNGATableCreator

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new table scaling table creator
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Create Tile Scaling table
 *
 *  @return tables created
 */
-(int) createTileScaling;

@end
