//
//  GPKGGriddedTile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGriddedTile.h"

NSString * const GPKG_CDGT_TABLE_NAME = @"gpkg_2d_gridded_tile_ancillary";
NSString * const GPKG_CDGT_COLUMN_PK = @"id";
NSString * const GPKG_CDGT_COLUMN_ID = @"id";
NSString * const GPKG_CDGT_COLUMN_TABLE_NAME = @"tpudt_name";
NSString * const GPKG_CDGT_COLUMN_TABLE_ID = @"tpudt_id";
NSString * const GPKG_CDGT_COLUMN_SCALE = @"scale";
NSString * const GPKG_CDGT_COLUMN_OFFSET = @"offset";
NSString * const GPKG_CDGT_COLUMN_MIN = @"min";
NSString * const GPKG_CDGT_COLUMN_MAX = @"max";
NSString * const GPKG_CDGT_COLUMN_MEAN = @"mean";
NSString * const GPKG_CDGT_COLUMN_STANDARD_DEVIATION = @"std_dev";

@implementation GPKGGriddedTile

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        self.tableName = contents.tableName;
    }else{
        self.tableName = nil;
    }
}

-(double) scaleOrDefault{
    return self.scale != nil ? [self.scale doubleValue] : 1.0;
}

-(double) offsetOrDefault{
    return self.offset != nil ? [self.offset doubleValue] : 0.0;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGGriddedTile *griddedTile = [[GPKGGriddedTile alloc] init];
    griddedTile.id = _id;
    griddedTile.tableName = _tableName;
    griddedTile.tableId = _tableId;
    griddedTile.scale = _scale;
    griddedTile.offset = _offset;
    griddedTile.min = _min;
    griddedTile.max = _max;
    griddedTile.mean = _mean;
    griddedTile.standardDeviation = _standardDeviation;
    return griddedTile;
}

@end
