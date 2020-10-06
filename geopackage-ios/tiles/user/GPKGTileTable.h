//
//  GPKGTileTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGTileColumn.h"
#import "GPKGTileColumns.h"

/**
 *  Represents a user tile table
 */
@interface GPKGTileTable : GPKGUserTable

/**
 * Initialize
 *
 * @param tableName
 *            table name
 *
 *  @return new tile table
 */
-(instancetype) initWithTable: (NSString *) tableName;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   columns
 *
 *  @return new tile table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 * Get the zoom level column index
 *
 * @return zoom level index
 */
-(int) zoomLevelIndex;

/**
 *  Get the zoom level column
 *
 *  @return zoom level tile column
 */
-(GPKGTileColumn *) zoomLevelColumn;

/**
 *  Get the tile column index
 *
 *  @return tile column index
 */
-(int) tileColumnIndex;

/**
 *  Get the tile column column
 *
 *  @return tile column column
 */
-(GPKGTileColumn *) tileColumnColumn;

/**
 *  Get the tile row index
 *
 *  @return tile row index
 */
-(int) tileRowIndex;

/**
 *  Get the tile row column
 *
 *  @return tile row column
 */
-(GPKGTileColumn *) tileRowColumn;

/**
 *  Get the tile data index
 *
 *  @return tile data index
 */
-(int) tileDataIndex;

/**
 *  Get the tile data column
 *
 *  @return tile data column
 */
-(GPKGTileColumn *) tileDataColumn;

/**
 *  Create the required table columns
 *
 *  @return columns
 */
+(NSArray *) createRequiredColumns;

/**
 * Create the required table columns
 *
 * @param autoincrement
 *            autoincrement id values
 *
 * @return tile columns
 */
+(NSArray *) createRequiredColumnsWithAutoincrement: (BOOL) autoincrement;

/**
 *  Create the required table columns, starting at the provided index
 *
 *  @param startingIndex starting column index
 *
 *  @return columns
 */
+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex;

/**
 * Create the required table columns, starting at the provided index
 *
 * @param startingIndex
 *            starting index
 * @param autoincrement
 *            autoincrement id values
 * @return tile columns
 */
+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex andAutoincrement: (BOOL) autoincrement;

/**
 * Get the tile columns
 *
 * @return columns
 */
-(GPKGTileColumns *) tileColumns;

@end
