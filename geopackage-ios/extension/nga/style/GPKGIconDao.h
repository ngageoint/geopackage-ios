//
//  GPKGIconDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGMediaDao.h"
#import "GPKGIconTable.h"
#import "GPKGIconRow.h"
#import "GPKGStyleMappingRow.h"

/**
 * Icon DAO for reading icon tables
 */
@interface GPKGIconDao : GPKGMediaDao

/**
 *  Initialize
 *
 *  @param dao      user custom data access object
 *
 *  @return new icon dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 *  Get the icon table
 *
 *  @return icon table
 */
-(GPKGIconTable *) iconTable;

/**
 *  Get the icon row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return icon row
 */
-(GPKGIconRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new icon row
 *
 *  @return icon row
 */
-(GPKGIconRow *) newRow;

/**
 * Get the icon rows that exist with the provided ids
 *
 * @param ids
 *            list of ids
 * @return icon rows
 */
-(NSArray<GPKGIconRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids;

/**
 * Query for the icon row from a style mapping row
 *
 * @param styleMappingRow style mapping row
 * @return icon row
 */
-(GPKGIconRow *) queryForRow: (GPKGStyleMappingRow *) styleMappingRow;

@end
