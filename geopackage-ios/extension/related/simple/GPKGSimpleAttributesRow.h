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
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new simple attributes row
 */
-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table simple attributes table
 *
 *  @return new simple attributes row
 */
-(instancetype) initWithSimpleAttributesTable: (GPKGSimpleAttributesTable *) table;

/**
 *  Get the simple attributes table
 *
 *  @return simple attributes table
 */
-(GPKGSimpleAttributesTable *) simpleAttributesTable;

@end
