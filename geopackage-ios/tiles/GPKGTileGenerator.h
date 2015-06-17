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

@interface GPKGTileGenerator : NSObject

@property (nonatomic, strong) GPKGGeoPackage * geoPackage;
@property (nonatomic, strong) NSString * tableName;
@property (nonatomic) int minZoom;
@property (nonatomic) int maxZoom;
@property (nonatomic, strong) NSNumber * tileCount;
@property (nonatomic, strong) NSMutableDictionary * tileGrids;
@property (nonatomic, strong) GPKGBoundingBox * boundingBox;
@property (nonatomic, strong) GPKGBoundingBox * tileMatrixSetBoundingBox;
@property (nonatomic) enum GPKGCompressFormat compressFormat;
@property (nonatomic) CGFloat compressQuality;
@property (nonatomic, strong)  NSObject<GPKGProgress> * progress;
@property (nonatomic, strong) NSDecimalNumber * scale;
@property (nonatomic) BOOL standardWebMercatorFormat;
@property (nonatomic) CGFloat compressScale;
@property (nonatomic, strong) GPKGBoundingBox * webMercatorBoundingBox;
@property (nonatomic) int matrixHeight;
@property (nonatomic) int matrixWidth;

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom;

-(void) setTileBoundingBox: (GPKGBoundingBox *) boundingBox;

-(int) getTileCount;

-(int) generateTiles;

-(void) close;

@end
