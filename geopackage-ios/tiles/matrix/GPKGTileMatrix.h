//
//  GPKGTileMatrix.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"

extern NSString * const GPKG_TM_TABLE_NAME;
extern NSString * const GPKG_TM_COLUMN_PK1;
extern NSString * const GPKG_TM_COLUMN_PK2;
extern NSString * const GPKG_TM_COLUMN_TABLE_NAME;
extern NSString * const GPKG_TM_COLUMN_ZOOM_LEVEL;
extern NSString * const GPKG_TM_COLUMN_MATRIX_WIDTH;
extern NSString * const GPKG_TM_COLUMN_MATRIX_HEIGHT;
extern NSString * const GPKG_TM_COLUMN_TILE_WIDTH;
extern NSString * const GPKG_TM_COLUMN_TILE_HEIGHT;
extern NSString * const GPKG_TM_COLUMN_PIXEL_X_SIZE;
extern NSString * const GPKG_TM_COLUMN_PIXEL_Y_SIZE;

@interface GPKGTileMatrix : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSNumber *zoomLevel;
@property (nonatomic, strong) NSNumber *matrixWidth;
@property (nonatomic, strong) NSNumber *matrixHeight;
@property (nonatomic, strong) NSNumber *tileWidth;
@property (nonatomic, strong) NSNumber *tileHeight;
@property (nonatomic, strong) NSDecimalNumber *pixelXSize;
@property (nonatomic, strong) NSDecimalNumber *pixelYSize;

-(void) setContents: (GPKGContents *) contents;

-(void) setZoomLevel:(NSNumber *)zoomLevel;

-(void) setMatrixWidth:(NSNumber *)matrixWidth;

-(void) setMatrixHeight:(NSNumber *)matrixHeight;

-(void) setTileWidth:(NSNumber *)tileWidth;

-(void) setTileHeight:(NSNumber *)tileHeight;

-(void) setPixelXSize:(NSDecimalNumber *)pixelXSize;

-(void) setPixelYSize:(NSDecimalNumber *)pixelYSize;

@end
