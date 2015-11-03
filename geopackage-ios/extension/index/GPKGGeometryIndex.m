//
//  GPKGGeometryIndex.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeometryIndex.h"

NSString * const GPKG_GI_TABLE_NAME = @"nga_geometry_index";
NSString * const GPKG_GI_COLUMN_PK1 = @"table_name";
NSString * const GPKG_GI_COLUMN_PK2 = @"geom_id";
NSString * const GPKG_GI_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_GI_COLUMN_GEOM_ID = @"geom_id";
NSString * const GPKG_GI_COLUMN_MIN_X = @"min_x";
NSString * const GPKG_GI_COLUMN_MAX_X = @"max_x";
NSString * const GPKG_GI_COLUMN_MIN_Y = @"min_y";
NSString * const GPKG_GI_COLUMN_MAX_Y = @"max_y";
NSString * const GPKG_GI_COLUMN_MIN_Z = @"min_z";
NSString * const GPKG_GI_COLUMN_MAX_Z = @"max_z";
NSString * const GPKG_GI_COLUMN_MIN_M = @"min_m";
NSString * const GPKG_GI_COLUMN_MAX_M = @"max_m";

@implementation GPKGGeometryIndex

-(void) setTableIndex: (GPKGTableIndex *) tableIndex{
    if(tableIndex != nil){
        self.tableName = tableIndex.tableName;
    }else{
        self.tableName = nil;
    }
}

@end
