//
//  GPKGFeatureTiles.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPKGResultSet.h"
#import "GPKGBoundingBox.h"
#import "GPKGFeatureDao.h"
#import "GPKGCompressFormats.h"

@interface GPKGFeatureTiles : NSObject

@property (nonatomic) BOOL indexQuery;
@property (nonatomic) int tileWidth;
@property (nonatomic) int tileHeight;
@property (nonatomic) enum GPKGCompressFormat compressFormat;
@property (nonatomic) double pointRadius;
@property (nonatomic) BOOL fillPolygon;
@property (nonatomic) double heightOverlap;
@property (nonatomic) double widthOverlap;

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao;

-(void) calculateDrawOverlap;

-(void) setDrawOverlapsWithPixels: (double) pixels;

-(NSData *) drawTileDataWithX: (int) x andY: (int) y andZoom: (int) zoom;

-(UIImage *) drawTileWithX: (int) x andY: (int) y andZoom: (int) zoom;

-(UIImage *) drawTileQueryIndexWithX: (int) x andY: (int) y andZoom: (int) zoom;

-(UIImage *) drawTileQueryAllWithX: (int) x andY: (int) y andZoom: (int) zoom;

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andResults: (GPKGResultSet *) results;

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andFeatureRows: (NSArray *) featureRows;

@end
