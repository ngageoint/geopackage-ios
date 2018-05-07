//
//  GPKGCoverageDataTiff.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageData.h"
#import "TIFFFileDirectory.h"
#import "GPKGCoverageDataTiffImage.h"

/**
 * Tiled Gridded Coverage Data, TIFF Encoding, Extension
 */
@interface GPKGCoverageDataTiff : GPKGCoverageData

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
 * Get the pixel value as a float
 *
 * @param imageData
 *            image data
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return float pixel value
 */
-(float) pixelValueWithData: (NSData *) imageData andX: (int) x andY: (int) y;

/**
 * Get the pixel values of the image data as an array of decimal numbers
 *
 * @param imageData
 *            image data
 * @return pixel values array
 */
-(NSArray *) pixelArrayValuesWithData: (NSData *) imageData;

/**
 * Get the pixel values of the image data as floats
 *
 * @param imageData
 *            image data
 * @return float pixel values
 */
-(float *) pixelValuesWithData: (NSData *) imageData;

/**
 * Validate the image type
 *
 * @param directory file directory
 */
+(void) validateImageType: (TIFFFileDirectory *) directory;

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
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y;

/**
 * Draw a coverage data image tile from the flat array of float pixel values of
 * length tileWidth * tileHeight where each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile
 */
-(GPKGCoverageDataTiffImage *) drawTileWithFloatPixelValues: (float *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile from the flat array of float pixel values of
 * length tileWidth * tileHeight where each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile
 */
-(GPKGCoverageDataTiffImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile and format as TIFF bytes from the flat array
 * of float pixel values of length tileWidth * tileHeight where
 * each pixel is at: (y * tileWidth) + x
 *
 * @param pixelValues
 *            float pixel values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile bytes
 */
-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data tile from the double array of float pixel
 * values formatted as float[row][width]
 *
 * @param pixelValues
 *            float pixel values as [row][width]
 * @return coverage data image tile
 */
-(GPKGCoverageDataTiffImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues;

/**
 * Draw a coverage data tile and format as TIFF bytes from the double array of
 * float pixel values formatted as float[row][width]
 *
 * @param pixelValues
 *            float pixel values as [row][width]
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
-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

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
-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values;

/**
 * Create a new image
 *
 * @param tileWidth  tile width
 * @param tileHeight tile height
 * @return image
 */
-(GPKGCoverageDataTiffImage *) createImageWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Set the pixel value into the image
 *
 * @param image      image
 * @param x          x coordinate
 * @param y          y coordinate
 * @param pixelValue pixel value
 */
-(void) setPixelValueWithImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y andPixelValue: (float) pixelValue;

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
-(float) pixelIn: (float *) pixels withWidth: (int) width atX: (int) x andY: (int) y;

/**
 * Convert the float pixel array to a NSArray of numbers
 *
 * @param pixelValues
 *            pixels values
 * @param count
 *            pixel count
 * @return pixel array
 */
-(NSArray *) pixelValuesFloatToArray: (float *) pixelValues withCount: (int) count;

/**
 * Convert the pixel array to a float pixel array
 *
 * @param pixelValues
 *            pixels values
 * @return float pixel array
 */
-(float *) pixelValuesArrayToFloat: (NSArray *) pixelValues;

/**
 * Convert the pixel double array to a float pixel array
 *
 * @param pixelValues
 *            pixels values
 * @return float pixel array
 */
-(float *) pixelValuesDoubleArrayToFloat: (NSArray *) pixelValues;

/**
 * Convert the coverage data array to a float pixel array
 *
 * @param values
 *            coverage data values
 * @param griddedTile
 *            gridded tile
 * @return float pixel array
 */
-(float *) pixelValuesOfValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile;

/**
 * Convert the coverage data values double array to a float pixel array
 *
 * @param values
 *            coverage data values
 * @param griddedTile
 *            gridded tile
 * @return float pixel array
 */
-(float *) pixelValuesOfDoubleArrayValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile;

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
+(GPKGCoverageDataTiff *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

@end
