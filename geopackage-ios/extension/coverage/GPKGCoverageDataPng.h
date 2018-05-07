//
//  CoverageDataPng.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageData.h"

/**
 * Tiled Gridded Coverage Data, PNG Encoding, Extension
 */
@interface GPKGCoverageDataPng : GPKGCoverageData

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *  @param width specified results width
 *  @param height specified results height
 *  @param requestProjection request projection
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (SFPProjection *) requestProjection;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *  @param requestProjection request projection
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (SFPProjection *) requestProjection;

/**
 * Get the pixel value as an unsigned short
 *
 * @param image
 *            tile image
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return unsigned short pixel value
 */
-(unsigned short) pixelValueWithImage: (UIImage *) image andX: (int) x andY: (int) y;

/**
 * Get the pixel value as an unsigned short
 *
 * @param imageData
 *            image data
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return unsigned short pixel value
 */
-(unsigned short) pixelValueWithData: (NSData *) imageData andX: (int) x andY: (int) y;

/**
 * Get the pixel values of the image as unsigned shorts
 *
 * @param image
 *            tile image
 * @return unsigned short pixel values
 */
-(unsigned short *) pixelValuesWithImage: (UIImage *) image;

/**
 * Get the pixel values of the image as unsigned shorts
 *
 * @param imageData
 *            image data
 * @return unsigned short pixel values
 */
-(unsigned short *) pixelValuesWithData: (NSData *) imageData;

/**
 * Validate that the image type is an unsigned short
 *
 * @param image
 *            tile image
 */
+(void) validateImageType: (UIImage *) image;

/**
 * Get the coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            tile image
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andImage: (UIImage *) image andX: (int) x andY: (int) y;

/**
 * Get the coverage data values
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            tile image
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andImage: (UIImage *) image;

/**
 * Draw a coverage data image tile from the flat array of unsigned short
 * pixel values of length tileWidth * tileHeight where each pixel is at: (y
 * * tileWidth) + x
 *
 * @param pixelValues
 *            unsigned short pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile
 */
-(UIImage *) drawTileWithUnsignedShortPixelValues: (unsigned short *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile from the flat array of unsigned short
 * pixel values of length tileWidth * tileHeight where each pixel is at: (y
 * * tileWidth) + x
 *
 * @param pixelValues
 *            unsigned short pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile
 */
-(UIImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile and format as PNG bytes from the flat array
 * of unsigned short pixel values of length tileWidth * tileHeight where
 * each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            unsigned short pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile bytes
 */
-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data tile from the double array of unsigned short pixel
 * values formatted as short[row][width]
 *
 * @param pixelValues
 *            unsigned short pixel values as [row][width]
 * @return coverage data image tile
 */
-(UIImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw a coverage data tile and format as PNG bytes from the double array of
 * "unsigned short" pixel values formatted as short[row][width]
 *
 * @param pixelValues
 *            "unsigned short" pixel values as [row][width]
 * @return coverage data image tile bytes
 */
-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw a coverage data image tile from the flat array of coverage data values of length
 * tileWidth * tileHeight where each value is at: (y * tileWidth) + x
 *
 * @param griddedTile
 *            gridded tile
 * @param values
 *            coverage data values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile
 */
-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile from the double array of coverage data values
 * formatted as Double[row][width]
 *
 * @param griddedTile
 *            gridded tile
 * @param values
 *            coverage data values as [row][width]
 * @return coverage data image tile
 */
-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values;

/**
 * Get the image as PNG bytes
 *
 * @param image
 *            buffered image
 * @return image bytes
 */
-(NSData *) imageData: (UIImage *) image;

/**
 * Get the pixel at the provided x and y with the image width
 *
 * @param pixels
 *            pixels array
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordintate
 * @return pixel value
 */
-(unsigned short) pixelIn: (unsigned short *) pixels withWidth: (int) width atX: (int) x andY: (int) y;

/**
 * Convert the unsigned short pixel array to a NSArray of numbers
 *
 * @param pixelValues
 *            pixels values
 * @param count
 *            pixel count
 * @return pixel array
 */
-(NSArray *) pixelValuesUnsignedShortToArray: (unsigned short *) pixelValues withCount: (int) count;

/**
 * Convert the pixel array to an unsigned short pixel array
 *
 * @param pixelValues
 *            pixels values
 * @return unsigned short pixel array
 */
-(unsigned short *) pixelValuesArrayToUnsignedShort: (NSArray *) pixelValues;

/**
 * Convert the pixel double array to an unsigned short pixel array
 *
 * @param pixelValues
 *            pixels values
 * @return unsigned short pixel array
 */
-(unsigned short *) pixelValuesDoubleArrayToUnsignedShort: (NSArray *) pixelValues;

/**
 * Convert the coverage data array to an unsigned short pixel array
 *
 * @param values
 *            coverage data values
 * @param griddedTile
 *            gridded tile
 * @return unsigned short pixel array
 */
-(unsigned short *) pixelValuesOfValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile;

/**
 * Convert the coverage data double array to an unsigned short pixel array
 *
 * @param values
 *            coverage data values
 * @param griddedTile
 *            gridded tile
 * @return unsigned short pixel array
 */
-(unsigned short *) pixelValuesOfDoubleArrayValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile;

/**
 * Create the coverage data tile table with metadata and extension
 *
 * @param geoPackage GeoPackage
 * @param tableName table name
 * @param contentsBoundingBox contents bounding box
 * @param contentsSrsId contents srs id
 * @param tileMatrixSetBoundingBox tile matrix set bounding box
 * @param tileMatrixSetSrsId tile matrix set srs id
 * @return coverage data tiles
 */
+(GPKGCoverageDataPng *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

@end
