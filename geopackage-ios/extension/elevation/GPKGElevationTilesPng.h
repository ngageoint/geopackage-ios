//
//  GPKGElevationTilesPng.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesCore.h"

@interface GPKGElevationTilesPng : GPKGElevationTilesCore

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
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection;

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
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (GPKGProjection *) requestProjection;

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
 * Get the pixel values of the image as unsigned shorts
 *
 * @param image
 *            tile image
 * @return unsigned short pixel values
 */
-(NSArray *) pixelValuesWithImage: (UIImage *) image;

/**
 * Validate that the image type is an unsigned short
 *
 * @param image
 *            tile image
 */
-(void) validateImageType: (UIImage *) image;

/**
 * Get the elevation value
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            tile image
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return elevation value
 */
-(NSDecimalNumber *) elevationValueWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image andX:(int)x andY:(int)y;

/**
 * Get the elevation values
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            tile image
 * @return elevation values
 */
-(NSArray *) elevationValuesWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image;

/**
 * Draw an elevation image tile from the flat array of unsigned short
 * pixel values of length tileWidth * tileHeight where each pixel is at: (y
 * * tileWidth) + x
 *
 * @param pixelValues
 *            unsigned short pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile
 */
-(UIImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation image tile and format as PNG bytes from the flat array
 * of unsigned short pixel values of length tileWidth * tileHeight where
 * each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            unsigned short pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation tile from the double array of unsigned short pixel
 * values formatted as short[row][width]
 *
 * @param pixelValues
 *            unsigned short pixel values as [row][width]
 * @return elevation image tile
 */
-(UIImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw an elevation tile and format as PNG bytes from the double array of
 * "unsigned short" pixel values formatted as short[row][width]
 *
 * @param pixelValues
 *            "unsigned short" pixel values as [row][width]
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw an elevation image tile from the flat array of elevations of length
 * tileWidth * tileHeight where each elevation is at: (y * tileWidth) + x
 *
 * @param griddedTile
 *            gridded tile
 * @param elevations
 *            elevations of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile
 */
-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation image tile and format as PNG bytes from the flat array
 * of elevations of length tileWidth * tileHeight where each elevation is
 * at: (y * tileWidth) + x
 *
 * @param griddedTile
 *            gridded tile
 * @param elevations
 *            elevations of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation image tile from the double array of unsigned elevations
 * formatted as Double[row][width]
 *
 * @param griddedTile
 *            gridded tile
 * @param elevations
 *            elevations as [row][width]
 * @return elevation image tile
 */
-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayElevations: (NSArray *) elevations;

/**
 * Draw an elevation image tile and format as PNG bytes from the double
 * array of unsigned elevations formatted as Double[row][width]
 *
 * @param griddedTile
 *            gridded tile
 * @param elevations
 *            elevations as [row][width]
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations;

/**
 * Create a new unsigned 16 bit short grayscale image
 *
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return image
 */
-(UIImage *) createImageWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Get the image as PNG bytes
 *
 * @param image
 *            buffered image
 * @return image bytes
 */
-(NSData *) imageData: (UIImage *) image;

// TODO setPixel method?

/**
 * Create the elevation tile table with metadata and extension
 *
 * @param geoPackage
 * @param tableName
 * @param contentsBoundingBox
 * @param contentsSrsId
 * @param tileMatrixSetBoundingBox
 * @param tileMatrixSetSrsId
 * @return elevation tiles
 */
+(GPKGElevationTilesPng *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

@end
