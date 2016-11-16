//
//  GPKGElevationTilesCommon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGGriddedCoverageDao.h"

extern NSString * const GPKG_ELEVATION_TILES_EXTENSION_NAME;

@interface GPKGElevationTilesCommon : GPKGBaseExtension

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension definition URL
 */
@property (nonatomic, strong) NSString *definition;

/**
 * Elevation results width
 */
@property (nonatomic, strong) NSNumber *width;

/**
 * Elevation results height
 */
@property (nonatomic, strong) NSNumber *height;

/**
 * True if zooming in should be performed to find a tile matrix with
 * elevation values
 */
@property (nonatomic) BOOL zoomIn;

/**
 * True if zooming out should be performed to find a tile matrix with
 * elevation values
 */
@property (nonatomic) BOOL zoomOut;

/**
 * True if zoom in in before zooming out, false to zoom out first
 */
@property (nonatomic) BOOL zoomInBeforeOut;

/**
 * Interpolation algorithm
 */
@property (nonatomic) enum GPKGElevationTilesAlgorithm algorithm;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileMatrixSet tile matrix set
 *  @param width specified results width
 *  @param height specified results height
 *  @param requestProjection request projection
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileMatrixSet tile matrix set
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

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
-(GPKGProjection *) requestProjection;

/**
 * Get the elevation projection
 *
 * @return elevation projection
 */
-(GPKGProjection *) elevationProjection;

/**
 * Get the elevation bounding box
 *
 * @return elevation bounding box
 */
-(GPKGBoundingBox *) elevationBoundingBox;

/**
 * Is the request and elevation projection the same
 *
 * @return true if the same
 */
-(BOOL) isSameProjection;

/**
 *  Get or create the extension
 *
 *  @return extensions array
 */
-(NSArray *) getOrCreate;

/**
 * Determine if the Tile Matrix Set has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Get the gridded coverage
 *
 * @return gridded coverage
 */
-(GPKGGriddedCoverage *) griddedCoverage;

/**
 *  Query and updated the gridded coverage
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
 * Get the elevation tile tables
 *
 * @param geoPackage
 *            GeoPackage
 * @return table names
 */
+(NSArray *) tablesForGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the pixel value as an "unsigned short" at the coordinate from the
 * "unsigned short" pixel values
 *
 * @param pixelValues
 *            "unsigned short" pixel values
 * @param width
 *            image width
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return "unsigned short" pixel value
 */
-(unsigned short) pixelValueWithValues:(NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y;

/**
 * Get the elevation value for the "unsigned short" pixel value
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValue
 *            pixel value as an unsigned short
 * @return elevation value
 */
-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (unsigned short) pixelValue;

/**
 * Get the elevation values from the "unsigned short" pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values as "unsigned shorts"
 * @return elevation values
 */
-(NSArray *) elevationValuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (NSArray *) pixelValues;

/**
 * Create the elevation tile table with metadata
 *
 * @param geoPackage GeoPackage
 * @param tableName table name
 * @param contentsBoundingBox contents bounding box
 * @param contentsSrsId contents srs id
 * @param tileMatrixSetBoundingBox tile matrix set bounding box
 * @param tileMatrixSetSrsId tile matrix set srs id
 */
+(GPKGTileMatrixSet *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

/**
 * Get the "unsigned short" pixel value of the elevation
 *
 * @param griddedTile
 *            gridded tile
 * @param elevation
 *            elevation value
 * @return "unsigned short" pixel value
 */
-(unsigned short) pixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevation: (NSDecimalNumber *) elevation;

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
 * Get the elevation value for the pixel value
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValue
 *            pixel value
 * @return elevation value
 */
-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValue: (float) pixelValue;

/**
 * Get the elevation values from the pixel values
 *
 * @param griddedTile
 *            gridded tile
 * @param pixelValues
 *            pixel values
 * @return elevation values
 */
-(NSArray *) elevationValuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (NSArray *) pixelValues;

/**
 * Get the pixel value of the elevation
 *
 * @param griddedTile
 *            gridded tile
 * @param elevation
 *            elevation value
 * @return pixel value
 */
-(float) floatPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevation: (NSDecimalNumber *) elevation;

@end
