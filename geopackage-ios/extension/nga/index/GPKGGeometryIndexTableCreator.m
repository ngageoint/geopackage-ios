//
//  GPKGGeometryIndexTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGGeometryIndexTableCreator.h"

@implementation GPKGGeometryIndexTableCreator

// TODO

-(int) createTableIndex{
    return [self createTable:GPKG_TI_TABLE_NAME];
}

-(int) createGeometryIndex{
    return [self createTable:GPKG_GI_TABLE_NAME];
}

-(int) indexGeometryIndex{
    return [self execSQLScript:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_index"]];
}

-(int) unindexGeometryIndex{
    return [self execSQLScript:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_unindex"]];
}

@end
