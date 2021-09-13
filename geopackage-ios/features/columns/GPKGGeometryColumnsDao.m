//
//  GPKGGeometryColumnsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryColumnsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGContentsDao.h"

@implementation GPKGGeometryColumnsDao

+(GPKGGeometryColumnsDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:database];
}

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GC_TABLE_NAME;
        self.idColumns = @[GPKG_GC_COLUMN_PK1, GPKG_GC_COLUMN_PK2];
        self.columnNames = @[GPKG_GC_COLUMN_TABLE_NAME, GPKG_GC_COLUMN_COLUMN_NAME, GPKG_GC_COLUMN_GEOMETRY_TYPE_NAME, GPKG_GC_COLUMN_SRS_ID, GPKG_GC_COLUMN_Z, GPKG_GC_COLUMN_M];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeometryColumns alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeometryColumns *setObject = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.columnName = (NSString *) value;
            break;
        case 2:
            setObject.geometryTypeName = (NSString *) value;
            break;
        case 3:
            setObject.srsId = (NSNumber *) value;
            break;
        case 4:
            setObject.z = (NSNumber *) value;
            break;
        case 5:
            setObject.m = (NSNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryColumns *columns = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 0:
            value = columns.tableName;
            break;
        case 1:
            value = columns.columnName;
            break;
        case 2:
            value = columns.geometryTypeName;
            break;
        case 3:
            value = columns.srsId;
            break;
        case 4:
            value = columns.z;
            break;
        case 5:
            value = columns.m;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(PROJProjection *) projection: (NSObject *) object{
    GPKGGeometryColumns *projectionObject = (GPKGGeometryColumns*) object;
    GPKGSpatialReferenceSystem * srs = [self srs:projectionObject];
    PROJProjection *projection = [srs projection];
    return projection;
}

-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName{
    
    GPKGGeometryColumns *geometryColumns = nil;
    
    GPKGResultSet * result = [self queryForEqWithField:GPKG_GC_COLUMN_TABLE_NAME andValue:tableName];
    if([result moveToNext]){
        geometryColumns = (GPKGGeometryColumns *) [self object:result];
    }
    [result close];
    
    return geometryColumns;
}

-(NSArray *) featureTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GPKG_GC_COLUMN_TABLE_NAME, GPKG_GC_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(GPKGSpatialReferenceSystem *) srs: (GPKGGeometryColumns *) geometryColumns{
    GPKGSpatialReferenceSystemDao * dao = [self spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:geometryColumns.srsId];
    return srs;
}

-(GPKGContents *) contents: (GPKGGeometryColumns *) geometryColumns{
    GPKGContentsDao * dao = [self contentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:geometryColumns.tableName];
    return contents;
}

-(GPKGSpatialReferenceSystemDao *) spatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) contentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
