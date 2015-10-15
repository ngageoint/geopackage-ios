//
//  GPKGUserDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGUserTable.h"
#import "GPKGUserRow.h"
#import "GPKGBoundingBox.h"

/**
 *  Abstract User DAO for reading user tables
 */
@interface GPKGUserDao : GPKGBaseDao

/**
 *  User table
 */
@property (nonatomic, strong) GPKGUserTable * table;

/**
 *  Projection
 */
@property (nonatomic, strong) GPKGProjection * projection;

/**
 *  Initialize
 *
 *  @param database database connection
 *  @param table    user table
 *
 *  @return new user dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table;

/**
 *  Get a user row from the current result
 *
 *  @param results result set
 *
 *  @return user row
 */
-(GPKGUserRow *) getRow: (GPKGResultSet *) results;

/**
 *  Create a user row
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return user row
 */
-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Get the bounding box of the user table data
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) getBoundingBox;

/**
 *  Get the approximate zoom level of where the bounding box of the user data fits into the world
 *
 *  @return zoom level
 */
-(int) getZoomLevel;

@end
