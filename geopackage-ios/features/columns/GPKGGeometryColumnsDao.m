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

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GC_TABLE_NAME;
        self.idColumns = @[GPKG_GC_COLUMN_PK1, GPKG_GC_COLUMN_PK2];
        self.columns = @[GPKG_GC_COLUMN_TABLE_NAME, GPKG_GC_COLUMN_COLUMN_NAME, GPKG_GC_COLUMN_GEOMETRY_TYPE_NAME, GPKG_GC_COLUMN_SRS_ID, GPKG_GC_COLUMN_Z, GPKG_GC_COLUMN_M];
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

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryColumns *getObject = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.columnName;
            break;
        case 2:
            value = getObject.geometryTypeName;
            break;
        case 3:
            value = getObject.srsId;
            break;
        case 4:
            value = getObject.z;
            break;
        case 5:
            value = getObject.m;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGGeometryColumns *projectionObject = (GPKGGeometryColumns*) object;
    GPKGSpatialReferenceSystem * srs = [self getSrs:projectionObject];
    GPKGSpatialReferenceSystemDao * srsDao = [self getSpatialReferenceSystemDao];
    GPKGProjection * projection = [srsDao getProjection:srs];
    return projection;
}

-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName{
    
    GPKGGeometryColumns *geometryColumns = nil;
    
    GPKGResultSet * result = [self queryForEqWithField:GPKG_GC_COLUMN_TABLE_NAME andValue:tableName];
    if([result moveToNext]){
        geometryColumns = (GPKGGeometryColumns *) [self getObject:result];
    }
    [result close];
    
    return geometryColumns;
}

-(NSArray *) getFeatureTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GPKG_GC_COLUMN_TABLE_NAME, GPKG_GC_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGGeometryColumns *) geometryColumns{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:geometryColumns.srsId];
    return srs;
}

-(GPKGContents *) getContents: (GPKGGeometryColumns *) geometryColumns{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:geometryColumns.tableName];
    return contents;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
