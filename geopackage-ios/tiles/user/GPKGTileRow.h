//
//  GPKGTileRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import "GPKGTileTable.h"
#import "GPKGTileColumn.h"
#import <UIKit/UIKit.h>
#import "GPKGCompressFormats.h"

/**
 *  Tile Row containing the values from a single results row
 */
@interface GPKGTileRow : GPKGUserRow

/**
 *  Tile Table
 */
@property (nonatomic, strong) GPKGTileTable *tileTable;

/**
 *  Tile Columns
 */
@property (nonatomic, strong) GPKGTileColumns *tileColumns;

/**
 *  Initialize
 *
 *  @param table       tile table
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new tile row
 */
-(instancetype) initWithTileTable: (GPKGTileTable *) table andColumns: (GPKGTileColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table tile table
 *
 *  @return new tile row
 */
-(instancetype) initWithTileTable: (GPKGTileTable *) table;

/**
 *  Get the zoom level column index
 *
 *  @return zoom level column index
 */
-(int) zoomLevelColumnIndex;

/**
 *  Get the zoom level column
 *
 *  @return zoom level column
 */
-(GPKGTileColumn *) zoomLevelColumn;

/**
 *  Get the zoom level
 *
 *  @return zoom level
 */
-(int) zoomLevel;

/**
 *  Set the zoom level
 *
 *  @param zoomLevel zoom level
 */
-(void) setZoomLevel: (int) zoomLevel;

/**
 *  Get the tile column column index
 *
 *  @return tile column column index
 */
-(int) tileColumnColumnIndex;

/**
 *  Get the tile column column
 *
 *  @return tile column column
 */
-(GPKGTileColumn *) tileColumnColumn;

/**
 *  Get the tile column
 *
 *  @return tile column
 */
-(int) tileColumn;

/**
 *  Set the tile column
 *
 *  @param tileColumn tile column
 */
-(void) setTileColumn: (int) tileColumn;

/**
 *  Get the tile row column index
 *
 *  @return tile row column index
 */
-(int) tileRowColumnIndex;

/**
 *  Get the tile row column
 *
 *  @return tile row column
 */
-(GPKGTileColumn *) tileRowColumn;

/**
 *  Get the tile row
 *
 *  @return tile row
 */
-(int) tileRow;

/**
 *  Set the tile row
 *
 *  @param tileRow tile row
 */
-(void) setTileRow: (int) tileRow;

/**
 *  Get the tile data column index
 *
 *  @return tile data column index
 */
-(int) tileDataColumnIndex;

/**
 *  Get the tile data column
 *
 *  @return tile data column
 */
-(GPKGTileColumn *) tileDataColumn;

/**
 *  Get the tile data
 *
 *  @return tile data
 */
-(NSData *) tileData;

/**
 *  Set the tile data
 *
 *  @param tileData tile data
 */
-(void) setTileData: (NSData *) tileData;

/**
 *  Get the tile data as an image
 *
 *  @return tile image
 */
-(UIImage *) tileDataImage;

/**
 *  Get the tile data as a scaled image
 *
 *  @param scale scale, 0.0 to 1.0
 *
 *  @return tile image
 */
-(UIImage *) tileDataImageWithScale: (CGFloat) scale;

/**
 *  Set the tile data with an image
 *
 *  @param image  image
 *  @param format image format
 */
-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format;

/**
 *  Set the tile data with an image
 *
 *  @param image  image
 *  @param format image format
 *  @param quality compression quality, 0.0 to 1.0, used only for GPKG_CF_JPEG
 */
-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality;

@end
