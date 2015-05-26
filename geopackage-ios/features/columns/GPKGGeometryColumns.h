//
//  GPKGGeometryColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "WKBGeometryTypes.h"

extern NSString * const GPKG_GC_TABLE_NAME;
extern NSString * const GPKG_GC_COLUMN_PK1;
extern NSString * const GPKG_GC_COLUMN_PK2;
extern NSString * const GPKG_GC_COLUMN_TABLE_NAME;
extern NSString * const GPKG_GC_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_GC_COLUMN_GEOMETRY_TYPE_NAME;
extern NSString * const GPKG_GC_COLUMN_SRS_ID;
extern NSString * const GPKG_GC_COLUMN_Z;
extern NSString * const GPKG_GC_COLUMN_M;

@interface GPKGGeometryColumns : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSString *geometryTypeName;
@property (nonatomic, strong) NSNumber *srsId;
@property (nonatomic, strong) NSNumber *z;
@property (nonatomic, strong) NSNumber *m;

-(enum WKBGeometryType) getGeometryType;

-(void) setGeometryType: (enum WKBGeometryType) geometryType;

-(void) setZ:(NSNumber *)z;

-(void) setM:(NSNumber *)m;

-(void) setContents: (GPKGContents *) contents;

-(void) setSrs: (GPKGSpatialReferenceSystem *) srs;

@end
