//
//  GPKGGeometryColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GC_TABLE_NAME;
extern NSString * const GC_COLUMN_TABLE_NAME;
extern NSString * const GC_COLUMN_COLUMN_NAME;
extern NSString * const GC_COLUMN_GEOMETRY_TYPE_NAME;
extern NSString * const GC_COLUMN_SRS_ID;
extern NSString * const GC_COLUMN_Z;
extern NSString * const GC_COLUMN_M;

@interface GPKGGeometryColumns : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSString *geometryTypeName;
@property (nonatomic, strong) NSNumber *srsId;
@property (nonatomic, strong) NSNumber *z;
@property (nonatomic, strong) NSNumber *m;

@end
