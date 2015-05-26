//
//  GPKGTileMatrixSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrixSet.h"

NSString * const GPKG_TMS_TABLE_NAME = @"gpkg_tile_matrix_set";
NSString * const GPKG_TMS_COLUMN_PK = @"table_name";
NSString * const GPKG_TMS_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_TMS_COLUMN_SRS_ID = @"srs_id";
NSString * const GPKG_TMS_COLUMN_MIN_X = @"min_x";
NSString * const GPKG_TMS_COLUMN_MIN_Y = @"min_y";
NSString * const GPKG_TMS_COLUMN_MAX_X = @"max_x";
NSString * const GPKG_TMS_COLUMN_MAX_Y = @"max_y";

@implementation GPKGTileMatrixSet

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        // Verify the Contents have a tiles data type (Spec Requirement 33)
        enum GPKGContentsDataType dataType = contents.getContentsDataType;
        if(dataType != GPKG_CDT_TILES){
            [NSException raise:@"Contents Type" format:@"The Contents of a Tile Matrix Set must have a data type of tiles"];
        }
        self.tableName = contents.tableName;
    }else{
        self.tableName = nil;
    }
}

-(void) setSrs: (GPKGSpatialReferenceSystem *) srs{
    if(srs != nil){
        self.srsId = srs.srsId;
    }else{
        self.srsId = nil;
    }
}

-(GPKGBoundingBox *) getBoundingBox{
    return[[GPKGBoundingBox alloc] initWithMinLongitude:self.minX andMaxLongitude:self.maxX andMinLatitude:self.minY andMaxLatitude:self.maxY];
}

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox{
    self.minX = boundingBox.minLongitude;
    self.maxX = boundingBox.maxLongitude;
    self.minY = boundingBox.minLatitude;
    self.maxY = boundingBox.maxLatitude;
}

@end
