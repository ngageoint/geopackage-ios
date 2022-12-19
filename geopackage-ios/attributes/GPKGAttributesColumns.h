//
//  GPKGAttributesColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"

/**
 * Collection of attributes columns
*/
@interface GPKGAttributesColumns : GPKGUserColumns

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *
 *  @return new attributes columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *
 *  @return new attributes columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param attributesColumns
 *            attributes columns
 *
 *  @return new attributes columns
 */
-(instancetype) initWithAttributesColumns: (GPKGAttributesColumns *) attributesColumns;

@end
