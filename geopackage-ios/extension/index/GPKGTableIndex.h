//
//  GPKGTableIndex.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Table Index table constants
 */
extern NSString * const GPKG_TI_TABLE_NAME;
extern NSString * const GPKG_TI_COLUMN_PK;
extern NSString * const GPKG_TI_COLUMN_TABLE_NAME;
extern NSString * const GPKG_TI_COLUMN_LAST_INDEXED;

/**
 * Table Index object, for indexing data within user tables
 */
@interface GPKGTableIndex : NSObject

/**
 *  Name of the table
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Last indexed date
 */
@property (nonatomic, strong) NSDate *lastIndexed;

@end
