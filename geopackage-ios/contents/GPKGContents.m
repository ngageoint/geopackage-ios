//
//  GPKGContents.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContents.h"
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

-(enum GPKGContentsDataType) contentsDataType{
    enum GPKGContentsDataType value = -1;
    
    if(self.dataType != nil){
        value = [GPKGContentsDataTypes fromName:self.dataType];
    }
    
    return value;
}

-(void) setContentsDataType: (enum GPKGContentsDataType) dataType{
    self.dataType = [GPKGContentsDataTypes name:dataType];
}

-(void) setDataType: (NSString *) name asContentsDataType: (enum GPKGContentsDataType) dataType{
    [self setDataType:name];
    [GPKGContentsDataTypes setName:name asType:dataType];
}

-(BOOL) isFeaturesType{
    return [GPKGContentsDataTypes isFeaturesType:_dataType];
}

-(BOOL) isFeaturesTypeOrUnknown{
    return [GPKGContentsDataTypes isFeaturesType:_dataType andMatchUnknown:YES];
}

-(BOOL) isTilesType{
    return [GPKGContentsDataTypes isTilesType:_dataType];
}

-(BOOL) isTilesTypeOrUnknown{
    return [GPKGContentsDataTypes isTilesType:_dataType andMatchUnknown:YES];
}

-(BOOL) isAttributesType{
    return [GPKGContentsDataTypes isAttributesType:_dataType];
}

-(BOOL) isAttributesTypeOrUnknown{
    return [GPKGContentsDataTypes isAttributesType:_dataType andMatchUnknown:YES];
}

-(void) setSrs: (GPKGSpatialReferenceSystem *) srs{
    if(srs != nil){
        self.srsId = srs.srsId;
    }else{
        self.srsId = nil;
    }
}

-(GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox *boundingBox = nil;
    if(self.minX != nil && self.maxX != nil && self.minY != nil && self.maxY != nil){
        boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitude:self.minX andMinLatitude:self.minY andMaxLongitude:self.maxX andMaxLatitude:self.maxY];
    }
    return boundingBox;
}

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox{
    self.minX = boundingBox.minLongitude;
    self.maxX = boundingBox.maxLongitude;
    self.minY = boundingBox.minLatitude;
    self.maxY = boundingBox.maxLatitude;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGContents *contents = [[GPKGContents alloc] init];
    contents.tableName = _tableName;
    contents.dataType = _dataType;
    contents.identifier = _identifier;
    contents.theDescription = _theDescription;
    contents.lastChange = _lastChange;
    contents.minX = _minX;
    contents.maxX = _maxX;
    contents.minY = _minY;
    contents.maxY = _maxY;
    contents.srsId = _srsId;
    return contents;
}

@end
