//
//  GPKGTileGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGBoundingBox.h"
#import "GPKGProgress.h"
#import "GPKGTileScaling.h"

/**
 *  Creates a set of tiles within a GeoPackage
 */
@interface GPKGTileGenerator : NSObject

/**
 *  GeoPackage
 */
@property (nonatomic, strong) GPKGGeoPackage * geoPackage;

/**
 *  Table Name
 */
@property (nonatomic, strong) NSString * tableName;

/**
 *  Min zoom level
 */
@property (nonatomic) int minZoom;

/**
 *  Max zoom level
 */
@property (nonatomic) int maxZoom;

/**
 *  Tiles projection
 */
@property (nonatomic, strong) SFPProjection * projection;

/**
 *  Total tile count
 */
@property (nonatomic, strong) NSNumber * totalCount;

/**
 *  Tile grids by zoom level
 */
@property (nonatomic, strong) NSMutableDictionary * tileGrids;

/**
 *  Tile bounding boxes by zoom level
 */
@property (nonatomic, strong) NSMutableDictionary * tileBounds;

/**
 *  Tile bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox * boundingBox;

/**
 *  Compress format
 */
@property (nonatomic) enum GPKGCompressFormat compressFormat;

/**
 *  Compress quality
 */
@property (nonatomic) CGFloat compressQuality;

/**
 *  GeoPackage progress for callbacks
 */
@property (nonatomic, strong)  NSObject<GPKGProgress> * progress;

/**
 * True when generating tiles in standard z,x,y tile format, false when generating
 * GeoPackage format where rows and columns do not match the standard row &
 * column coordinates
 */
@property (nonatomic) BOOL xyzTiles;

/**
 *  Compress scale
 */
@property (nonatomic) CGFloat compressScale;

/**
 *  Tile grid bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox * tileGridBoundingBox;

/**
 *  Matrix height when GeoPackage tile format
 */
@property (nonatomic) int matrixHeight;

/**
 *  Matrix width when GeoPackage tile format
 */
@property (nonatomic) int matrixWidth;

/**
 *  Tile scaling settings
 */
@property (nonatomic, strong) GPKGTileScaling *scaling;

/**
 * Skip existing tiles
 */
@property (nonatomic) BOOL skipExisting;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tableName  table name
 *  @param minZoom    min zoom
 *  @param maxZoom    max zoom
 *  @param boundingBox tiles bounding box
 *  @param projection tiles projection
 *
 *  @return new tile generator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (SFPProjection *) projection;

/**
 * Get the bounding box, possibly expanded for the zoom level
 *
 * @param zoom zoom level
 * @return original or expanded bounding box
 */
-(GPKGBoundingBox *) boundingBoxAtZoom: (int) zoom;

/**
 *  Set the compress quality as an integer percentage, 0 to 100
 *
 *  @param percentage integer percentage
 */
-(void) setCompressQualityAsIntPercentage: (int) percentage;

/**
 *  Set the compress scale as an integer percentage, 0 to 100
 *
 *  @param percentage integer percentage
 */
-(void) setCompressScaleAsIntPercentage: (int) percentage;

/**
 *  Get the tile count of tiles to be generated
 *
 *  @return tile count
 */
-(int) tileCount;

/**
 *  Generate the tiles
 *
 *  @return tiles generated
 */
-(int) generateTiles;

/**
 *  Close the GeoPackage
 */
-(void) close;

@end
