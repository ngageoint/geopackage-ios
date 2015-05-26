//
//  GPKGDataColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumns.h"

NSString * const GPKG_DC_TABLE_NAME = @"gpkg_data_columns";
NSString * const GPKG_DC_COLUMN_PK1 = @"table_name";
NSString * const GPKG_DC_COLUMN_PK2 = @"column_name";
NSString * const GPKG_DC_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_DC_COLUMN_COLUMN_NAME = @"column_name";
NSString * const GPKG_DC_COLUMN_NAME = @"name";
NSString * const GPKG_DC_COLUMN_TITLE = @"title";
NSString * const GPKG_DC_COLUMN_DESCRIPTION = @"description";
NSString * const GPKG_DC_COLUMN_MIME_TYPE = @"mime_type";
NSString * const GPKG_DC_COLUMN_CONSTRAINT_NAME = @"constraint_name";

@implementation GPKGDataColumns

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        // Verify the Contents have a data type
        enum GPKGContentsDataType dataType = contents.getContentsDataType;
        if(dataType != GPKG_CDT_TILES && dataType != GPKG_CDT_FEATURES){
            [NSException raise:@"Contents Type" format:@"The Contents of Data Columns must have a data type of tiles or features"];
        }
        self.tableName = contents.tableName;
    }else{
        self.tableName = nil;
    }
}

-(void) setConstraint: (GPKGDataColumnConstraints *) constraint{
    if(constraint != nil){
        self.constraintName = constraint.constraintName;
    }else{
        self.constraintName = nil;
    }
}

@end
