//
//  GPKGAttributesRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import "GPKGAttributesTable.h"

/**
 * Attributes Row containing the values from a single cursor row
 */
@interface GPKGAttributesRow : GPKGUserRow

/**
 *  Attributes Table
 */
@property (nonatomic, strong) GPKGAttributesTable *attributesTable;

/**
 *  Initialize
 *
 *  @param table       attributes table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new attributes row
 */
-(instancetype) initWithAttributesTable: (GPKGAttributesTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table attributes table
 *
 *  @return new attributes row
 */
-(instancetype) initWithAttributesTable: (GPKGAttributesTable *) table;

@end
