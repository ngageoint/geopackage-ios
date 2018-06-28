//
//  GPKGSimpleAttributesRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"
#import "GPKGSimpleAttributesTable.h"

/**
 * User Simple Attributes Row containing the values from a single result set row
 */
@interface GPKGSimpleAttributesRow : GPKGUserCustomRow

/**
 *  Initialize
 *
 *  @param table       simple attributes table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new simple attributes row
 */
-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table simple attributes table
 *
 *  @return new simple attributes row
 */
-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table;

/**
 *  Initialize
 *
 *  @param userCustomRow user custom row
 *
 *  @return new simple attributes row
 */
-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow;

/**
 *  Get the simple attributes table
 *
 *  @return simple attributes table
 */
-(GPKGSimpleAttributesTable *) table;

/**
 * Get the id column index
 *
 * @return id column index
 */
-(int) idColumnIndex;

/**
 * Get the id column
 *
 * @return id column
 */
-(GPKGUserCustomColumn *) idColumn;

/**
 * Get the id
 *
 * @return id
 */
-(int) id;

@end
