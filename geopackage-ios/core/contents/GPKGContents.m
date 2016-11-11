//
//  GPKGContents.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContents.h"
#import "GPKGUtils.h"
#import "GPKGContentsDataTypes.h"

NSString * const GPKG_CON_TABLE_NAME = @"gpkg_contents";
NSString * const GPKG_CON_COLUMN_PK = @"table_name";
NSString * const GPKG_CON_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_CON_COLUMN_DATA_TYPE = @"data_type";
NSString * const GPKG_CON_COLUMN_IDENTIFIER = @"identifier";
NSString * const GPKG_CON_COLUMN_DESCRIPTION = @"description";
NSString * const GPKG_CON_COLUMN_LAST_CHANGE = @"last_change";
NSString * const GPKG_CON_COLUMN_MIN_X = @"min_x";
NSString * const GPKG_CON_COLUMN_MIN_Y = @"min_y";
NSString * const GPKG_CON_COLUMN_MAX_X = @"max_x";
NSString * const GPKG_CON_COLUMN_MAX_Y = @"max_y";
NSString * const GPKG_CON_COLUMN_SRS_ID = @"srs_id";

@implementation GPKGContents

-(enum GPKGContentsDataType) getContentsDataType{
    enum GPKGContentsDataType value = -1;
    
    if(self.dataType != nil){
        value = [GPKGContentsDataTypes fromName:self.dataType];
    }
    
    return value;
}

-(void) setContentsDataType: (enum GPKGContentsDataType) dataType{
    self.dataType = [GPKGContentsDataTypes name:dataType];
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
