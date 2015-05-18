//
//  GPKGTileMatrixSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGBoundingBox.h"

extern NSString * const TMS_TABLE_NAME;
extern NSString * const TMS_COLUMN_TABLE_NAME;
extern NSString * const TMS_COLUMN_SRS_ID;
extern NSString * const TMS_COLUMN_MIN_X;
extern NSString * const TMS_COLUMN_MIN_Y;
extern NSString * const TMS_COLUMN_MAX_X;
extern NSString * const TMS_COLUMN_MAX_Y;

@interface GPKGTileMatrixSet : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSNumber *srsId;
@property (nonatomic, strong) NSDecimalNumber *minX;
@property (nonatomic, strong) NSDecimalNumber *minY;
@property (nonatomic, strong) NSDecimalNumber *maxX;
@property (nonatomic, strong) NSDecimalNumber *maxY;

-(void) setContents: (GPKGContents *) contents;

-(void) setSrs: (GPKGSpatialReferenceSystem *) srs;

-(GPKGBoundingBox *) getBoundingBox;

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
