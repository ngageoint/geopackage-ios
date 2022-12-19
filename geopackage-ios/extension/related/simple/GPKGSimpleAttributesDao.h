//
//  GPKGSimpleAttributesDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomDao.h"
#import "GPKGSimpleAttributesRow.h"

/**
 * User Simple Attributes DAO for reading user simple attributes data tables
 */
@interface GPKGSimpleAttributesDao : GPKGUserCustomDao

/**
 *  Initialize
 *
 *  @param dao      user custom data access object
 *
 *  @return new simple attributes dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 *  Initialize
 *
 *  @param dao                   user custom data access object
 *  @param simpleAttributesTable simple attributes table
 *
 *  @return new simple attributes dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGSimpleAttributesTable *) simpleAttributesTable;

/**
 *  Get the simple attributes table
 *
 *  @return simple attributes table
 */
-(GPKGSimpleAttributesTable *) simpleAttributesTable;

/**
 *  Get the simple attributes row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return simple attributes row
 */
-(GPKGSimpleAttributesRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new simple attributes row
 *
 *  @return simple attributes row
 */
-(GPKGSimpleAttributesRow *) newRow;

/**
 * Get the simple attributes rows that exist with the provided ids
 *
 * @param ids
 *            list of ids
 * @return simple attributes rows
 */
-(NSArray<GPKGSimpleAttributesRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids;

@end
