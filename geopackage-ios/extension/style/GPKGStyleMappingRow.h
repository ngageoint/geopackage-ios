//
//  GPKGStyleMappingRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGUserMappingRow.h"
#import "GPKGStyleMappingTable.h"

/**
 * Style Mapping Row containing the values from a single result set row
 */
@interface GPKGStyleMappingRow : GPKGUserMappingRow

/**
 *  Initialize
 *
 *  @param table       style mapping table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new style mapping row
 */
-(instancetype) initWithStyleMappingTable: (GPKGStyleMappingTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table style mapping table
 *
 *  @return new style mapping row
 */
-(instancetype) initWithStyleMappingTable: (GPKGStyleMappingTable *) table;

/**
 *  Get the style mapping table
 *
 *  @return style mapping table
 */
-(GPKGStyleMappingTable *) table;

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

/**
 * Get the geometry type name
 *
 * @return geometry type name
 */
-(NSString *) geometryTypeName;

/**
 * Get the geometry type
 *
 * @return geometry type
 */
-(enum SFGeometryType) geometryType;

/**
 * Set the geometry type
 *
 * @param geometryType geometry type
 */
-(void) setGeometryType: (enum SFGeometryType) geometryType;

@end
