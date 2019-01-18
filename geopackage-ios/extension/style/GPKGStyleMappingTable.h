//
//  GPKGStyleMappingTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGUserMappingTable.h"

/**
 *  Style Mapping Table constants
 */
extern NSString * const GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME;

/**
 * Feature Style mapping table
 */
@interface GPKGStyleMappingTable : GPKGUserMappingTable

/**
 * Initializer
 *
 * @param tableName
 *            table name
 * @return new style mapping table
 */
-(instancetype) initWithTableName: (NSString *) tableName;

/**
 * Initializer
 *
 * @param table
 *            user custom table
 * @return new style mapping table
 */
-(instancetype) initWithTable: (GPKGUserCustomTable *) table;

/**
 * Get the geometry type name column index
 *
 * @return geometry type name column index
 */
-(int) geometryTypeNameColumnIndex;

/**
 * Get the geometry type name column
 *
 * @return geometry type name column
 */
-(GPKGUserCustomColumn *) geometryTypeNameColumn;

@end
