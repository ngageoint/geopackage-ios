//
//  GPKGElevationTilesTiff.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesCore.h"

@interface GPKGElevationTilesTiff : GPKGElevationTilesCore

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
 * Get the pixel value as a float
 *
 * @param image
 *            tile image
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return float pixel value
 */
-(float) pixelValueWithImage: (UIImage *) image andX: (int) x andY: (int) y;

/**
 * Get the pixel values of the image as floats
 *
 * @param image
 *            tile image
 * @return float pixel values
 */
-(float *) pixelValuesWithImage: (UIImage *) image;

/**
 * Validate that the image type
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
 * Draw an elevation image tile from the flat array of float pixel values of
 * length tileWidth * tileHeight where each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile
 */
-(UIImage *) drawTileWithFloatPixelValues: (float *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation image tile from the flat array of float pixel values of
 * length tileWidth * tileHeight where each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile
 */
-(UIImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation image tile and format as TIFF bytes from the flat array
 * of float pixel values of length tileWidth * tileHeight where
 * each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw an elevation tile from the double array of float pixel
 * values formatted as float[row][width]
 *
 * @param pixelValues
 *            float pixel values as [row][width]
 * @return elevation image tile
 */
-(UIImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw an elevation tile and format as TIFF bytes from the double array of
 * float pixel values formatted as float[row][width]
 *
 * @param pixelValues
 *            float pixel values as [row][width]
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
 * Draw an elevation image tile and format as TIFF bytes from the flat array
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
 * Draw an elevation image tile from the double array of elevations
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
 * Draw an elevation image tile and format as TIFF bytes from the double
 * array of unsigned elevations formatted as Double[row][width]
 *
 * @param griddedTile
 *            gridded tile
 * @param elevations
 *            elevations as [row][width]
 * @return elevation image tile bytes
 */
-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayElevations: (NSArray *) elevations;

/**
 * Get the image as TIFF bytes
 *
 * @param image
 *            buffered image
 * @return image bytes
 */
-(NSData *) imageData: (UIImage *) image;

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
+(GPKGElevationTilesTiff *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

@end
