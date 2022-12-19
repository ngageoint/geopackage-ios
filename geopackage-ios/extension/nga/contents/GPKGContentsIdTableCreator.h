//
//  GPKGContentsIdTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGNGATableCreator.h"

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
 * Create Contents Id table
 *
 * @return executed statements
 */
-(int) createContentsId;

@end
