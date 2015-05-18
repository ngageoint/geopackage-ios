//
//  GPKGGeometryColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryColumns.h"

NSString * const GC_TABLE_NAME = @"gpkg_geometry_columns";
NSString * const GC_COLUMN_TABLE_NAME = @"table_name";
NSString * const GC_COLUMN_COLUMN_NAME = @"column_name";
NSString * const GC_COLUMN_GEOMETRY_TYPE_NAME = @"geometry_type_name";
NSString * const GC_COLUMN_SRS_ID = @"srs_id";
NSString * const GC_COLUMN_Z = @"z";
NSString * const GC_COLUMN_M = @"m";

@implementation GPKGGeometryColumns

-(void) setZ:(NSNumber *)z{
    [self validateValuesWithColumn:GC_COLUMN_Z andValue:z];
    _z = z;
}

-(void) setM:(NSNumber *)m{
    [self validateValuesWithColumn:GC_COLUMN_M andValue:m];
    _m = m;
}

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        enum GPKGContentsDataType dataType = contents.getContentsDataType;
        if(dataType != FEATURES){
            [NSException raise:@"Contents Type" format:@"The Contents of Geometry Columns must have a data type of features"];
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

-(void) validateValuesWithColumn: (NSString *) column andValue: (NSNumber *) value{
    int intValue = [value intValue];
    if(intValue < 0 || intValue > 2){
        [NSException raise:@"Illegal Value" format:@"%@ value must be 0 for prohibited, 1 for mandatory, or 2 for optional. Illegal: %@", column, value];
    }
}

@end
