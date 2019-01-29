//
//  GPKGStyleDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAttributesDao.h"
#import "GPKGStyleTable.h"
#import "GPKGStyleRow.h"
#import "GPKGStyleMappingRow.h"

/**
 * Style DAO for reading style tables
 */
@interface GPKGStyleDao : GPKGAttributesDao

/**
 *  Initialize
 *
 *  @param dao      attributes data access object
 *
 *  @return new style dao
 */
-(instancetype) initWithDao: (GPKGAttributesDao *) dao;

/**
 *  Get the style table
 *
 *  @return style table
 */
-(GPKGStyleTable *) table;

/**
 *  Get the style row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return style row
 */
-(GPKGStyleRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new style row
 *
 *  @return style row
 */
-(GPKGStyleRow *) newRow;

/**
 * Query for the style row from a style mapping row
 *
 * @param styleMappingRow style mapping row
 * @return style row
 */
-(GPKGStyleRow *) queryForRow: (GPKGStyleMappingRow *) styleMappingRow;

@end
