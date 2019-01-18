//
//  GPKGStyleTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAttributesTable.h"
#import "GPKGAttributesColumn.h"

/**
 *  Style Table constants
 */
extern NSString * const GPKG_ST_TABLE_NAME;
extern NSString * const GPKG_ST_COLUMN_ID;
extern NSString * const GPKG_ST_COLUMN_NAME;
extern NSString * const GPKG_ST_COLUMN_DESCRIPTION;
extern NSString * const GPKG_ST_COLUMN_COLOR;
extern NSString * const GPKG_ST_COLUMN_OPACITY;
extern NSString * const GPKG_ST_COLUMN_WIDTH;
extern NSString * const GPKG_ST_COLUMN_FILL_COLOR;
extern NSString * const GPKG_ST_COLUMN_FILL_OPACITY;

/**
 * Style Table
 */
@interface GPKGStyleTable : GPKGAttributesTable

/**
 * Initializer
 *
 * @return new style table
 */
-(instancetype) init;

/**
 * Initializer
 *
 * @param table
 *            attributes table
 * @return new style table
 */
-(instancetype) initWithTable: (GPKGAttributesTable *) table;

/**
 * Get the name column index
 *
 * @return name column index
 */
-(int) nameColumnIndex;

/**
 * Get the name column
 *
 * @return name column
 */
-(GPKGAttributesColumn *) nameColumn;

/**
 * Get the description column index
 *
 * @return description column index
 */
-(int) descriptionColumnIndex;

/**
 * Get the description column
 *
 * @return description column
 */
-(GPKGAttributesColumn *) descriptionColumn;

/**
 * Get the color column index
 *
 * @return color column index
 */
-(int) colorColumnIndex;

/**
 * Get the color column
 *
 * @return color column
 */
-(GPKGAttributesColumn *) colorColumn;

/**
 * Get the opacity column index
 *
 * @return opacity column index
 */
-(int) opacityColumnIndex;

/**
 * Get the opacity column
 *
 * @return opacity column
 */
-(GPKGAttributesColumn *) opacityColumn;

/**
 * Get the width column index
 *
 * @return width column index
 */
-(int) widthColumnIndex;

/**
 * Get the width column
 *
 * @return width column
 */
-(GPKGAttributesColumn *) widthColumn;

/**
 * Get the fill color column index
 *
 * @return fill color column index
 */
-(int) fillColorColumnIndex;

/**
 * Get the fill color column
 *
 * @return fill color column
 */
-(GPKGAttributesColumn *) fillColorColumn;

/**
 * Get the fill opacity column index
 *
 * @return fill opacity column index
 */
-(int) fillOpacityColumnIndex;

/**
 * Get the fill opacity column
 *
 * @return fill opacity column
 */
-(GPKGAttributesColumn *) fillOpacityColumn;

@end
