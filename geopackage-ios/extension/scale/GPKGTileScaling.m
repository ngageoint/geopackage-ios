//
//  GPKGTileScaling.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileScaling.h"

NSString * const GPKG_TS_TABLE_NAME = @"nga_tile_scaling";
NSString * const GPKG_TS_COLUMN_PK = @"table_name";
NSString * const GPKG_TS_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_TS_COLUMN_SCALING_TYPE = @"scaling_type";
NSString * const GPKG_TS_COLUMN_ZOOM_IN = @"zoom_in";
NSString * const GPKG_TS_COLUMN_ZOOM_OUT = @"zoom_out";

@implementation GPKGTileScaling

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut{
    self = [super init];
    if(self != nil){
        [self setTileMatrixSet:tileMatrixSet];
        [self setTileScalingType:scalingType];
        self.zoomIn = zoomIn;
        self.zoomOut = zoomOut;
    }
    return self;
}

-(instancetype) initWithTableName: (NSString *) tableName andScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        [self setTileScalingType:scalingType];
        self.zoomIn = zoomIn;
        self.zoomOut = zoomOut;
    }
    return self;
}

-(instancetype) initWithScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut{
    self = [super init];
    if(self != nil){
        [self setTileScalingType:scalingType];
        self.zoomIn = zoomIn;
        self.zoomOut = zoomOut;
    }
    return self;
}

-(void) setTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    [self setTableName:tileMatrixSet != nil ? tileMatrixSet.tableName : nil];
}

-(enum GPKGTileScalingType) getTileScalingType{
    enum GPKGTileScalingType value = -1;
    
    if(self.scalingType != nil){
        value = [GPKGTileScalingTypes fromName:self.scalingType];
    }
    
    return value;
}

-(void) setTileScalingType: (enum GPKGTileScalingType) scalingType{
    self.scalingType = [GPKGTileScalingTypes name:scalingType];
}

-(BOOL) isZoomIn{
    return (self.zoomIn == nil || [self.zoomIn intValue] > 0) && self.scalingType != nil && [self getTileScalingType] != GPKG_TSC_OUT;
}

-(BOOL) isZoomOut{
    return (self.zoomOut == nil || [self.zoomOut intValue] > 0) && self.scalingType != nil && [self getTileScalingType] != GPKG_TSC_IN;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileScaling *tileScaling = [[GPKGTileScaling alloc] init];
    tileScaling.tableName = _tableName;
    tileScaling.scalingType = _scalingType;
    tileScaling.zoomIn = _zoomIn;
    tileScaling.zoomOut = _zoomOut;
    return tileScaling;
}

@end
