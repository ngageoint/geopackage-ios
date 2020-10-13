//
//  GPKGCoverageData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGGriddedCoverageDao.h"
#import "GPKGTileDao.h"
#import "GPKGCoverageDataImage.h"
#import "GPKGCoverageDataRequest.h"
#import "GPKGCoverageDataResults.h"
#import "GPKGGriddedCoverageEncodingTypes.h"
#import "GPKGGriddedTileDao.h"

extern NSString * const GPKG_CD_GRIDDED_COVERAGE;
extern NSString * const GPKG_GRIDDED_COVERAGE_EXTENSION_NAME;

/**
 *  Tiled Gridded Coverage Data, Common Encoding, Extension
 *
 *  http://docs.opengeospatial.org/is/17-066r1/17-066r1.html
 */
@interface GPKGCoverageData : GPKGBaseExtension

/**
 * Get a Tiled Gridded Coverage Data
 *
 * @param geoPackage        GeoPackage
 * @param tileDao           tile dao
 * @param width             coverage data response width
 * @param height            coverage data response height
 * @param requestProjection request projection
 */
+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (SFPProjection *) requestProjection;

/**
 * Get a Tiled Gridded Coverage Data, use the coverage data pixel tile size
 * as the request size width and height
 *
 * @param geoPackage GeoPackage
 * @param tileDao    tile dao
 */
+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao;

/**
 * Get a Tiled Gridded Coverage Data, use the coverage data pixel tile size
 * as the request size width and height, request as the specified projection
 *
 * @param geoPackage        GeoPackage
 * @param tileDao           tile dao
 * @param requestProjection request projection
 */
+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (SFPProjection *) requestProjection;

/**
 * Create the coverage data tile table with metadata and extension
 *
 * @param geoPackage GeoPackage
 * @param metadata   tile table metadata
 * @param dataType   gridded coverage data type
 * @return coverage data
 */
+(GPKGCoverageData *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGTileTableMetadata *) metadata andDataType: (enum GPKGGriddedCoverageDataType) dataType;

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension definition URL
 */
@property (nonatomic, strong) NSString *definition;

/**
 * Coverage Data results width
 */
@property (nonatomic, strong) NSNumber *width;

/**
 * Coverage Data results height
 */
@property (nonatomic, strong) NSNumber *height;

/**
 * True if zooming in should be performed to find a tile matrix with
 * coverage data values
 */
@property (nonatomic) BOOL zoomIn;

/**
 * True if zooming out should be performed to find a tile matrix with
 * coverage data values
 */
@property (nonatomic) BOOL zoomOut;

/**
 * True if zoom in in before zooming out, false to zoom out first
 */
@property (nonatomic) BOOL zoomInBeforeOut;

/**
 * Interpolation algorithm
 */
@property (nonatomic) enum GPKGCoverageDataAlgorithm algorithm;

/**
 * Value pixel encoding type
 */
@property (nonatomic) enum GPKGGriddedCoverageEncodingType encoding;

/**
 * Tile DAO
 */
@property (nonatomic, strong) GPKGTileDao *tileDao;

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
 *  Get the tile matrix set
 *
 *  @return tile matrix set
 */
-(GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get the gridded coverage dao
 *
 *  @return gridded coverage dao
 */
-(GPKGGriddedCoverageDao *) griddedCoverageDao;

/**
 *  Get the gridded tile dao
 *
 *  @return gridded tile dao
 */
-(GPKGGriddedTileDao *) griddedTileDao;

/**
 * Get the request projection
 *
 * @return request projection
 */
-(SFPProjection *) requestProjection;

/**
 * Get the coverage data projection
 *
 * @return coverage data projection
 */
-(SFPProjection *) coverageProjection;

/**
 * Get the coverage data bounding box
 *
 * @return coverage data bounding box
 */
-(GPKGBoundingBox *) coverageBoundingBox;

/**
 * Is the request and coverage data projection the same
 *
 * @return true if the same
 */
-(BOOL) isSameProjection;

/**
 *  Get or create the extension
 *
 *  @return extensions array
 */
-(NSArray *) extensionCreate;

/**
 * Determine if the Tile Matrix Set has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Get a 2D Gridded Coverage DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return 2d gridded coverage dao
 */
+(GPKGGriddedCoverageDao *) griddedCoverageDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a 2D Gridded Coverage DAO
 *
 * @param db
 *            database connection
 * @return 2d gridded coverage dao
 */
+(GPKGGriddedCoverageDao *) griddedCoverageDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the 2D Gridded Coverage Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createGriddedCoverageTable;

/**
 * Get a 2D Gridded Tile DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return 2d gridded tile dao
 */
+(GPKGGriddedTileDao *) griddedTileDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a 2D Gridded Tile DAO
 *
 * @param db
 *            database connection
 * @return 2d gridded tile dao
 */
+(GPKGGriddedTileDao *) griddedTileDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the 2D Gridded Tile Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createGriddedTileTable;

/**
 * Get the gridded coverage
 *
 * @return gridded coverage
 */
-(GPKGGriddedCoverage *) griddedCoverage;

/**
 *  Query and update the gridded coverage
 *
 *  @return gridded coverage
 */
-(GPKGGriddedCoverage *) queryGriddedCoverage;

/**
 * Get the gridded tile
 *
 * @return gridded tile result set
 */
-(GPKGResultSet *) griddedTile;

/**
 * Get the current gridded tile in the result set
 *
 * @param resultSet gridded tile result set
 *
 * @return gridded tile
 */
-(GPKGGriddedTile *) griddedTileWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the gridded tile by id
 *
 * @param tileId
 *            tile id
 * @return gridded tile
 */
-(GPKGGriddedTile *) griddedTileWithTileId: (int) tileId;

/**
 * Get the data null value
 *
 * @return data null value or null
 */
-(NSDecimalNumber *) dataNull;

/**
 * Check the pixel value to see if it is the null equivalent
 *
 * @param value
 *            pixel value
 * @return true if equivalent to data null
 */
-(BOOL) isDataNull: (double) value;

/**
 * Get the coverage data tile tables
 *
 * @param geoPackage
 *            GeoPackage
 * @return table names
 */
+(NSArray *) tablesForGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the pixel value as an unsigned short at the coordinate from the
 * unsigned short pixel values
 *
 * @param pixelValues
 *            unsigned short pixel values
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return unsigned short pixel value
 */
-(unsigned short) pixelValueWithValues:(NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y;

/**
 * Get the pixel value as an unsigned short at the coordinate from the
 * unsigned short pixel values
 *
 * @param pixelValues
 *            unsigned short pixel values
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return unsigned short pixel value
 */
-(unsigned short) pixelValueWithUnsignedShortValues:(unsigned short *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y;

/**
 * Get the coverage data value for the unsigned short pixel value
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValue
 *            pixel value as an unsigned short
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (unsigned short) pixelValue;

/**
 * Get the coverage data values from the unsigned short pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values as "unsigned shorts"
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (NSArray *) pixelValues;

/**
 * Get the coverage data values from the unsigned short pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values as unsigned shorts
 * @param count
 *            pixel count
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (unsigned short *) pixelValues andCount: (int) count;

/**
 * Create the coverage data tile table
 *
 * @param geoPackage
 *            GeoPackage
 * @param metadata
 *            tile table metadata
 * @return tile table
 */
+(GPKGTileTable *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGTileTableMetadata *) metadata;

/**
 * Get the unsigned short pixel value of the coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param value
 *            coverage data value
 * @return unsigned short pixel value
 */
-(unsigned short) pixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andValue: (NSDecimalNumber *) value;

/**
 * Get the pixel value at the coordinate from the pixel values
 *
 * @param pixelValues
 *            pixel values
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return pixel value
 */
-(float) pixelValueWithFloatValues: (NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y;

/**
 * Get the pixel value at the coordinate from the pixel values
 *
 * @param pixelValues
 *            pixel values
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return pixel value
 */
-(float) pixelValueWithRawFloatValues: (float *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y;

/**
 * Get the coverage data value for the pixel value
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValue
 *            pixel value
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValue: (float) pixelValue;

/**
 * Get the coverage data values from the pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (NSArray *) pixelValues;

/**
 * Get the coverage data values from the pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values as floats
 * @param count
 *            pixel count
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (float *) pixelValues andCount: (int) count;

/**
 * Get the pixel value of the coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param value
 *            coverage data value
 * @return pixel value
 */
-(float) floatPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andValue: (NSDecimalNumber *) value;

/**
 * Create a coverage data image
 *
 * @param tileRow
 *            tile row
 * @return coverage data image
 */
-(NSObject<GPKGCoverageDataImage> *) createImageWithTileRow: (GPKGTileRow *) tileRow;

/**
 * Get the coverage data value of the pixel in the tile row image
 *
 * @param griddedTile
 *            gridded tile
 * @param tileRow
 *            tile row
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(double) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y;

/**
 * Get the coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param imageData
 *            image data
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData andX: (int) x andY: (int) y;

/**
 * Get the coverage data values
 *
 * @param griddedTile
 *            gridded tile
 * @param imageData
 *            image data
 * @return coverage data values
 */
-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData;

/**
 * Draw a coverage data image tile and format as PNG bytes from the flat
 * array of coverage data values of length tileWidth * tileHeight where each
 * coverage data value is at: (y * tileWidth) + x
 *
 * @param griddedTile
 *            gridded tile
 * @param values
 *            coverage data values of length tileWidth * tileHeight
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @return coverage data image tile data
 */
-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight;

/**
 * Draw a coverage data image tile and format as bytes from the double
 * array of unsigned coverage data values formatted as Double[row][width]
 *
 * @param griddedTile
 *            gridded tile
 * @param values
 *            coverage data values as [row][width]
 * @return coverage data image tile data
 */
-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values;

/**
 * Get the coverage data value from the image at the coordinate
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            coverage data image
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andX: (int) x andY: (int) y;

/**
 * Get the tile dao
 *
 * @return tile dao
 */
-(GPKGTileDao *) tileDao;

/**
 * Get the coverage data value at the coordinate
 *
 * @param latitude
 *            latitude
 * @param longitude
 *            longitude
 * @return coverage data value
 */
-(NSDecimalNumber *) valueWithLatitude: (double) latitude andLongitude: (double) longitude;

/**
 * Get the coverage data values within the bounding box
 *
 * @param requestBoundingBox
 *            request bounding box
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox;

/**
 * Get the coverage data values within the bounding box with the requested width
 * and height result size
 *
 * @param requestBoundingBox
 *            request bounding box
 * @param width
 *            coverage data request width
 * @param height
 *            coverage data request height
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox andWidth: (NSNumber *) width andHeight: (NSNumber *) height;

/**
 * Get the requested coverage data values
 *
 * @param request
 *            coverage data request
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesWithCoverageDataRequest: (GPKGCoverageDataRequest *) request;

/**
 * Get the requested coverage data values with the requested width and height
 *
 * @param request
 *            coverage data request
 * @param width
 *            coverage data request width
 * @param height
 *            coverage data request height
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesWithCoverageDataRequest: (GPKGCoverageDataRequest *) request andWidth: (NSNumber *) width andHeight: (NSNumber *) height;

/**
 * Get the unbounded coverage data values within the bounding box. Unbounded
 * results retrieves and returns each coverage data pixel. The results size
 * equals the width and height of all matching pixels.
 *
 * @param requestBoundingBox
 *            request bounding box
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesUnboundedWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox;

/**
 * Get the requested unbounded coverage data values. Unbounded results retrieves
 * and returns each coverage data pixel. The results size equals the width and
 * height of all matching pixels.
 *
 * @param request
 *            coverage data request
 * @return coverage data results
 */
-(GPKGCoverageDataResults *) valuesUnboundedWithCoverageDataRequest: (GPKGCoverageDataRequest *) request;

/**
 * Get the coverage data value of the pixel in the tile row image
 *
 * @param tileRow
 *            tile row
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(double) valueWithTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y;

@end
