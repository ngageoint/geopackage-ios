//
//  GPKGAttributesTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGAttributesColumn.h"

@interface GPKGAttributesTable : GPKGUserTable

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   attributes columns
 *
 *  @return new attributes table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 * Get the list of attributes columns
 *
 * @return columns
 */
-(NSArray<GPKGAttributesColumn *> *) attributesColumns;

@end
