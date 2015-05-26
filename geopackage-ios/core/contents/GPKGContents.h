//
//  GPKGContents.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGBoundingBox.h"

extern NSString * const GPKG_CON_TABLE_NAME;
extern NSString * const GPKG_CON_COLUMN_PK;
extern NSString * const GPKG_CON_COLUMN_TABLE_NAME;
extern NSString * const GPKG_CON_COLUMN_DATA_TYPE;
extern NSString * const GPKG_CON_COLUMN_IDENTIFIER;
extern NSString * const GPKG_CON_COLUMN_DESCRIPTION;
extern NSString * const GPKG_CON_COLUMN_LAST_CHANGE;
extern NSString * const GPKG_CON_COLUMN_MIN_X;
extern NSString * const GPKG_CON_COLUMN_MIN_Y;
extern NSString * const GPKG_CON_COLUMN_MAX_X;
extern NSString * const GPKG_CON_COLUMN_MAX_Y;
extern NSString * const GPKG_CON_COLUMN_SRS_ID;

enum GPKGContentsDataType{
    GPKG_CDT_FEATURES,
    GPKG_CDT_TILES
};

extern NSString * const GPKG_CDT_FEATURES_NAME;
extern NSString * const GPKG_CDT_TILES_NAME;

@interface GPKGContents : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *theDescription;
@property (nonatomic, strong) NSDate *lastChange;
@property (nonatomic, strong) NSDecimalNumber *minX;
@property (nonatomic, strong) NSDecimalNumber *minY;
@property (nonatomic, strong) NSDecimalNumber *maxX;
@property (nonatomic, strong) NSDecimalNumber *maxY;
@property (nonatomic, strong) NSNumber *srsId;

-(enum GPKGContentsDataType) getContentsDataType;

-(void) setContentsDataType: (enum GPKGContentsDataType) dataType;

-(void) setSrs: (GPKGSpatialReferenceSystem *) srs;

-(GPKGBoundingBox *) getBoundingBox;

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
