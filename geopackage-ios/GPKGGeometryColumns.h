//
//  GPKGGeometryColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const TABLE_NAME = @"gpkg_geometry_columns";
NSString * const COLUMN_TABLE_NAME = @"table_name";
NSString * const COLUMN_COLUMN_NAME = @"column_name";
NSString * const COLUMN_GEOMETRY_TYPE_NAME = @"geometry_type_name";
NSString * const COLUMN_SRS_ID = @"srs_id";
NSString * const COLUMN_Z = @"z";
NSString * const COLUMN_M = @"m";

@interface GPKGGeometryColumns : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSString *geometryTypeName;
@property (nonatomic, strong) NSNumber *srsId;
@property (nonatomic, strong) NSNumber *z;
@property (nonatomic, strong) NSNumber *m;

@end
