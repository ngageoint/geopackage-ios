//
//  GPKGMediaDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomDao.h"
#import "GPKGMediaTable.h"
#import "GPKGMediaRow.h"

/**
 * User Media DAO for reading user media data tables
 */
@interface GPKGMediaDao : GPKGUserCustomDao

/**
 *  Initialize
 *
 *  @param dao      user custom data access object
 *
 *  @return new media dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 *  Initialize
 *
 *  @param dao        user custom data access object
 *  @param mediaTable media table
 *
 *  @return new media dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGMediaTable *) mediaTable;

/**
 *  Get the media table
 *
 *  @return media table
 */
-(GPKGMediaTable *) table;

/**
 *  Get the media row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return media row
 */
-(GPKGMediaRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new media row with the column types and values
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return media row as user row
 */
-(GPKGMediaRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Create a new media row
 *
 *  @return media row
 */
-(GPKGMediaRow *) newRow;

/**
 * Get the media rows that exist with the provided ids
 *
 * @param ids
 *            list of ids
 * @return media rows
 */
-(NSArray<GPKGMediaRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids;

@end
