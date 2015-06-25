//
//  GPKGGeoPackageMetadataTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/25/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageMetadataTableCreator.h"
#import "GPKGGeoPackageMetadata.h"
#import "GPKGTableMetadata.h"
#import "GPKGGeometryMetadata.h"

@implementation GPKGGeoPackageMetadataTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db{
    self = [super initWithDatabase:db];
    return self;
}

-(int) createGeoPackageMetadata{
    return [self createTable:GPKG_GPM_TABLE_NAME];
}

-(int) createTableMetadata{
    return [self createTable:GPKG_GPTM_TABLE_NAME];
}

-(int) createGeometryMetadata{
    return [self createTable:GPKG_GPGM_TABLE_NAME];
}

-(void) createAll{
    [self createGeoPackageMetadata];
    [self createTableMetadata];
    [self createGeometryMetadata];
}

@end
