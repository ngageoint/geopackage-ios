//
//  GPKGGriddedTile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGriddedTile.h"

NSString * const GPKG_EGT_TABLE_NAME = @"gpkg_2d_gridded_tile_ancillary";
NSString * const GPKG_EGT_COLUMN_PK = @"id";
NSString * const GPKG_EGT_COLUMN_ID = @"id";
NSString * const GPKG_EGT_COLUMN_TABLE_NAME = @"tpudt_name";
NSString * const GPKG_EGT_COLUMN_TABLE_ID = @"tpudt_id";
NSString * const GPKG_EGT_COLUMN_SCALE = @"scale";
NSString * const GPKG_EGT_COLUMN_OFFSET = @"offset";
NSString * const GPKG_EGT_COLUMN_MIN = @"min";
NSString * const GPKG_EGT_COLUMN_MAX = @"max";
NSString * const GPKG_EGT_COLUMN_MEAN = @"mean";
NSString * const GPKG_EGT_COLUMN_STANDARD_DEVIATION = @"std_dev";

@implementation GPKGGriddedTile

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        self.tableName = contents.tableName;
    }else{
        self.tableName = nil;
    }
}

-(double) getScaleOrDefault{
    return self.scale != nil ? [self.scale doubleValue] : 1.0;
}

-(double) getOffsetOrDefault{
    return self.offset != nil ? [self.offset doubleValue] : 0.0;
}

@end
