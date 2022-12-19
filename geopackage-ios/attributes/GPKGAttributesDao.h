//
//  GPKGAttributesDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGAttributesRow.h"

/**
 * Attributes DAO for reading attributes user data tables
 */
@interface GPKGAttributesDao : GPKGUserDao

/**
 * Initialize
 *
 * @param database        database connection
 * @param table           attributes table
 * @return new attributes dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGAttributesTable *) table;

/**
 *  Get the attributes table
 *
 *  @return attributes table
 */
-(GPKGAttributesTable *) attributesTable;

/**
 *  Get the attributes row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) row: (GPKGResultSet *) results;

/**
 *  Get the attributes row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) attributesRow: (GPKGResultSet *) results;

/**
 *  Get the attributes row for the row
 *
 *  @param row result row
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) rowWithRow: (GPKGRow *) row;

/**
 *  Create a new attributes row
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) newRow;

@end
