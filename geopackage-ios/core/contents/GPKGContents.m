//
//  GPKGContents.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContents.h"

NSString * const CON_TABLE_NAME = @"gpkg_contents";
NSString * const CON_COLUMN_PK = @"table_name";
NSString * const CON_COLUMN_TABLE_NAME = @"table_name";
NSString * const CON_COLUMN_DATA_TYPE = @"data_type";
NSString * const CON_COLUMN_IDENTIFIER = @"identifier";
NSString * const CON_COLUMN_DESCRIPTION = @"description";
NSString * const CON_COLUMN_LAST_CHANGE = @"last_change";
NSString * const CON_COLUMN_MIN_X = @"min_x";
NSString * const CON_COLUMN_MIN_Y = @"min_y";
NSString * const CON_COLUMN_MAX_X = @"max_x";
NSString * const CON_COLUMN_MAX_Y = @"max_y";
NSString * const CON_COLUMN_SRS_ID = @"srs_id";

NSString * const CDT_FEATURES = @"features";
NSString * const CDT_TILES = @"tiles";

@implementation GPKGContents

-(enum GPKGContentsDataType) getContentsDataType{
    enum GPKGContentsDataType value = -1;
    
    if(self.dataType != nil){
        NSDictionary *dataTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInteger:FEATURES], CDT_FEATURES,
                            [NSNumber numberWithInteger:TILES], CDT_TILES,
                            nil
                            ];
        NSNumber *enumValue = [dataTypes objectForKey:self.dataType];
        value = (enum GPKGContentsDataType)[enumValue intValue];
    }
    
    return value;
    
}

-(void) setContentsDataType: (enum GPKGContentsDataType) dataType{
    switch(dataType){
        case FEATURES:
            self.dataType = CDT_FEATURES;
            break;
        case TILES:
            self.dataType = CDT_TILES;
            break;
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
