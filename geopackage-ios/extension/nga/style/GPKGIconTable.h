//
//  GPKGIconTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGMediaTable.h"

/**
 *  Icon Table constants
 */
extern NSString * const GPKG_IT_TABLE_NAME;
extern NSString * const GPKG_IT_COLUMN_NAME;
extern NSString * const GPKG_IT_COLUMN_DESCRIPTION;
extern NSString * const GPKG_IT_COLUMN_WIDTH;
extern NSString * const GPKG_IT_COLUMN_HEIGHT;
extern NSString * const GPKG_IT_COLUMN_ANCHOR_U;
extern NSString * const GPKG_IT_COLUMN_ANCHOR_V;

/**
 * Icon Table
 */
@interface GPKGIconTable : GPKGMediaTable

/**
 * Initializer
 *
 * @return new icon table
 */
-(instancetype) init;

/**
 * Initializer
 *
 * @param table
 *            user custom table
 * @return new icon table
 */
-(instancetype) initWithTable: (GPKGUserCustomTable *) table;

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
-(GPKGUserCustomColumn *) nameColumn;

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
-(GPKGUserCustomColumn *) descriptionColumn;

/**
 * Get the width column index
 *
 * @return opacity column index
 */
-(int) widthColumnIndex;

/**
 * Get the width column
 *
 * @return width column
 */
-(GPKGUserCustomColumn *) widthColumn;

/**
 * Get the height column index
 *
 * @return height column index
 */
-(int) heightColumnIndex;

/**
 * Get the height column
 *
 * @return height column
 */
-(GPKGUserCustomColumn *) heightColumn;

/**
 * Get the anchor u column index
 *
 * @return anchor u column index
 */
-(int) anchorUColumnIndex;

/**
 * Get the anchor u column
 *
 * @return anchor u column
 */
-(GPKGUserCustomColumn *) anchorUColumn;

/**
 * Get the anchor v column index
 *
 * @return anchor v column index
 */
-(int) anchorVColumnIndex;

/**
 * Get the anchor v column
 *
 * @return anchor v column
 */
-(GPKGUserCustomColumn *) anchorVColumn;

@end
