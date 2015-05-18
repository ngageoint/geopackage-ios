//
//  GPKGContents.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContents.h"

NSString * const CON_TABLE_NAME = @"gpkg_contents";
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

@implementation GPKGContents

-(enum GPKGContentsDataType) getContentsDataType{
    enum GPKGContentsDataType value = -1;
    
    if(self.dataType != nil){
        NSDictionary *dataTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInteger:FEATURES], @"features",
                            [NSNumber numberWithInteger:TILES], @"tiles",
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
            self.dataType = @"features";
            break;
        case TILES:
            self.dataType = @"tiles";
            break;
    }
}

@end
