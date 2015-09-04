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
 *  Tile Row containing the values from a single cursor row
 */
@interface GPKGTileRow : GPKGUserRow

/**
 *  Tile Table
 */
@property (nonatomic, strong) GPKGTileTable *tileTable;

/**
 *  Initialize
 *
 *  @param table       tile table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new tile row
 */
-(instancetype) initWithTileTable: (GPKGTileTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

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
-(int) getZoomLevelColumnIndex;

/**
 *  Get the zoom level column
 *
 *  @return zoom level column
 */
-(GPKGTileColumn *) getZoomLevelColumn;

/**
 *  Get the zoom level
 *
 *  @return zoom level
 */
-(int) getZoomLevel;

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
-(int) getTileColumnColumnIndex;

/**
 *  Get the tile column column
 *
 *  @return tile column column
 */
-(GPKGTileColumn *) getTileColumnColumn;

/**
 *  Get the tile column
 *
 *  @return tile column
 */
-(int) getTileColumn;

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
-(int) getTileRowColumnIndex;

/**
 *  Get the tile row column
 *
 *  @return tile row column
 */
-(GPKGTileColumn *) getTileRowColumn;

/**
 *  Get the tile row
 *
 *  @return tile row
 */
-(int) getTileRow;

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
-(int) getTileDataColumnIndex;

/**
 *  Get the tile data column
 *
 *  @return tile data column
 */
-(GPKGTileColumn *) getTileDataColumn;

/**
 *  Get the tile data
 *
 *  @return tile data
 */
-(NSData *) getTileData;

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
-(UIImage *) getTileDataImage;

/**
 *  Get the tile data as a scaled image
 *
 *  @param scale scale, 0.0 to 1.0
 *
 *  @return tile image
 */
-(UIImage *) getTileDataImageWithScale: (CGFloat) scale;

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
