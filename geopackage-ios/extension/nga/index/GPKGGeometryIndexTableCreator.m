//
//  GPKGGeometryIndexTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGGeometryIndexTableCreator.h"
#import "GPKGGeometryIndex.h"

@implementation GPKGGeometryIndexTableCreator

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    return self;
}

-(int) createTableIndex{
    return [self createTable:GPKG_TI_TABLE_NAME];
}

-(int) createGeometryIndex{
    return [self createTable:GPKG_GI_TABLE_NAME];
}

-(int) indexGeometryIndex{
    return [self execSQLForProperty:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_index"]];
}

-(int) unindexGeometryIndex{
    return [self execSQLForProperty:[NSString stringWithFormat:@"%@%@", GPKG_GI_TABLE_NAME, @"_unindex"]];
}

@end
