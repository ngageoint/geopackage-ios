//
//  GPKGAttributesDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGAttributesRow.h"
#import "GPKGAttributesTable.h"

/**
 * Attributes DAO for reading attributes user data tables
 */
@interface GPKGAttributesDao : GPKGUserDao

/**
 * Constructor
 *
 * @param database        database connection
 * @param table           feature table
 * @return new attributes dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGAttributesTable *) table;

/**
 *  Get the attributes table
 *
 *  @return attributes table
 */
-(GPKGAttributesTable *) getAttributesTable;

/**
 *  Get the attributes row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) getAttributesRow: (GPKGResultSet *) results;

/**
 *  Create a new attributes row with the column types and values
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return attributes row as user row
 */
-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Create a new attributes row
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) newRow;

@end
